local t = Def.ActorFrame{
	InitCommand = function(self)
		self:diffusealpha(0)
		self:diffuse(getMainColor("negative"))
	end,
	OffCommand = function(self)
		self:smooth(1)
		self:diffusealpha(1)
		self:sleep(1)
	end
}

t[#t+1] = LoadActor("_background")

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:diffusealpha(0)
		self:Center()
		self:zoomto(200,50)
		self:smooth(1)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)
	end,
	OffCommand = function(self)
		self:sleep(1)
		self:smooth(1)
		self:diffusealpha(0)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:settext("Stage Failed\nPress \"`\" to retry.")
		self:Center()
		self:zoom(0.5)
		self:diffusealpha(0)
		self:smooth(1)
		self:diffusealpha(0.8)
		self:diffuseshift()
		self:effectcolor1(color("#FFFFFF")):effectcolor2(getMainColor("negative"))
	end,
	OffCommand = function(self)
		self:sleep(1)
		self:smooth(1)
		self:diffusealpha(0)
	end
}

return t