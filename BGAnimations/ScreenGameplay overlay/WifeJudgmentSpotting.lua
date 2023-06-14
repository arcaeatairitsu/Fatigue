--[[ 
	Basically rewriting the c++ code to not be total shit so this can also not be total shit.
]]
local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local practiceMode = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingPractice()
local jcKeys = tableKeys(colorConfig:get_data().judgment)
local jcT = {} -- A "T" following a variable name will designate an object of type table.

for i = 1, #jcKeys do
	jcT[jcKeys[i]] = byJudgment(jcKeys[i])
end

local jdgT = {
	-- Table of judgments for the judgecounter
	"TapNoteScore_W1",
	"TapNoteScore_W2",
	"TapNoteScore_W3",
	"TapNoteScore_W4",
	"TapNoteScore_W5",
	"TapNoteScore_Miss",
	"HoldNoteScore_Held",
	"HoldNoteScore_LetGo"
}

local dvCur
local jdgCur  -- Note: only for judgments with OFFSETS, might reorganize a bit later
local tDiff
local wifey
local judgect
local pbtarget
local curMeanSum = 0
local curMeanCount = 0
local positive = getMainColor("positive")
local highlight = getMainColor("highlight")
local negative = getMainColor("negative")

local jdgCounts = {} -- Child references for the judge counter

-- We can also pull in some localized aliases for workhorse functions for a modest speed increase
local Round = notShit.round
local Floor = notShit.floor
local diffusealpha = Actor.diffusealpha
local diffuse = Actor.diffuse
local finishtweening = Actor.finishtweening
local linear = Actor.linear
local x = Actor.x
local y = Actor.y
local addx = Actor.addx
local addy = Actor.addy
local Zoomtoheight = Actor.zoomtoheight
local Zoomtowidth = Actor.zoomtowidth
local Zoomm = Actor.zoom
local queuecommand = Actor.queuecommand
local playcommand = Actor.queuecommand
local settext = BitmapText.settext
local Broadcast = MessageManager.Broadcast

-- these dont really work as borders since they have to be destroyed/remade in order to scale width/height
-- however we can use these to at least make centered snap lines for the screens -mina
local function dot(height, x)
	return Def.Quad {
		InitCommand = function(self)
			self:zoomto(dotwidth, height)
			self:addx(x)
		end
	}
end

local function dottedline(len, height, x, y, rot)
	local t =
		Def.ActorFrame {
		InitCommand = function(self)
			self:xy(x, y):addrotationz(rot)
			if x == 0 and y == 0 then
				self:diffusealpha(0.65)
			end
		end
	}
	local numdots = len / dotwidth
	t[#t + 1] = dot(height, 0)
	for i = 1, numdots / 4 do
		t[#t + 1] = dot(height, i * dotwidth * 2 - dotwidth / 2)
	end
	for i = 1, numdots / 4 do
		t[#t + 1] = dot(height, -i * dotwidth * 2 + dotwidth / 2)
	end
	return t
end

local function DottedBorder(width, height, bw, x, y)
	return Def.ActorFrame {
		Name = "Border",
		InitCommand = function(self)
			self:xy(x, y):visible(false):diffusealpha(0.35)
		end,
		dottedline(width, bw, 0, 0, 0),
		dottedline(width, bw, 0, height / 2, 0),
		dottedline(width, bw, 0, -height / 2, 0),
		dottedline(height, bw, 0, 0, 90),
		dottedline(height, bw, width / 2, 0, 90),
		dottedline(height, bw, -width / 2, 0, 90)
	}
end

-- Screenwide params
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
isCentered = PREFSMAN:GetPreference("Center1Player")
local CenterX = SCREEN_CENTER_X
local mpOffset = 0
if not isCentered then
	CenterX =
		THEME:GetMetric(
		"ScreenGameplay",
		string.format("PlayerP1%sX", ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType()))
	)
	mpOffset = SCREEN_CENTER_X
end
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--

local screen  -- the screen after it is loaded

local WIDESCREENWHY = -5
local WIDESCREENWHX = -5

--error bar things
local errorBarFrameWidth = capWideScale(get43size(MovableValues.ErrorBarWidth), MovableValues.ErrorBarWidth)
local wscale = errorBarFrameWidth / 180

--differential tracker things
local targetTrackerMode = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetTrackerMode

--receptor/Notefield things
local Notefield
local noteColumns
local usingReverse

--guess checking if things are enabled before changing them is good for not having a log full of errors
local enabledErrorBar = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).ErrorBar
local enabledTargetTracker = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetTracker
local enabledDisplayPercent = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).DisplayPercent
local enabledDisplayMean = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).DisplayMean
local leaderboardEnabled = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).leaderboardEnabled and DLMAN:IsLoggedIn()
local isReplay = GAMESTATE:GetPlayerState():GetPlayerController() == "PlayerController_Replay"

