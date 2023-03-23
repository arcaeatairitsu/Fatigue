local baseline = SCREEN_HEIGHT*0.385											
local meterheight = SCREEN_HEIGHT*0.725
local panelWidth = SCREEN_HEIGHT*0.22
local panelPos = 1	--   1 = right, -1 = left
local pm =  playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).PaceMaker
if pm == 0 then
	return
elseif pm == 1 then
	panelPos = -1
end
print(tostring(pm))
local notes = GAMESTATE:GetCurrentSteps(pn):GetRadarValues(pn):GetValue(0)
local progress = 0
local maxcombo = 0
local percent = 0
local passflag = 0
local target1 = 0
local target2 = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetGoal
local colour = {
	Current = color("#008dff"),
	Target1 = color("#00d20b"),
	Target2 =color("#ff8d7e")
}
local percent2grade = {
	{percent = 60, grade =  "C",color="#c97bff"},
	{percent = 70, grade =  "B",color="#5b78bb"},
	{percent = 80, grade =  "A",color="#da5757"},
	{percent = 93, grade = "AA", color="#66cc66"},
	{percent = 99.7, grade = "AAA",color="#eebb00"},
	{percent = 99.955, grade = "AAAA",color="#66ccff"},
	{percent = 99.9935, grade = "AAAAA",color="#ffffff"},
}

local rtTable
local rates
local rateIndex = 1
local score


