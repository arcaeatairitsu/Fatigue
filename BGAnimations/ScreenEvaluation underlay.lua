local enabled = PREFSMAN:GetPreference("ShowBackgrounds")
local brightness = 0.4
local bgType = themeConfig:get_data().eval.SongBGType -- 1 = disabled, 2 = songbg, 3 = playerbg
local enabled = themeConfig:get_data().global.SongBGEnabled
local moveBG = themeConfig:get_data().global.SongBGMouseEnabled and enabled
local t = Def.ActorFrame {}

if enabled then
	t[#t + 1] = Def.Sprite {
		OnCommand = function(self)
			if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSong():GetBackgroundPath() then
				self:finishtweening()
				self:visible(true)
				self:LoadBackground(GAMESTATE:GetCurrentSong():GetBackgroundPath())
				self:scaletocover(0, 0, SCREEN_WIDTH, SCREEN_BOTTOM)
				self:sleep(0.5)
				self:decelerate(2)
				self:diffusealpha(0.3)
			else
				self:visible(false)
			end
		end
	}
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