local function arbitraryErrorBarValue(value)
	errorBarFrameWidth = capWideScale(get43size(value), value)
	wscale = errorBarFrameWidth / 180
end

local function spaceNotefieldCols(inc)
	if inc == nil then inc = 0 end
	local hCols = math.floor(#noteColumns/2)
	for i, col in ipairs(noteColumns) do
	    col:addx((i-hCols-1) * inc)
	end
end

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
								     **Wife deviance tracker. Basically half the point of the theme.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	For every doot there is an equal and opposite scoot.
]]
local t =
	Def.ActorFrame {
	Name = "WifePerch",
	OnCommand = function(self)
		if allowedCustomization then
			-- auto enable autoplay
			GAMESTATE:SetAutoplay(true)
		else
			GAMESTATE:SetAutoplay(false)
		end
		-- Discord thingies
		local largeImageTooltip =
			GetPlayerOrMachineProfile(PLAYER_1):GetDisplayName() ..
			": " .. string.format("%5.2f", GetPlayerOrMachineProfile(PLAYER_1):GetPlayerRating())
		local detail =
			GAMESTATE:GetCurrentSong():GetDisplayMainTitle() ..
			" " ..
				string.gsub(getCurRateDisplayString(), "Music", "") .. " [" .. GAMESTATE:GetCurrentSong():GetGroupName() .. "]"
		-- truncated to 128 characters(discord hard limit)
		detail = #detail < 128 and detail or string.sub(detail, 1, 124) .. "..."
		local state = "MSD: " .. string.format("%05.2f", GAMESTATE:GetCurrentSteps():GetMSD(getCurRateValue(), 1))
		local endTime = os.time() + GetPlayableTime()
		GAMESTATE:UpdateDiscordPresence(largeImageTooltip, detail, state, endTime)
		local streamerstuff =
		"Now playing " ..
		GAMESTATE:GetCurrentSong():GetDisplayMainTitle() ..
			" by " ..
				GAMESTATE:GetCurrentSong():GetDisplayArtist() ..
					" in " .. GAMESTATE:GetCurrentSong():GetGroupName() .. " " .. state
		File.Write("nowplaying.txt", streamerstuff)

		screen = SCREENMAN:GetTopScreen()
		usingReverse = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingReverse()
		Notefield = screen:GetChild("PlayerP1"):GetChild("NoteField")
		Notefield:addy(MovableValues.NotefieldY * (usingReverse and 1 or -1))
		Notefield:addx(MovableValues.NotefieldX)
		noteColumns = Notefield:get_column_actors()
		-- lifebar stuff
		local lifebar = SCREENMAN:GetTopScreen():GetLifeMeter(PLAYER_1)

		if (allowedCustomization) then
			Movable.pressed = false
			Movable.current = "None"
			Movable.DeviceButton_r.element = Notefield
			Movable.DeviceButton_t.element = noteColumns
			Movable.DeviceButton_r.condition = true
			Movable.DeviceButton_t.condition = true
			Movable.DeviceButton_f.condition = true
			Movable.DeviceButton_f.DeviceButton_up.arbitraryFunction = spaceNotefieldCols
			Movable.DeviceButton_f.DeviceButton_down.arbitraryFunction = spaceNotefieldCols
		end

		if lifebar ~= nil then
			lifebar:zoomtowidth(0)
			lifebar:zoomtoheight(0)
			lifebar:xy(0,0)
		end

		for i, actor in ipairs(noteColumns) do
			actor:zoomtowidth(MovableValues.NotefieldWidth)
			actor:zoomtoheight(MovableValues.NotefieldHeight)
		end
		spaceNotefieldCols(MovableValues.NotefieldSpacing)
	end,
	DoneLoadingNextSongMessageCommand = function(self)
		-- put notefield y pos back on doneloadingnextsong because playlist courses reset this for w.e reason -mina
		screen = SCREENMAN:GetTopScreen()

		-- nil checks are needed because these don't exist when doneloadingnextsong is sent initially
		-- which is convenient for us since addy -mina
		if screen ~= nil and screen:GetChild("PlayerP1") ~= nil then
			Notefield = screen:GetChild("PlayerP1"):GetChild("NoteField")
			Notefield:addy(MovableValues.NotefieldY * (usingReverse and 1 or -1))
		end
		-- force update everything once when entering new song
		self:playcommand("PracticeModeReset")
	end,
	JudgmentMessageCommand = function(self, msg)
		tDiff = msg.WifeDifferential
		wifey = Floor(msg.WifePercent * 10000) / 10000
		jdgct = msg.Val
		if msg.Offset ~= nil then
			dvCur = msg.Offset
			if not msg.HoldNoteScore then
				curMeanSum = curMeanSum + dvCur
				curMeanCount = curMeanCount + 1
			end
		else
			dvCur = nil
		end
		if msg.WifePBGoal ~= nil and targetTrackerMode ~= 0 then
			pbtarget = msg.WifePBGoal
			tDiff = msg.WifePBDifferential
		end
		jdgCur = msg.Judgment
		self:playcommand("SpottedOffset")
	end,
	PracticeModeResetMessageCommand = function(self)
		tDiff = 0
		wifey = 0
		jdgct = 0
		dvCur = nil
		jdgCur = nil
		curMeanCount = 0
		curMeanSum = 0
		self:playcommand("SpottedOffset")
	end
}
--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
																	**LaneCover**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Old scwh lanecover back for now. Equivalent to "screencutting" on ffr; essentially hides notes for a fixed distance before they appear
