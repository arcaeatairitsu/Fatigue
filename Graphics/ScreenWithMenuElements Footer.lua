local screenWithNoTips = {
	ScreenSelectMusic = true,
	ScreenGroupInfo = true,
	ScreenMusicInfo = true,
	ScreenPlayerProfile = true,
	ScreenNetEvaluation = true,
	ScreenNetSelectMusic = true,
	ScreenNetRoom = true,
	ScreenNetPlayerOptions = true,
	ScreenNetMusicInfo = true,
}

local t = Def.ActorFrame{}
local height = 20

t[#t+1] = quadButton(2) .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_HEIGHT)
		self:valign(1)
		self:zoomto(SCREEN_WIDTH,height)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end,
	OnCommand = function(self)
		self:zoomy(0)
		self:easeOut(0.5)
		self:zoomy(height)
	end,
	OffCommand = function(self)
		self:easeOut(0.5)
		self:zoomy(0)
	end
}
if themeConfig:get_data().global.TipType >= 2 then
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:xy(10,SCREEN_HEIGHT-10):zoom(0.4):maxwidth((SCREEN_WIDTH-160)/0.4):halign(0)
		end,
		OnCommand = function(self)
			self:diffuse(color(colorConfig:get_data().main.headerText))
			if not screenWithNoTips[SCREENMAN:GetTopScreen():GetName()] then
				self:settext(getRandomQuotes(themeConfig:get_data().global.TipType))
			end
			self:y(SCREEN_HEIGHT+height/2)
			self:easeOut(0.5)
			self:y(SCREEN_HEIGHT-height/2)
		end,
		OffCommand = function(self)
			self:easeOut(0.5)
			self:y(SCREEN_HEIGHT+height/2)
		end
	}
end

return t