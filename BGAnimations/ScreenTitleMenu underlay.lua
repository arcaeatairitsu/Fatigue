if IsSMOnlineLoggedIn() then
	CloseConnection()
end

local t = Def.ActorFrame {}

local frameX = THEME:GetMetric("ScreenTitleMenu", "ScrollerX") - 10
local frameY = THEME:GetMetric("ScreenTitleMenu", "ScrollerY")

--Title text
t[#t + 1] = UIElements.TextToolTip(1, 1, "Common Large") .. {
	InitCommand=function(self)
		self:xy(205,50):zoom(0.6):align(0.5,1)
		self:diffusetopedge(64,64,64, 0.5)
		self:diffusebottomedge(32,32,32, 0.8)
	end,
	OnCommand=function(self)
		self:settext("Etterna: Fatigue")
	end,
	
}

t[#t+1] = Def.ActorFrame {
	Name = "LogoFrame",
	InitCommand = function(self)
		self:xy(20,20)
	end,

	UIElements.SpriteButton(100, 1, THEME:GetPathG("", "Logo")) .. {
		Name = "Logo",
		InitCommand = function(self)
			self:halign(0):valign(0)
			self:zoomto(85,85)
		end,
	}
}
	
--Version number
t[#t + 1] = UIElements.TextToolTip(1, 1, "Common Large") .. {
	Name = "Version",
	InitCommand=function(self)
		self:xy(100,55):zoom(0.3):align(0,0)
		self:diffusetopedge(64,64,64, 0.5)
		self:diffusebottomedge(32,32,32, 0.8)
	end,
	BeginCommand = function(self)
		self:settext(string.format("v%s", GAMESTATE:GetEtternaVersion()))
	end,
	MouseDownCommand = function(self, params)
		if params.event == "DeviceButton_left mouse button" then
			local tag = "urlnoexit,https://github.com/etternagame/etterna/releases/tag/v" .. GAMESTATE:GetEtternaVersion()
			GAMESTATE:ApplyGameCommand(tag)
		end
	end
}



local function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	i = 1
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

local transformF = THEME:GetMetric("ScreenTitleMenu", "ScrollerTransform")
local scrollerX = THEME:GetMetric("ScreenTitleMenu", "ScrollerX")
local scrollerY = THEME:GetMetric("ScreenTitleMenu", "ScrollerY")
local scrollerChoices = THEME:GetMetric("ScreenTitleMenu", "ChoiceNames")
local _, count = string.gsub(scrollerChoices, "%,", "")
local choices = mysplit(scrollerChoices, ",")
local choiceCount = count + 1
local i
for i = 1, choiceCount do
	t[#t + 1] = UIElements.QuadButton(1, 1) .. {
		OnCommand = function(self)
			self:xy(scrollerX, scrollerY):zoomto(260, 16)
			transformF(self, 0, i, choiceCount)
			self:addx(SCREEN_CENTER_X - 20)
			self:addy(SCREEN_CENTER_Y - 20)
			self:diffusealpha(0)
		end,
		MouseDownCommand = function(self, params)
			if params.event == "DeviceButton_left mouse button" then
				SCREENMAN:GetTopScreen():playcommand("MadeChoicePlayer_1")
				SCREENMAN:GetTopScreen():playcommand("Choose")
				if choices[i] == "Multi" or choices[i] == "GameStart" then
					GAMESTATE:JoinPlayer()
				end
				GAMESTATE:ApplyGameCommand(THEME:GetMetric("ScreenTitleMenu", "Choice" .. choices[i]))
			end
		end
	}
end

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(850,465):zoom(0.4):valign(1):halign(1)
	end,
	OnCommand=function(self)
		if IsNetSMOnline() then
			self:settext("Online")
			self:diffuse(getMainColor('enabled'))
		else
			self:settext("Offline")
			self:diffuse(getMainColor('disabled'))
		end
	end
}


t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(850,475):zoom(0.35):valign(1):halign(1):diffuse(color("#666666"))
	end,
	OnCommand=function(self)
		if IsNetSMOnline() then
			self:settext(GetServerName())
			self:diffuse(color("#FFFFFF"))
		else
			self:settext("Not Available")
		end
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(98,75):zoom(0.5):valign(0):halign(0):diffuse(color("#888888"))
	end,
	OnCommand=function(self)
		self:settext(string.format("%s Songs in %s Groups",SONGMAN:GetNumSongs(),SONGMAN:GetNumSongGroups()))
	end
}

local function UpdateTime(self)
	local year = Year()
	local month = MonthOfYear() + 1
	local day = DayOfMonth()
	local hour = Hour()
	local minute = Minute()
	local second = Second()
	self:GetChild("CurrentTime"):settextf("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)

end

t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self:SetUpdateFunction(UpdateTime)
	end,
	LoadFont("Common Normal") .. {
		Name = "CurrentTime",
		InitCommand = function(self)
			self:xy(1,462):halign(0):valign(0):zoom(0.75)
		end
	},
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(830,35):zoom(0.4):valign(0):halign(1):diffuse(color("#FFFFFF"))
	end,
	OnCommand=function(self)
		self:settext("Theme by Gekizi\n Etterna by poco0317")
	end
}

return t