on screen so you can adjust the time arrows display on screen without modifying their spacing from each other. 
]]
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCover then
	t[#t + 1] = LoadActor("lanecover")
end

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 					    	**Player Target Differential: Ghost target rewrite, average score gone for now**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Point differential to AA.
]]
-- Mostly clientside now. We set our desired target goal and listen to the results rather than calculating ourselves.
local target = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetGoal
GAMESTATE:GetPlayerState():SetTargetGoal(target / 100)


-- We can save space by wrapping the personal best and set percent trackers into one function, however
-- this would make the actor needlessly cumbersome and unnecessarily punish those who don't use the
-- personal best tracker (although everything is efficient enough now it probably wouldn't matter)

-- moved it for better manipulation
local d =
	Def.ActorFrame {
	Name = "TargetTracker",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_7.element = self
			Movable.DeviceButton_8.element = self
			Movable.DeviceButton_8.Border = self:GetChild("Border")
			Movable.DeviceButton_7.condition = enabledTargetTracker
			Movable.DeviceButton_8.condition = enabledTargetTracker
		end
		self:xy(MovableValues.TargetTrackerX, MovableValues.TargetTrackerY):zoom(MovableValues.TargetTrackerZoom)
	end,
	MovableBorder(100, 13, 1, 0, 0)
}

if targetTrackerMode == 0 then -- going for set goals
	d[#d + 1] =
		LoadFont("Common Normal") ..
		{
			Name = "PercentDifferential",
			InitCommand = function(self)
				self:halign(0):valign(1)
				if allowedCustomization then
					self:settextf("%5.2f (%5.2f%%)", -100, 100)
					setBorderAlignment(self:GetParent():GetChild("Border"), 0, 1)
					setBorderToText(self:GetParent():GetChild("Border"), self)
				end
				self:settextf("")
			end,
			SpottedOffsetCommand = function(self)
				if tDiff >= 0 then
					diffuse(self, positive)
				else
					diffuse(self, negative)
				end
				self:settextf("%5.2f (%5.2f%%)", tDiff, target)
			end
		}
else -- going for PB
	d[#d + 1] =
		LoadFont("Common Normal") ..
		{
			Name = "PBDifferential",
			InitCommand = function(self)
				self:halign(0):valign(1)
				if allowedCustomization then
					self:settextf("%5.2f (%5.2f%%)", -100, 100)
					setBorderAlignment(self:GetParent():GetChild("Border"), 0, 1)
					setBorderToText(self:GetParent():GetChild("Border"), self)
				end
				self:settextf("")
			end,
			SpottedOffsetCommand = function(self, msg)
				if pbtarget then
					if tDiff >= 0 then
						diffuse(self, color("#00ff00"))
					else
						diffuse(self, negative)
					end
					self:settextf("%5.2f (%5.2f%%)", tDiff, pbtarget * 100)
				else
					if tDiff >= 0 then
						diffuse(self, positive)
					else
						diffuse(self, negative)
					end
					self:settextf("%5.2f (%5.2f%%)", tDiff, target)
				end
			end
		}
end

if enabledTargetTracker then
	t[#t + 1] = d
end

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 					    									**Display Percent**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Displays the current percent for the score.
]]
local cp =
	Def.ActorFrame {
	Name = "DisplayPercent",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_w.element = self
			Movable.DeviceButton_e.element = self
			Movable.DeviceButton_w.condition = enabledDisplayPercent
			Movable.DeviceButton_e.condition = enabledDisplayPercent
			Movable.DeviceButton_w.Border = self:GetChild("Border")
			Movable.DeviceButton_e.Border = self:GetChild("Border")
		end
		self:zoom(MovableValues.DisplayPercentZoom):x(MovableValues.DisplayPercentX):y(MovableValues.DisplayPercentY)
	end,
	Def.Quad {
		InitCommand = function(self)
			self:zoomto(60, 13):diffuse(color("0,0,0,0.4")):halign(0.5):valign(0)
		end
	},
	-- Displays your current percentage score
	LoadFont("Common Large") ..
		{
			Name = "DisplayPercent",
			InitCommand = function(self)
				self:zoom(0.3):halign(0.5):valign(0)
			end,
			OnCommand = function(self)
				if allowedCustomization then
					self:settextf("%05.4f%%", 100)
					setBorderAlignment(self:GetParent():GetChild("Border"), 1, 0)
					setBorderToText(self:GetParent():GetChild("Border"), self)
				end
				self:settextf("%05.4f%%", 0)
			end,
			SpottedOffsetCommand = function(self)
				self:settextf("%05.4f%%", wifey)
			end
		},
	MovableBorder(100, 13, 1, 0, 0)
}

if enabledDisplayPercent then
	t[#t + 1] = cp
end

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 					    									**Current Mean**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Displays the current mean for all tap deviations so far.
	GRRRRRRRR POCO WHY AINT THIS WORKING
]]

local mT =
	Def.ActorFrame {
		Name = "DisplayMean",
		InitCommand = function(self)
			if (allowedCustomization) then
				Movable.DeviceButton_n.element = self
				Movable.DeviceButton_m.element = self
				Movable.DeviceButton_n.condition = enabledDisplayMean
				Movable.DeviceButton_m.condition = enabledDisplayMean
				Movable.DeviceButton_n.Border = self:GetChild("Border")
				Movable.DeviceButton_m.Border = self:GetChild("Border")
			end
			self:zoom(MovableValues.DisplayMeanZoom):x(MovableValues.DisplayMeanX):y(MovableValues.DisplayMeanY)
		end,
		Def.Quad {
			InitCommand = function(self)
				self:zoomto(60, 13):diffuse(color("0,0,0,0.4")):halign(1):valign(0)
			end
		},
		-- Displays your current mean
		LoadFont("Common Large") ..
			{
				Name = "DisplayMeanText",
				InitCommand = function(self)
					self:zoom(0.3):halign(1):valign(0)
				end,
				OnCommand = function(self)
					if allowedCustomization then
						self:settextf("%5.2fms", -180)
						setBorderAlignment(self:GetParent():GetChild("Border"), 1, 0)
						setBorderToText(self:GetParent():GetChild("Border"), self)
					end
					self:settextf("%5.2fms", 0)
				end,
				SpottedOffsetCommand = function(self)
					self:settextf("%5.2fms", curMeanSum / curMeanCount)
				end
			},
		MovableBorder(100, 13, 1, 0, 0)
	}

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
														    	**Player ErrorBar**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Visual display of deviance MovableValues. 
--]]
-- User Parameters
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
local barcount = 30 -- Number of bars. Older bars will refresh if judgments/barDuration exceeds this value. You don't need more than 40.
local barWidth = 2 -- Width of the ticks.
local barDuration = 0.75 -- Time duration in seconds before the ticks fade out. Doesn't need to be higher than 1. Maybe if you have 300 bars I guess.
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
local currentbar = 1 -- so we know which error bar we need to update
local ingots = {} -- references to the error bars
local alpha = 0.07 -- ewma alpha
local avg
local lastAvg

