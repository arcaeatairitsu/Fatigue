local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local fullPlayerInfo = themeConfig:get_data().global.PlayerInfoType -- true for full, false for minimal (lifebar only)
--Avatar frames which also includes current additive %score, mods, and the song stepsttype/difficulty.
local profileP1

local profileNameP1 = "No Profile"

local avatarPosition = {
	X = MovableValues.PlayerInfoP1X,
	Y = MovableValues.PlayerInfoP1Y
}

local translated_info = {
	Judge = THEME:GetString("ScreenGameplay", "ScoringJudge"),
	Scoring = THEME:GetString("ScreenGameplay", "ScoringType")
}
local function PLife(pn)
	local life = STATSMAN:GetCurStageStats():GetPlayerStageStats():GetCurrentLife() or 0
	if life < 0 then
		return 0
	else
		return life
	end
end

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats()
local profile = GetPlayerOrMachineProfile(PLAYER_1)

-- whole frame actorframe
local t = Def.ActorFrame {
	OnCommand = function(self)
		self:xy(avatarPosition.X,avatarPosition.Y)
		self:zoomto(MovableValues.PlayerInfoP1Width, MovableValues.PlayerInfoP1Height)
		if (allowedCustomization) then
			Movable.DeviceButton_j.element = self
			Movable.DeviceButton_j.condition = true
			Movable.DeviceButton_k.element = self
			Movable.DeviceButton_k.condition = true
		end
	end,
}

if fullPlayerInfo then
	-- whole frame bg quad
	t[#t+1] = Def.Quad {
		InitCommand = function(self)
			self:zoomto(200,50)
			self:halign(0):valign(0)
			self:queuecommand('Set')
		end,
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps()
			local diff = steps:GetDifficulty()
			self:diffuse(color("#000000"))
			self:diffusealpha(0.8)
		end,
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end
	}

	-- border?
	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(200,50)
			self:halign(0):valign(0)
			self:xy(-3,-3)
			self:zoomto(56,56)
			self:diffuse(color("#000000"))
			self:diffusealpha(0.8)
		end,
		SetCommand = function(self)
			self:stoptweening()
			self:smooth(0.5)
			self:diffuse(getBorderColor())
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	-- avatar
	t[#t+1] = Def.Sprite {
		InitCommand = function(self)
			self:halign(0):valign(0)
		end,
		BeginCommand = function(self) self:queuecommand('ModifyAvatar') end,
		ModifyAvatarCommand=function(self)
			self:finishtweening()
			self:Load(getAvatarPath(PLAYER_1))
			self:zoomto(50,50)
		end
	}


	-- profile name
	t[#t+1] = LoadFont("Common Bold") .. {
		InitCommand= function(self)
			local name = profile:GetDisplayName()
			self:xy(56,7):zoom(0.6):shadowlength(1):halign(0):maxwidth(180/0.6)
			self:settext(name)
		end
	}

	-- msd
	t[#t+1] = LoadFont("Common large") .. {
		InitCommand = function(self)
			self:xy(52,28):zoom(0.75):halign(0):maxwidth(100)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end,
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps()
			local diff = getDifficulty(steps:GetDifficulty())
			local meter = steps:GetMSD(getCurRateValue(),1)
			meter = meter == 0 and steps:GetMeter() or meter


			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			self:settextf("%5.2f",meter)
			self:diffuse(getMSDColor(meter))
		end,
		CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end
	}
		-- diff name
		t[#t+1] = LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:xy(127,28):zoom(0.5):halign(0):maxwidth(180/0.5)
			end,
			BeginCommand = function(self) self:queuecommand('Set') end,
			SetCommand=function(self)
				local steps = GAMESTATE:GetCurrentSteps()
				local diff = getDifficulty(steps:GetDifficulty())
				local meter = steps:GetMSD(getCurRateValue(),1)
				meter = meter == 0 and steps:GetMeter() or meter
	
	
				local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
				self:settextf("%s\n%s",diff, stype)
				self:diffuse(getDifficultyColor(steps:GetDifficulty()))
			end,
			CurrentSongChangedMessageCommand = function(self) self:queuecommand('Set') end
		}

	
	t[#t+1] = LoadFont("Common Bold") .. {
		OnCommand = function(self)
			self:xy(57, 47)
			self:zoom(0.35)
			self:queuecommand("Set")
			self:halign(0)
			self:maxwidth(1000)
		end,
		SetCommand = function(self)
			local mods = GAMESTATE:GetPlayerState():GetPlayerOptionsString("ModsLevel_Current")
			self:settext(mods)
		end

	}
end

-- life bg
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(200,50)
		self:halign(0)
		self:xy(-2, 60)
		self:zoomto(120,10)
	end
}

-- life bar
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:halign(0)
		self:xy(-2,60)
		self:zoomto(0,10):diffuse(color("#FF0000"))
		self:queuecommand("Set")
	end,
	JudgmentMessageCommand = function(self, params)
		self:playcommand("Set", params)
	end,
	SetCommand = function(self, params)
		if params ~= nil and params.TapNoteScore == "TapNoteScore_AvoidMine" then
			return
		end
		self:finishtweening()
		self:smooth(0.1)
		self:zoomx(PLife(PLAYER_1)*120)
	end
}

-- life counter
t[#t+1] = LoadFont("Common Bold") .. {
	OnCommand = function(self)
		self:xy(165,60)
		self:zoom(0.35):halign(1)
		self:queuecommand("Set")
	end,
	JudgmentMessageCommand = function(self, params)
		self:playcommand("Set", params)
	end,
	SetCommand = function(self, params)
		if params ~= nil and params.TapNoteScore == "TapNoteScore_AvoidMine" then
			return
		end
		local life = PLife(PLAYER_1)
		self:settextf("%0.1f Per.",life*10000/100)
		if life*100 < 30 and life*100 ~= 0 then -- replace with lifemeter danger later
			self:diffuseshift()
			self:effectcolor1(1,1,1,1)
			self:effectcolor2(1,0.9,0.9,0.5)
			self:effectperiod(0.9*life+0.15)
		elseif life*100 <= 0 then
			self:stopeffect()
			self:diffuse(color("0,0,0,1"))
		else
			self:stopeffect()
			self:diffuse(color("1,1,1,1"))
		end
	end
}


t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(1,-20):halign(0):zoom(0.45)
		end,
		BeginCommand = function(self)
			self:settextf("%s: %d", translated_info["Judge"], GetTimingDifficulty())
		end
	}
t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(0,-10):halign(0):zoom(0.45)
		end,
		BeginCommand = function(self)
			self:settextf("%s: %s", translated_info["Scoring"], scoringToText(4))
		end
	}
return t