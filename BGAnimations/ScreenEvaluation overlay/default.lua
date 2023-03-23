local t = Def.ActorFrame {}
t[#t + 1] = LoadActor("../_frame")
t[#t + 1] = LoadActor("../_PlayerInfo.lua")	

translated_info = {
	Title = THEME:GetString("ScreenEvaluation", "Title"),
	Replay = THEME:GetString("ScreenEvaluation", "ReplayTitle")
}
--Group folder name
t[#t + 1] = LoadFont("Common Large") .. {
	InitCommand = function(self)
		self:xy(850,9):halign(1):zoom(0.28)
	end,
	BeginCommand = function(self)
		self:queuecommand("Set"):diffuse(getMainColor("positive"))
	end,
	SetCommand = function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song ~= nil then
			self:settext(song:GetGroupName())
		end
	end
}
t[#t + 1] = LoadActor("../_cursor")

return t