-- Makes the error bars. They position themselves relative to the center of the screen based on your dv and diffuse to your judgment value before disappating or refreshing
-- Should eventually be handled by the game itself to optimize performance
function smeltErrorBar(index)
	return Def.Quad {
		Name = index,
		InitCommand = function(self)
			self:xy(MovableValues.ErrorBarX, MovableValues.ErrorBarY):zoomto(barWidth, MovableValues.ErrorBarHeight):diffusealpha(
				0
			)
		end,
		UpdateErrorBarCommand = function(self) -- probably a more efficient way to achieve this effect, should test stuff later
			finishtweening(self) -- note: it really looks like shit without the fade out
			diffusealpha(self, 1)
			diffuse(self, jcT[jdgCur])
			x(self, MovableValues.ErrorBarX + dvCur * wscale)
			y(self, MovableValues.ErrorBarY)
			Zoomtoheight(self, MovableValues.ErrorBarHeight)
			linear(self, barDuration)
			diffusealpha(self, 0)
		end
	}
end

local e =
	Def.ActorFrame {
	Name = "ErrorBar",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_5.element = self:GetChildren()
			Movable.DeviceButton_6.element = self:GetChildren()
			Movable.DeviceButton_5.condition = enabledErrorBar ~= 0
			Movable.DeviceButton_6.condition = enabledErrorBar ~= 0
			Movable.DeviceButton_5.Border = self:GetChild("Border")
			Movable.DeviceButton_6.Border = self:GetChild("Border")
			Movable.DeviceButton_6.DeviceButton_left.arbitraryFunction = arbitraryErrorBarValue
			Movable.DeviceButton_6.DeviceButton_right.arbitraryFunction = arbitraryErrorBarValue
		end
		if enabledErrorBar == 1 then
			for i = 1, barcount do -- basically the equivalent of using GetChildren() if it returned unnamed children numerically indexed
				ingots[#ingots + 1] = self:GetChild(i)
			end
		else
			avg = 0
			lastAvg = 0
		end
	end,
	SpottedOffsetCommand = function(self)
		if enabledErrorBar == 1 then
			if dvCur ~= nil then
				currentbar = ((currentbar) % barcount) + 1
				ingots[currentbar]:playcommand("UpdateErrorBar") -- Update the next bar in the queue
			end
		end
	end,
	DootCommand = function(self)
		self:RemoveChild("DestroyMe")
		self:RemoveChild("DestroyMe2")
		
		-- basically we need the ewma version to exist inside this actor frame
		-- for customize gameplay stuff, however it seems silly to have it running
		-- visibility/nil/type checks if we aren't using it, so we can just remove
		-- it if we're outside customize gameplay and errorbar is set to normal -mina
		if not allowedCustomization and enabledErrorBar == 1 then
			self:RemoveChild("WeightedBar")
		end
	end,
	Def.Quad {
		Name = "WeightedBar",
		InitCommand = function(self)
			if enabledErrorBar == 2 then
				self:xy(MovableValues.ErrorBarX, MovableValues.ErrorBarY):zoomto(barWidth, MovableValues.ErrorBarHeight):diffusealpha(
					1
				):diffuse(getMainColor("enabled"))
			else
				self:visible(false)
			end
		end,
		SpottedOffsetCommand = function(self)
			if enabledErrorBar == 2 and dvCur ~= nil then
				avg = alpha * dvCur + (1 - alpha) * lastAvg
				lastAvg = avg
				self:x(MovableValues.ErrorBarX + avg * wscale)
			end
		end
	},
	Def.Quad {
		Name = "Center",
		InitCommand = function(self)
			self:diffuse(getMainColor("highlight")):xy(MovableValues.ErrorBarX, MovableValues.ErrorBarY):zoomto(
				2,
				MovableValues.ErrorBarHeight
			)
		end
	},
	-- Indicates which side is which (early/late) These should be destroyed after the song starts.
	LoadFont("Common Normal") ..
		{
			Name = "DestroyMe",
			InitCommand = function(self)
				self:xy(MovableValues.ErrorBarX + errorBarFrameWidth / 4, MovableValues.ErrorBarY):zoom(0.35)
			end,
			BeginCommand = function(self)
				self:settext("Late"):diffusealpha(0):smooth(0.5):diffusealpha(0.5):sleep(1.5):smooth(0.5):diffusealpha(0)
			end
		},
	LoadFont("Common Normal") ..
		{
			Name = "DestroyMe2",
			InitCommand = function(self)
				self:xy(MovableValues.ErrorBarX - errorBarFrameWidth / 4, MovableValues.ErrorBarY):zoom(0.35)
			end,
			BeginCommand = function(self)
				self:settext("Early"):diffusealpha(0):smooth(0.5):diffusealpha(0.5):sleep(1.5):smooth(0.5):diffusealpha(0):queuecommand(
					"Doot"
				)
			end,
			DootCommand = function(self)
				self:GetParent():queuecommand("Doot")
			end
		},
	MovableBorder(
		MovableValues.ErrorBarWidth,
		MovableValues.ErrorBarHeight,
		1,
		MovableValues.ErrorBarX,
		MovableValues.ErrorBarY
	)
}

-- Initialize bars
if enabledErrorBar == 1 then
	for i = 1, barcount do
		e[#e + 1] = smeltErrorBar(i)
	end
end

-- Add the completed errorbar frame to the primary actor frame t if enabled
if enabledErrorBar ~= 0 then
	t[#t + 1] = e
end

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
														    	**Music Rate Display**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
]]
t[#t + 1] =
Def.ActorFrame {
	Name = "MusicRate",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_v.element = self
			Movable.DeviceButton_b.element = self
			Movable.DeviceButton_v.condition = true
			Movable.DeviceButton_b.condition = true
			Movable.DeviceButton_v.Border = self:GetChild("Border")
			Movable.DeviceButton_b.Border = self:GetChild("Border")
		end
		self:xy(MovableValues.MusicRateX, MovableValues.MusicRateY):zoom(MovableValues.MusicRateZoom)
	end,
	LoadFont("Common Normal") ..
	{
		InitCommand = function(self)
			self:zoom(0.35):settext(getCurRateDisplayString())
		end,
		OnCommand = function(self)
			if allowedCustomization then
				setBorderToText(self:GetParent():GetChild("Border"), self)
			end
		end,
		SetRateCommand = function(self)
			self:settext(getCurRateDisplayString())
		end,
		DoneLoadingNextSongMessageCommand = function(self)
			self:playcommand("SetRate")
		end,
		CurrentRateChangedMessageCommand = function(self)
			self:playcommand("SetRate")
		end
	},
	MovableBorder(100, 13, 1, 0, 0)
}

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
														    	**BPM Display**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Better optimized frame update bpm display. 
]]
local BPM
local a = GAMESTATE:GetPlayerState():GetSongPosition()
local r = GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate() * 60
local GetBPS = SongPosition.GetCurBPS

