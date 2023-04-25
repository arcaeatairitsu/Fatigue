--Banner and song info that shows before the gameplay starts.
--SongStartingMessageCommand is sent from progressbar.lua

local bannerWidth = 256
local bannerHeight = 80
local borderWidth = 2

local translated_info = {
	InvalidMods = THEME:GetString("ScreenGameplay", "InvalidMods"),
	By = THEME:GetString("ScreenGameplay", "CreatedBy")
}
local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y-50)
		self:diffusealpha(0)
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:easeOut(1)
		self:diffusealpha(0.8)
		self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y-60)
	end,
	SongStartingMessageCommand = function(self)
		self:stoptweening()
		self:smooth(0.5)
		self:diffusealpha(0)
	end
}



t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:y(30)
		self:zoomto(bannerWidth+borderWidth*4,bannerHeight+borderWidth*4+60)
		self:diffuse(color("#000000"))
		self:diffusealpha(0)
	end,
	CurrentSongChangedMessageCommand = function(self)
		if GAMESTATE:GetCurrentSteps() ~= nil then
			self:diffuse(getDifficultyColor(GAMESTATE:GetHardestStepsDifficulty()))
		end
	end
}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:y(30)
		self:zoomto(bannerWidth+borderWidth*2,bannerHeight+borderWidth*2+60)
		self:diffuse(color("#000000"))
		self:diffusealpha(0.8)
	end
}

t[#t+1] = Def.Sprite {
	CurrentSongChangedMessageCommand = function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song then
			local bnpath = song:GetBannerPath()
			if not bnpath then
				bnpath = THEME:GetPathG("Common", "fallback banner")
			end
			self:LoadBackground(bnpath)
		end
		self:scaletoclipped(bannerWidth,bannerHeight)
	end
}

t[#t+1] = LoadFont("Common Bold") .. {
	InitCommand = function(self)
		self:y(50)
		self:zoom(0.6)
		self:diffusealpha(1)
		self:maxwidth(bannerWidth/0.6)
	end,
	CurrentSongChangedMessageCommand = function(self)
		if GAMESTATE:GetCurrentSong() ~= nil then
			self:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle())
		end
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:y(65)
		self:zoom(0.4)
		self:diffusealpha(1)
		self:maxwidth(bannerWidth/0.4)
	end,
	CurrentSongChangedMessageCommand = function(self)
		if GAMESTATE:GetCurrentSong() ~= nil then
			self:settext(GAMESTATE:GetCurrentSong():GetDisplaySubTitle())
		end
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:y(80)
		self:zoom(0.4)
		self:diffusealpha(1)
		self:maxwidth(bannerWidth/0.4)
	end,
	CurrentSongChangedMessageCommand = function(self)
		if GAMESTATE:GetCurrentSong() ~= nil then
			self:settext(GAMESTATE:GetCurrentSong():GetDisplayArtist())
		end
	end
}

t[#t+1] = LoadFont("Common Normal") .. { -- will make this sync'd with other information later
	Name = "credits",
	InitCommand = function(self)
		self:y(90):zoom(0.35):diffusealpha(0)
	end,
	BeginCommand = function(self)
		local auth = GAMESTATE:GetCurrentSong():GetOrTryAtLeastToGetSimfileAuthor()
		self:settextf("%s", auth)
	end,
	OnCommand = function(self)
		self:smooth(0.5):diffusealpha(1):sleep(1):smooth(0.3):smooth(0.4):diffusealpha(0)
	end
}

t[#t+1] = Def.ActorFrame {
	LoadFont("Common Normal") .. {
	Name = "InvalidatingMods",
	InitCommand = function(self)
		self:xy(0,100):zoom(0.55):diffusealpha(1):valign(0):diffuse(color"#ff0000")
	end,
	BeginCommand = function(self)
		mods = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():GetInvalidatingMods()
		local translated = {}
		if #mods > 0 then
			for _,mod in ipairs(mods) do
				table.insert(translated, THEME:HasString("OptionNames", mod) and THEME:GetString("OptionNames", mod) or mod)
			end
			self:settextf("%s\n%s", translated_info["InvalidMods"], table.concat(translated, "\n"))
		end
	end,
	OnCommand = function(self)
		self:smooth(0.5):diffusealpha(1):sleep(1):smooth(0.3):smooth(0.4):smooth(2):diffusealpha(0)
	end
	}
}
return t