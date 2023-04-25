local enabled = PREFSMAN:GetPreference("ShowBackgrounds")
local brightness = 0.4
local bgType = themeConfig:get_data().eval.SongBGType -- 1 = disabled, 2 = songbg, 3 = playerbg
local enabled = themeConfig:get_data().global.SongBGEnabled
local moveBG = themeConfig:get_data().global.SongBGMouseEnabled and enabled
local magnitude = 0.03
local maxDistX = SCREEN_WIDTH*magnitude
local maxDistY = SCREEN_HEIGHT*magnitude
local t = Def.ActorFrame {}



if enabled and bgType == 1 then -- SONG BG
	t[#t+1] = LoadSongBackground()..{
		Name="MouseXY",
		BeginCommand=function(self)
			if moveBG then
				self:scaletocover(0-maxDistX/8,0-maxDistY/8,SCREEN_WIDTH+maxDistX/8,SCREEN_BOTTOM+maxDistY/8)
				self:diffusealpha(brightness)
			else
				self:scaletocover(0,0,SCREEN_WIDTH,SCREEN_BOTTOM)
				self:diffusealpha(brightness)
			end
		end
	}
end


if enabled and bgType > 1 then -- 2 = Grade+Clear, 3 = Grade Only

	local bgList = {} -- Contains paths to potential bgs

	-- Get the highest grade from the player (or players if 2P)
	local pss
	local highestGrade = "Grade_Failed" 
	if GAMESTATE:IsPlayerEnabled() then
		pss = STATSMAN:GetCurStageStats():GetPlayerStageStats()
		local playerGrade = pss:GetGrade()
		if Enum.Reverse(Grade)[playerGrade] < Enum.Reverse(Grade)[highestGrade] then
			highestGrade = playerGrade
		end
	end

	local imgTypes = {".jpg",".png",".gif",".jpeg"}
	if highestGrade == "Grade_Failed" then -- Grab from failed folder
		bgList = FILEMAN:GetDirListing("Themes/"..THEME:GetCurThemeName().."/Graphics/Eval background/Grade_Failed/")
		for k,v in pairs(bgList) do
			bgList[k] = "Themes/"..THEME:GetCurThemeName().."/Graphics/Eval background/Grade_Failed/"..v
		end
	else
		bgList = FILEMAN:GetDirListing("Themes/"..THEME:GetCurThemeName().."/Graphics/Eval background/Grade_Cleared/")

		for k,v in pairs(bgList) do
			bgList[k] = "Themes/"..THEME:GetCurThemeName().."/Graphics/Eval background/Grade_Cleared/"..v
		end

		if FILEMAN:DoesFileExist("Themes/"..THEME:GetCurThemeName().."/Graphics/Eval background/"..highestGrade) then
			if bgType == 3 then -- If grade specific bgs only, set bglist to grade backgrounds.
				bgList = FILEMAN:GetDirListing("Themes/"..THEME:GetCurThemeName().."/Graphics/Eval background/"..highestGrade.."/")
				for k,v in pairs(bgList) do
					bgList[k] = "Themes/"..THEME:GetCurThemeName().."/Graphics/Eval background/"..highestGrade.."/"..v
				end
			else -- Else, append grade backgrounds to bglist.
				gradeBgList = FILEMAN:GetDirListing("Themes/"..THEME:GetCurThemeName().."/Graphics/Eval background/"..highestGrade.."/")
				for _,v in pairs(gradeBgList) do
					bgList[#bgList+1] = "Themes/"..THEME:GetCurThemeName().."/Graphics/Eval background/"..highestGrade.."/"..v
				end
			end
		end
	end

	-- Filter out non-supported filetypes.
	local bgList = filterFileList(bgList,imgTypes)

	t[#t+1] = Def.Sprite {
		Name="MouseXY",
		BeginCommand=function(self)
			if #bgList > 0 then
				local bg = bgList[math.random(#bgList)]
				--SCREENMAN:SystemMessage(string.format("Loading %s",bg))
				self:LoadBackground(bg)
			end
			if moveBG then
				self:scaletocover(0-maxDistX/8,0-maxDistY/8,SCREEN_WIDTH+maxDistX/8,SCREEN_BOTTOM+maxDistY/8)
				self:diffusealpha(brightness)
			else
				self:scaletocover(0,0,SCREEN_WIDTH,SCREEN_BOTTOM)
				self:diffusealpha(brightness)
			end
		end
	}
end

t[#t+1] = LoadActor("_particles")

-- Calculate bg offset based on mouse pos
local function getPosX()
	local offset = magnitude*(INPUTFILTER:GetMouseX()-SCREEN_CENTER_X)
	local neg
	if offset < 0 then
		neg = true
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(math.abs(offset)),maxDistX)
		end
	else
		neg = false
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(math.abs(offset)),maxDistX)
		end
	end
	if neg then
		return SCREEN_CENTER_X+offset
	else 
		return SCREEN_CENTER_X-offset
	end
end

local function getPosY()
	local offset = magnitude*(INPUTFILTER:GetMouseY()-SCREEN_CENTER_Y)
	local neg
	if offset < 0 then
		neg = true
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(offset),maxDistY)
		end
	else
		neg = false
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(offset),maxDistY)
		end
	end
	if neg then
		return SCREEN_CENTER_Y+offset
	else 
		return SCREEN_CENTER_Y-offset
	end
end

local function Update(self)
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end
    self:GetChild("MouseXY"):xy(getPosX(),getPosY())
end

if moveBG then
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end
end

t[#t + 1] = Def.Sprite {
	Name = "Banner",
	OnCommand = function(self)
		self:x(438):y(35):valign(0):zoom(0.5)
		local bnpath = GAMESTATE:GetCurrentSong():GetBannerPath()
		self:scaletoclipped(capWideScale(get43size(336), 336), capWideScale(get43size(105), 105))
		self:visible(true)
		if not bnpath then
			bnpath = THEME:GetPathG("Common", "fallback banner")
		end
		self:LoadBackground(bnpath)
	end
}

t[#t+1] = LoadActor("_particles")


return t