local function UpdateBPM(self)
	local bpm = GetBPS(a) * r
	settext(BPM, Round(bpm, 2))
end	

t[#t + 1] =
	Def.ActorFrame {
	Name = "BPMText",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_x.element = self
			Movable.DeviceButton_c.element = self
			Movable.DeviceButton_x.condition = true
			Movable.DeviceButton_c.condition = true
			Movable.DeviceButton_x.Border = self:GetChild("Border")
			Movable.DeviceButton_c.Border = self:GetChild("Border")
		end
		self:x(MovableValues.BPMTextX):y(MovableValues.BPMTextY):zoom(MovableValues.BPMTextZoom)
		BPM = self:GetChild("BPM")
		if #GAMESTATE:GetCurrentSong():GetTimingData():GetBPMs() > 1 then -- dont bother updating for single bpm files
			self:SetUpdateFunction(UpdateBPM)
			self:SetUpdateRate(0.5)
		else
			BPM:settextf("%5.2f", GetBPS(a) * r) -- i wasn't thinking when i did this, we don't need to avoid formatting for performance because we only call this once -mina
		end
	end,
	LoadFont("Common Normal") ..
		{
			Name = "BPM",
			InitCommand = function(self)
				self:halign(0.5):zoom(0.40)
			end,
			OnCommand = function(self)
				if allowedCustomization then
					setBorderToText(self:GetParent():GetChild("Border"), self)
				end
			end
		},
	DoneLoadingNextSongMessageCommand = function(self)
		self:queuecommand("Init")
	end,
	-- basically a copy of the init
	CurrentRateChangedMessageCommand = function(self)
		r = GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate() * 60
		if #GAMESTATE:GetCurrentSong():GetTimingData():GetBPMs() > 1 then
			self:SetUpdateFunction(UpdateBPM)
			self:SetUpdateRate(0.5)
		else
			BPM:settextf("%5.2f", GetBPS(a) * r)
		end
	end,
	PracticeModeReloadMessageCommand = function(self)
		self:playcommand("CurrentRateChanged")
	end,
	MovableBorder(40, 13, 1, 0, 0)
}

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
															**Combo Display**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

]]
local x = 0
local y = 60

