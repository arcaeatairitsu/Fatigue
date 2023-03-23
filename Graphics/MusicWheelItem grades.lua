return Def.ActorFrame{
	LoadFont("Common Bold") .. {
		InitCommand=function(self)
			self:xy(13,10):zoom(0.5):maxwidth(WideScale(get43size(20),20)/0.5)
		end,
		SetGradeCommand=function(self,params)
			local player = params.PlayerNumber
				local song = params.Song
				local sGrade = params.Grade or 'Grade_None'
				self:valign(0.5)
				self:settext(THEME:GetString("Grade",ToEnumShortString(sGrade)) or "")
				self:diffuse(getGradeColor(sGrade))
		end
	},


	},	
LoadActor("mirror") .. {
		InitCommand = function(self)
			self:xy(-7,11)
			self:zoom(0.3)
			self:diffuse(color("#888888"))
		end,
		SetGradeCommand = function(self,params)
			self:visible(false)
			if params.PermaMirror then
				self:visible(true)
			end
		end
	}