local t = Def.ActorFrame{
	Name="PaceMaker",

	InitCommand=function(self)
		self:xy(SCREEN_CENTER_X+((SCREEN_WIDTH-panelWidth)/2*panelPos),SCREEN_CENTER_Y)
		rtTable = getRateTable()
		if rtTable ~= nil then
			rates, rateIndex = getUsedRates(rtTable)
			score = rtTable[rates[rateIndex]][1]
			target1 = score:GetWifeScore()*100
		end
		self:queuecommand("Display")
	end;
	JudgmentMessageCommand=function (self,msg)
	if msg.Judgment == "TapNoteScore_W1" or
		msg.Judgment == "TapNoteScore_W2" or
		msg.Judgment == "TapNoteScore_W3" or
		msg.Judgment == "TapNoteScore_W4" or
		msg.Judgment == "TapNoteScore_W5" or
		msg.Judgment == "TapNoteScore_Miss" then
		progress = progress + 1
		percent = msg.WifePercent
		self:playcommand("Update")
		if progress/notes*percent >= percent2grade[passflag+1].percent then
			for j = 1, #percent2grade do
				if progress/notes*percent>=percent2grade[j].percent then
					passflag = j
				end
			end
			self:playcommand("UpdateGrade")
		end
	end
	end;
	--base
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(panelWidth ,SCREEN_HEIGHT)
			self:diffuse(.05,.05,.05,0.8)
		end;
	},
	--current score meter
	Def.ActorFrame{
		InitCommand=function(self)
			self:xy(-0.33*panelWidth*panelPos,baseline)
		end;
		Def.Quad{
			InitCommand=function(self)
				self:align(0.5,1)
				self:zoomto(panelWidth*0.22,0)
				self:diffuse(colour.Current)
				self:diffusealpha(0.2)
			end;
			UpdateCommand=function (self,msg)
				if percent < 0 then
					self: zoomtoheight(0)
				else
					self:zoomtoheight(meterheight*percent/100)
				end
			end
		},
		Def.Quad{
			InitCommand=function(self)
				self:align(0.5,1)
				self:zoomto(panelWidth*0.22,0)
				self:diffuse(colour.Current)
				self:diffusealpha(0.75)
			end;
			UpdateCommand=function (self,msg)
				if percent < 0 then
					self: zoomtoheight(0)
				else
					self:zoomtoheight(meterheight*percent/100*progress/notes)
				end
			end
		},
	},

	--target 1
	Def.ActorFrame{
		InitCommand=function(self)
			self:xy(0,baseline)
		end;
		Def.Quad{
			InitCommand=function(self)
				self:align(0.5,1)
				self:zoomto(panelWidth*0.22,0)
				self:diffuse(colour.Target1):diffusealpha(0.2)
			end;
			DisplayCommand=function (self)
				self:decelerate(1.5):zoomtoheight(meterheight*target1/100)
			end;
		},
		Def.Quad{
			InitCommand=function(self)
				self:align(0.5,1)
				self:zoomto(panelWidth*0.22,0)
				self:diffuse(colour.Target1)
				self:diffusealpha(0.75)
			end;
			UpdateCommand=function (self)
				self:zoomtoheight(meterheight*target1/100):croptop(1-(progress/notes))
			end;
		},
		LoadFont("Common normal")..{
			DisplayCommand=function(self)
				self:align(0.5,1.1):zoom(SCREEN_HEIGHT/1370):y(-10)
				self:settext("Best")
				self:decelerate(1.5):y(-(meterheight-10)*target1/100-10)
				self:sleep(1):linear(0.5):diffusealpha(0)
			end,
		},
		LoadFont("Common normal")..{
			DisplayCommand=function(self)
				self:align(0.5,-0.1):zoom(SCREEN_HEIGHT/1370):y(-10)
				self:settextf("%2.2f",notes*target1/50):maxwidth(panelWidth*0.22/0.35)
				self:decelerate(1.5):y(-(meterheight-10)*target1/100-10)
				self:sleep(1):linear(0.5):diffusealpha(0)
			end,
		}
	},
	--target 2
	Def.ActorFrame{
		InitCommand=function(self)
			self:xy(0.33*panelWidth*panelPos,baseline)
		end;
		Def.Quad{
			InitCommand=function(self)
				self:align(0.5,1)
				self:zoomto(panelWidth*0.22,0)
				self:diffuse(colour.Target2):diffusealpha(0.2)
			end;
			DisplayCommand=function (self)
				self:decelerate(1.5):zoomtoheight(meterheight*target2/100)
			end;
		},
		Def.Quad{
			InitCommand=function(self)
				self:align(0.5,1)
				self:zoomto(panelWidth*0.22,0)
				self:diffuse(colour.Target2)
				self:diffusealpha(0.75)
			end;
			UpdateCommand=function (self)
				self:zoomtoheight(meterheight*target2/100):croptop(1-(progress/notes))
			end;
		},
		LoadFont("Common normal")..{
			DisplayCommand=function(self)
				self:align(0.5,1.1):zoom(SCREEN_HEIGHT/1370):y(-10)
				self:settext("Target"):maxwidth(panelWidth*0.22/0.35)
				self:decelerate(1.5):y(-(meterheight-10)*target2/100-10)
				self:sleep(1):linear(0.5):diffusealpha(0)
			end,
		},
		LoadFont("Common normal")..{
			DisplayCommand=function(self)
				self:align(0.5,-0.1):zoom(SCREEN_HEIGHT/1370):y(-10)
				self:settextf("%2.2f",notes*target2/50):maxwidth(panelWidth*0.22/0.35)
				self:decelerate(1.5):y(-(meterheight-10)*target2/100-10)
				self:sleep(1):linear(0.5):diffusealpha(0)
			end,
		}
	},
	--top text
	Def.ActorFrame{
		InitCommand=function(self)
			self:xy(-panelWidth*0.48,-SCREEN_HEIGHT*0.410)
		end,
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:align(0,1):zoom(SCREEN_HEIGHT/1200)
				self:settext("Timing Difficulty:"):y(-30)
				self:diffusealpha(0.5)
			end;
		};
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:align(0,1):zoom(SCREEN_HEIGHT/1200)
				self:settext("Life Difficulty:"):y(-16)
				self:diffusealpha(0.5)
			end;
		};
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:align(0,1):zoom(SCREEN_HEIGHT/1370)
				self:diffuse(colour.Current)
				self:settext(DLMAN:IsLoggedIn() and DLMAN:GetUsername() or PROFILEMAN:GetPlayerName(pn))
			end;
		};
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:align(0,1):zoom(SCREEN_HEIGHT/1370):y(10)
				self:settext("PS Best")
				self:diffuse(colour.Target1)
			end;
		};
		LoadFont("Common normal")..{
			DisplayCommand=function(self)
				self:align(0,1):zoom(SCREEN_HEIGHT/1370):y(20)
				self:settext("PS "..target2.."%")
				self:diffuse(colour.Target2)
			end;
		};
	};
	Def.ActorFrame{
		InitCommand=function(self)
			self:xy(panelWidth*0.48,-SCREEN_HEIGHT*0.410)
		end,
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:align(1,1):zoom(SCREEN_HEIGHT/1200)
				self:settext(GetTimingDifficulty()):y(-30)
				self:diffusealpha(0.5)
			end;
		};
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:align(1,1):zoom(SCREEN_HEIGHT/1200)
				self:settext(GetLifeDifficulty()):y(-16)
				self:diffusealpha(0.5)
			end;
		};
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:align(1,1):zoom(SCREEN_HEIGHT/1370)
				self:settextf("%2.2f",0)
			end;
			UpdateCommand=function (self,msg)
				self:settextf("%2.2f",progress*percent/50)
			end
		};
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:align(1,1):zoom(SCREEN_HEIGHT/1370):y(10)
				self:settextf("%2.2f",0)
			end;
			UpdateCommand=function (self,msg)
				self:settextf("%2.2f",progress*target1/50)
			end
		};
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:align(1,1):zoom(SCREEN_HEIGHT/1370):y(20)
				self:settextf("%2.2f",0)
			end;
			UpdateCommand=function (self,msg)
				self:settextf("%2.2f",progress*target2/50)
			end
		};
	};
	--bottom text
	Def.ActorFrame{
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:settext("Current Score")
				self:diffuse(colour.Current):zoom(SCREEN_HEIGHT/1200)
				self:y(baseline+(SCREEN_HEIGHT*0.02))
			end
		},
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:settext("Best Score")
				self:diffuse(colour.Target1):zoom(SCREEN_HEIGHT/1200)
				self:y(baseline+(SCREEN_HEIGHT*0.042))
			end
		},
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:settext("Target Score")
				self:diffuse(colour.Target2):zoom(SCREEN_HEIGHT/1200)
				self:y(baseline+(SCREEN_HEIGHT*0.064))
			end
		},
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(panelWidth,2):y(baseline):align(0.5,0)
				self:diffusealpha(0.3)
			end;
			UpdateCommand=function (self)
				if progress/notes*percent>0 then
					self:diffuse(color("#00adff66"))
				end
			end
		},
	},
}
for i = 1, 5 do
t[#t+1] = Def.ActorFrame{
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(panelWidth,SCREEN_HEIGHT/300):y(baseline-(meterheight*percent2grade[i].percent/100)):align(0.5,1)
			self:diffusealpha(0.3)
		end;
		UpdateGradeCommand=function (self)
			if passflag>=i then
				self:diffuse(color("#00adff66"))
			end
		end
	},
	LoadFont("Common normal") ..{
		InitCommand=function(self)
			self:xy(-panelWidth*0.5*panelPos,baseline-(meterheight*percent2grade[i].percent/100)-2):align((1-panelPos)/2,1):settext(percent2grade[i].grade):zoom(SCREEN_HEIGHT/1600)
			self:diffusealpha(0.3)
		end;
		UpdateGradeCommand=function (self)
			if passflag == i or i == 5 and passflag>5  then
				self:diffusealpha(0.5)
				self:settext(percent2grade[passflag].grade)
				self:diffuse(color(percent2grade[passflag].color))
			end
		end
	},
	LoadFont("Common normal") ..{
		InitCommand=function(self)
			self:xy(0,baseline-(meterheight*percent2grade[i].percent/100)-3):align(0.5,1):zoom(SCREEN_HEIGHT/960)
			self:diffusealpha(0)
		end;
		UpdateGradeCommand=function (self)
			if passflag == i or i == 5 and passflag>5  then
				self:stoptweening()
				self:settext("Rank "..percent2grade[passflag].grade.." Pass")
				self:diffusealpha(0):x(panelWidth*panelPos):linear(0.2):diffusealpha(1):x(0)
				self:sleep(1):linear(0.2):x(panelWidth*panelPos):diffusealpha(0)
			end
		end
	},--]]
}
end

return t