-- CUZ WIDESCREEN DEFAULTS SCREAAAAAAAAAAAAAAAAAAAAAAAAAM -mina
if IsUsingWideScreen() then
	y = y - WIDESCREENWHY
	x = x + WIDESCREENWHX
end

--This just initializes the initial point or not idk not needed to mess with this any more
function ComboTransformCommand(self, params)
	self:x(x)
	self:y(y)
end

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
															  **Practice Mode**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	stuff
]]
local prevZoom = 0.65
local musicratio = 1

-- hurrrrr nps quadzapalooza -mina
local wodth = capWideScale(get43size(240), 280)
local hidth = 40
local cd
local loopStartPos
local loopEndPos

local function handleRegionSetting(positionGiven)
	-- don't allow a negative region 
	-- internally it is limited to -2
	-- the start delay is 2 seconds, so limit this to 0
	if positionGiven < 0 then return end

	-- first time starting a region
	if not loopStartPos and not loopEndPos then
		loopStartPos = positionGiven
		MESSAGEMAN:Broadcast("RegionSet")
		return
	end

	-- reset region to bookmark only if double right click
	if positionGiven == loopStartPos or positionGiven == loopEndPos then
		loopEndPos = nil
		loopStartPos = positionGiven
		MESSAGEMAN:Broadcast("RegionSet")
		SCREENMAN:GetTopScreen():ResetLoopRegion()
		return
	end

	-- measure the difference of the new pos from each end
	local startDiff = math.abs(positionGiven - loopStartPos)
	local endDiff = startDiff + 0.1
	if loopEndPos then
		endDiff = math.abs(positionGiven - loopEndPos)
	end

	-- use the diff to figure out which end to move

	-- if there is no end, then you place the end
	if not loopEndPos then
		if loopStartPos < positionGiven then
			loopEndPos = positionGiven
		elseif loopStartPos > positionGiven then
			loopEndPos = loopStartPos
			loopStartPos = positionGiven
		else
			-- this should never happen
			-- but if it does, reset to bookmark
			loopEndPos = nil
			loopStartPos = positionGiven
			MESSAGEMAN:Broadcast("RegionSet")
			SCREENMAN:GetTopScreen():ResetLoopRegion()
			return
		end
	else
		-- closer to the start, move the start
		if startDiff < endDiff then
			loopStartPos = positionGiven
		else
			loopEndPos = positionGiven
		end
	end
	SCREENMAN:GetTopScreen():SetLoopRegion(loopStartPos, loopEndPos)
	MESSAGEMAN:Broadcast("RegionSet", {loopLength = loopEndPos-loopStartPos})
end

local function duminput(event)
	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_backspace" then
			if loopStartPos ~= nil then
				SCREENMAN:GetTopScreen():SetSongPositionAndUnpause(loopStartPos, 1, true)
			end
		elseif event.button == "EffectUp" then
			SCREENMAN:GetTopScreen():AddToRate(0.05)
		elseif event.button == "EffectDown" then
			SCREENMAN:GetTopScreen():AddToRate(-0.05)
		elseif event.button == "Coin" then
			handleRegionSetting(SCREENMAN:GetTopScreen():GetSongPosition())
		elseif event.DeviceInput.button == "DeviceButton_mousewheel up" then
			if GAMESTATE:IsPaused() then
				local pos = SCREENMAN:GetTopScreen():GetSongPosition()
				local dir = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingReverse() and 1 or -1
				local nextpos = pos + dir * 0.05
				if loopEndPos ~= nil and nextpos >= loopEndPos then
					handleRegionSetting(nextpos + 1)
				end
				SCREENMAN:GetTopScreen():SetSongPosition(nextpos, 0, false)
			end
		elseif event.DeviceInput.button == "DeviceButton_mousewheel down" then
			if GAMESTATE:IsPaused() then
				local pos = SCREENMAN:GetTopScreen():GetSongPosition()
				local dir = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingReverse() and 1 or -1
				local nextpos = pos - dir * 0.05
				if loopEndPos ~= nil and nextpos >= loopEndPos then
					handleRegionSetting(nextpos + 1)
				end
				SCREENMAN:GetTopScreen():SetSongPosition(nextpos, 0, false)
			end
		end
	end
	
	return false
end

local function UpdatePreviewPos(self)
	local pos = SCREENMAN:GetTopScreen():GetSongPosition() / musicratio
	self:GetChild("Pos"):zoomto(math.min(math.max(0, pos), wodth), hidth)
	self:queuecommand("Highlight")
end

local pm =
	Def.ActorFrame {
	Name = "ChartPreview",
	InitCommand = function(self)
		self:xy(MovableValues.PracticeCDGraphX, MovableValues.PracticeCDGraphY)
		self:SetUpdateFunction(UpdatePreviewPos)
		cd = self:GetChild("ChordDensityGraph"):visible(true):draworder(1000):y(20)
		if (allowedCustomization) then
			Movable.DeviceButton_z.element = self
			Movable.DeviceButton_z.condition = practiceMode
		end
	end,
	BeginCommand = function(self)
		musicratio = GAMESTATE:GetCurrentSong():GetLastSecond() / (wodth)
		SCREENMAN:GetTopScreen():AddInputCallback(duminput)
		cd:GetChild("cdbg"):diffusealpha(0)
		self:SortByDrawOrder()
		self:queuecommand("GraphUpdate")
	end,
	PracticeModeReloadMessageCommand = function(self)
		musicratio = GAMESTATE:GetCurrentSong():GetLastSecond() / wodth
	end,
	Def.Quad {
		Name = "BG",
		InitCommand = function(self)
			self:x(wodth / 2)
			self:diffuse(color("0.05,0.05,0.05,1"))
		end
	},
	Def.Quad {
		Name = "PosBG",
		InitCommand = function(self)
			self:zoomto(wodth, hidth):halign(0):diffuse(color("1,1,1,1")):draworder(900)
		end,
		HighlightCommand = function(self) -- use the bg for detection but move the seek pointer -mina
			if isOver(self) then
				self:GetParent():GetChild("Seek"):visible(true)
				self:GetParent():GetChild("Seektext"):visible(true)
				self:GetParent():GetChild("Seek"):x(INPUTFILTER:GetMouseX() - self:GetParent():GetX())
				self:GetParent():GetChild("Seektext"):x(INPUTFILTER:GetMouseX() - self:GetParent():GetX() - 4) -- todo: refactor this lmao -mina
				self:GetParent():GetChild("Seektext"):y(INPUTFILTER:GetMouseY() - self:GetParent():GetY())
				self:GetParent():GetChild("Seektext"):settextf(
					"%0.2f",
					self:GetParent():GetChild("Seek"):GetX() * musicratio / getCurRateValue()
				)
			else
				self:GetParent():GetChild("Seektext"):visible(false)
				self:GetParent():GetChild("Seek"):visible(false)
			end
		end
	},
	Def.Quad {
		Name = "Pos",
		InitCommand = function(self)
			self:zoomto(0, hidth):diffuse(color("0,1,0,.5")):halign(0):draworder(900)
		end
	}
	--MovableBorder(wodth+3, hidth+3, 1, (wodth)/2, 0)
}

-- Load the CDGraph with a forced width parameter.
pm[#pm + 1] = LoadActorWithParams("../_gameplaydensitygraph.lua", {width=wodth})

-- more draw order shenanigans
pm[#pm + 1] =
	LoadFont("Common Normal") ..
	{
		Name = "Seektext",
		InitCommand = function(self)
			self:y(8):valign(1):halign(1):draworder(1100):diffuse(color("0.8,0,0")):zoom(0.4)
		end
	}

pm[#pm + 1] =
	quadButton(7) .. {
		Name = "Seek",
		InitCommand = function(self)
			self:zoomto(2, hidth):diffuse(color("1,.2,.5,1")):halign(0.5):draworder(1100)
		end,
		MouseDownCommand = function(self, params)
			if params.button == "DeviceButton_left mouse button" then
				local withCtrl = INPUTFILTER:IsControlPressed()
				if withCtrl then
					handleRegionSetting(self:GetX() * musicratio)
				else
					SCREENMAN:GetTopScreen():SetSongPosition(self:GetX() * musicratio, 0, false)
				end
			elseif params.button == "DeviceButton_right mouse button" then
				handleRegionSetting(self:GetX() * musicratio)
			end
		end,
		MouseRightClickMessageCommand = function(self)
			if not isOver(self) then
				if not (allowedCustomization) then
					SCREENMAN:GetTopScreen():TogglePause()
				end
			end
		end
	}

pm[#pm + 1] =
	Def.Quad {
	Name = "BookmarkPos",
	InitCommand = function(self)
		self:zoomto(2, hidth):diffuse(color(".2,.5,1,1")):halign(0.5):draworder(1100)
		self:visible(false)
	end,
	SetCommand = function(self)
		self:visible(true)
		self:zoomto(2, hidth):diffuse(color(".2,.5,1,1")):halign(0.5)
		self:x(loopStartPos / musicratio)
	end,
	RegionSetMessageCommand = function(self, params)
		if not params or not params.loopLength then
			self:playcommand("Set")
		else
			self:visible(true)
			self:x(loopStartPos / musicratio):halign(0)
			self:zoomto(params.loopLength / musicratio, hidth):diffuse(color(".7,.2,.7,0.5"))
		end
	end,
	CurrentRateChangedMessageCommand = function(self)
		if not loopEndPos and loopStartPos then
			self:playcommand("Set")
		elseif loopEndPos and loopStartPos then
			self:playcommand("RegionSet", {loopLength = (loopEndPos - loopStartPos)})
		end
	end,
	PracticeModeReloadMessageCommand = function(self)
		self:playcommand("CurrentRateChanged")
	end
}

if practiceMode and not isReplay then
	t[#t + 1] = pm
end


return t
