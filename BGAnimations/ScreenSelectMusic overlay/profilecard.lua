local t = Def.ActorFrame{
	InitCommand = function(self) 
		self:delayedFadeIn(6)

		-- auto login
		local user = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).Username
		local passToken = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).Password
		if passToken ~= "" and answer ~= "" then
			if not DLMAN:IsLoggedIn() then
				DLMAN:LoginWithToken(user, passToken)
			end
		end
		
	end,
	OffCommand = function(self)
		self:sleep(0.05)
		self:smooth(0.2)
		self:diffusealpha(0) 
	end
}

local frameX = SCREEN_CENTER_X/2
local frameY = SCREEN_CENTER_Y+100
local frameWidth = capWideScale(get43size(390),390)
local frameHeight = 110
local frameHeightShort = 61
local song
local course
local ctags = {}
local filterTags = {}

local function wheelSearch()
	local search = GHETTOGAMESTATE:getMusicSearch()
	GHETTOGAMESTATE:getSSM():GetMusicWheel():SongSearch(search)
end

local function updateTagFilter(tag)
	local ptags = tags:get_data().playerTags
	local charts = {}

	local playertags = {}
	for k,v in pairs(ptags) do
		playertags[#playertags+1] = k
	end

	local filterTags = tag
	if filterTags then
		local toFilterTags = {}
		toFilterTags[1] = filterTags
		local inCharts = {}

		for k, v in pairs(ptags[toFilterTags[1]]) do
			inCharts[k] = 1
		end
		toFilterTags[1] = nil
		for k, v in pairs(toFilterTags) do
			for key, val in pairs(inCharts) do
				if ptags[v][key] == nil then
					inCharts[key] = nil
				end
			end
		end
		for k, v in pairs(inCharts) do
			charts[#charts + 1] = k
		end
	end
	local out = {}
	if tag ~= nil then out[tag] = 1	end
	GHETTOGAMESTATE:setFilterTags(out)
	GHETTOGAMESTATE:getSSM():GetMusicWheel():FilterByStepKeys(charts)
	wheelSearch()
end

local steps = {
	PlayerNumber_P1
}

local trail = {
	PlayerNumber_P1
}

local profile = {
	PlayerNumber_P1
}

local topScore = {
	PlayerNumber_P1
}

local hsTable = {
	PlayerNumber_P1
}

local function generalFrame(pn)
	local t = Def.ActorFrame{
		BeginCommand = function(self)
			self:xy(frameX,frameY)
			self:visible(GAMESTATE:IsPlayerEnabled())
			self:playcommand("UpdateInfo")
		end,

		UpdateInfoCommand = function(self)
			song = GAMESTATE:GetCurrentSong()
			
			for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
				profile[pn] = GetPlayerOrMachineProfile(pn)
				steps[pn] = GAMESTATE:GetCurrentSteps()
				topScore[pn] = getBestScore(pn, 0, getCurRate())
				if song and steps[pn] then
					ptags = tags:get_data().playerTags
					chartkey = steps[pn]:GetChartKey()
					ctags = {}
					for k,v in pairs(ptags) do
						if ptags[k][chartkey] then
							ctags[#ctags + 1] = k
						end
					end
				end
			end
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end,

		PlayerJoinedMessageCommand = function(self) self:playcommand("UpdateInfo") end,
		PlayerUnjoinedMessageCommand = function(self) self:playcommand("UpdateInfo") end,
		CurrentStepsChangedMessageCommand = function(self) self:playcommand("UpdateInfo") end,
		CurrentRateChangedMessageCommand = function(self) self:playcommand("UpdateInfo") end
	}

	--Upper Bar
	t[#t+1] = quadButton(2) .. {
		InitCommand = function(self)
			self:zoomto(frameWidth,frameHeight)
			self:valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end
	}

	if not IsUsingWideScreen() then
		t[#t+1] = Def.Quad {
			InitCommand = function(self)
				self:halign(0):valign(0)
				self:xy(frameX-14,frameHeight/2)
				self:zoomto(65,frameHeight/2)
				self:diffuse(getMainColor("frame"))
				self:diffusealpha(0.8)
			end
		}
	end


	t[#t+1] = quadButton(3) .. {
		InitCommand = function(self)
			self:xy(15+10-(frameWidth/2),18)
			self:zoomto(30,30)
			self:visible(false)
		end,
		MouseDownCommand = function(self, params)
			if params.button == "DeviceButton_left mouse button" then
				SCREENMAN:AddNewScreenToTop("ScreenPlayerProfile")
			end
		end
	}

	-- Avatar
	t[#t+1] = Def.Sprite {
		InitCommand = function (self) self:xy(15+10-(frameWidth/2),18):playcommand("ModifyAvatar") end,
		PlayerJoinedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end,
		PlayerUnjoinedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end,
		AvatarChangedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end,
		ModifyAvatarCommand = function(self)
			self:visible(true)
			self:Load(getAvatarPath(PLAYER_1))
			self:zoomto(30,30)
		end
	}

	-- Player name
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(43-frameWidth/2,9)
			self:zoom(0.6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local text = ""
			if profile[pn] ~= nil then
				text = getCurrentUsername(pn)
				if text == "" then
					text = pn == PLAYER_1 and "Player 1" or "Player 2"
				end
			end
			self:settext(text)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end,
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end,
		LoginMessageCommand = function(self) self:queuecommand('Set') end,
		LogOutMessageCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(43-frameWidth/2,20)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local rating = 0
			local rank = 0
			local localrating = 0

			if DLMAN:IsLoggedIn() then
				rank = DLMAN:GetSkillsetRank("Overall")
				rating = DLMAN:GetSkillsetRating("Overall")
				localrating = profile[pn]:GetPlayerRating()

				self:settextf("Skill Rating: %0.2f  (%0.2f #%d Online)", localrating, rating, rank)
				self:AddAttribute(#"Skill Rating:", {Length = 7, Zoom =0.3 ,Diffuse = getMSDColor(localrating)})
				self:AddAttribute(#"Skill Rating: 00.00  ", {Length = -1, Zoom =0.3 ,Diffuse = getMSDColor(rating)})
			else
				if profile[pn] ~= nil then
					localrating = profile[pn]:GetPlayerRating()
					self:settextf("Skill Rating: %0.2f",localrating)
					self:AddAttribute(#"Skill Rating:", {Length = -1, Zoom =0.3 ,Diffuse = getMSDColor(localrating)})
				end

			end

		end,
		BeginCommand = function(self) self:queuecommand('Set') end,
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end,
		LoginMessageCommand = function(self) self:queuecommand('Set') end,
		LogOutMessageCommand = function(self) self:queuecommand('Set') end,
		OnlineUpdateMessageCommand = function(self) self:queuecommand('Set') end
	}

	-- Level and exp
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(43-frameWidth/2,29)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			if profile[pn] ~= nil then
				local level = getLevel(getProfileExp(pn))
				local currentExp = getProfileExp(pn) - getLvExp(level)
				local nextExp = getNextLvExp(level)
				self:settextf("Lv.%d (%d/%d)",level, currentExp, nextExp)
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end,
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end
	}

	--Score Date
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-3,-10)
			self:zoom(0.35)
		    self:halign(1):valign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText)):diffusealpha(0.5)
		end,
		SetCommand = function(self)
			if getScoreDate(topScore[pn]) == "" then
				self:settext("Never played, maybe check other rates?")
			else
				self:settext("Date Achieved: "..getScoreDate(topScore[pn]))
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	-- Steps info
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(5-frameWidth/2,-35)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local diff,stype
			local notes,holds,rolls,mines,lifts = 0
			local difftext = ""

			if steps[pn] ~= nil then
				notes = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Notes")
				holds = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Holds")
				rolls = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Rolls")
				mines = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Mines")
				lifts = steps[pn]:GetRadarValues(pn):GetValue("RadarCategory_Lifts")
				diff = steps[pn]:GetDifficulty()

			

				stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
				self:settextf("Notes:%s\nHolds:%s\nRolls:%s\nMines:%s\nLifts:%s",notes,holds,rolls,mines,lifts)
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="Steps",
		InitCommand = function(self)
			self:xy(190,10)
			self:zoom(0.65)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand= function(self)
			if steps[pn] ~= nil then

			local diff = steps[pn]:GetDifficulty()
			local stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
			local difftext
			if diff == 'Difficulty_Edit' then
				difftext = steps[pn]:GetDescription()
				difftext = difftext == '' and getDifficulty(diff) or difftext
			else
				difftext = getDifficulty(diff)
				self:settextf("%s %s",stype,difftext)
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[pn]:GetStepsType(),steps[pn]:GetDifficulty())))
			end
		end
	end
}
	t[#t+1] = LoadFont("Common Normal")..{
		Name="Meter",
		InitCommand = function(self)
			self:xy(-145,-80)
			self:zoom(1.2):maxwidth(85)
			self:halign(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			if steps[pn] ~= nil then


				local meter = steps[pn]:GetMSD(getCurRateValue(),1)
				if meter == 0 then
					meter = steps[pn]:GetMeter()
				end
				meter = math.max(0,meter)
					self:settextf("%05.2f",meter)
					self:diffuse(getMSDColor(meter))

			else
				self:settext("")
			end
		end,

	}



	t[#t+1] = LoadFont("Common Normal")..{
		Name="MSDAvailability",
		InitCommand = function(self)
			self:xy(-147,-94)
			self:zoom(0.3)
			self:halign(0.5)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			if steps[pn] ~= nil then

				local meter = math.floor(steps[pn]:GetMSD(getCurRateValue(),1))
				if meter == 0 then
					self:settext("Default")
					self:diffuse(color(colorConfig:get_data().main.disabled))
				else
					self:settext("MSD")
					self:diffuse(color(colorConfig:get_data().main.enabled))
				end
			else
				self:settext("")
			end
		end
	}

	-- Stepstype and Difficulty meter
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth-10-frameWidth/2-2,50)
			self:zoom(0.3)
		end,
		SetCommand = function(self)
			if steps[pn] ~= nil then
				local diff = getDifficulty(steps[pn]:GetDifficulty())
				local stype = ToEnumShortString(steps[pn]:GetStepsType()):gsub("%_"," ")
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[pn]:GetStepsType(),steps[pn]:GetDifficulty())))
			end
		end
	}


	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth/2-8,40)
			self:settext("Negative BPMs\n Instant invalidation")
			self:zoom(0.4)
			self:halign(1)
			self:visible(false)
		end,
		SetCommand = function(self)
			if song and steps and steps[pn] then
				if steps[pn]:GetTimingData():HasWarps() then
					self:visible(true)
					return
				end
			end
			self:visible(false)
		end
	}

	--Grades
	t[#t+1] = LoadFont("Common BLarge")..{
		InitCommand = function(self)
			self:xy(32,-83):halign(0)
			self:zoom(0.6)
		    self:maxwidth(70/0.6)
		end,
		SetCommand = function(self)
			local grade = 'Grade_None'
			if topScore[pn] ~= nil then
				grade = topScore[pn]:GetWifeGrade()
			end
			self:settext(THEME:GetString("Grade",ToEnumShortString(grade)))
			self:diffuse(getGradeColor(grade))
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	--ClearType
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand = function(self)
			self:xy(32,-65):halign(0)
			self:zoom(0.4)
			self:maxwidth(110/0.4)
		end,
		SetCommand = function(self)
			self:stoptweening()

			local scoreList
			local clearType = getClearType(pn,steps,curScore)
			if profile[pn] ~= nil and song ~= nil and steps[pn] ~= nil then
				scoreList = getScoreTable(pn, getCurRate())
				clearType = getHighestClearType(pn,steps[pn],scoreList,0)
				self:settext(getClearTypeText(clearType))
				self:diffuse(getClearTypeColor(clearType))
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	-- Percentage Score
	t[#t+1] = LoadFont("Common BLarge")..{
		InitCommand= function(self)
			self:xy(194,frameHeight-189)
			self:zoom(0.35):halign(1):maxwidth(100/0.45)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local scorevalue = 0
			if topScore[pn] ~= nil then
				scorevalue = getScore(topScore[pn], steps[pn], true)
			end
			self:settextf("%.4f%%",math.floor((scorevalue)*1000000)/10000)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}


	--Player DP/Exscore / Max DP/Exscore
	t[#t+1] = LoadFont("Common Normal")..{
		Name = "score", 
		InitCommand= function(self)
			self:xy(180,-66)
			self:zoom(0.4):halign(0.5)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self) 
			self:settext(getMaxScore(pn,0))
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(175,-66)
			self:zoom(0.4):halign(0.75)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self) 
			self:x(self:GetParent():GetChild("score"):GetX()-(math.min(self:GetParent():GetChild("score"):GetWidth(),27/0.5)*0.5))

			local scoreValue = 0
			if topScore[pn] ~= nil then
				scoreValue = getScore(topScore[pn], steps[pn], false)
			end
			self:settextf("%.0f/",scoreValue)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	--ScoreType superscript(?)
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(172,-56)
			self:zoom(0.3)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		BeginCommand = function(self) self:queuecommand("Set") end,
		SetCommand = function(self)
			local version = 3
			if topScore[pn] ~= nil then
				version = topScore[pn]:GetWifeVers()
			end
			self:settextf("Wife%d", version)
		end
	}

	--MaxCombo
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(31,-47)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local score = getBestMaxCombo(pn,0, getCurRate())
			local maxCombo = 0
			maxCombo = getScoreMaxCombo(score)
			self:settextf("Max Combo: %d",maxCombo)
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}
	--TapNoteScore
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(32,-22)
			self:zoom(0.4):halign(0):maxwidth(400)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local displayScore = GetDisplayScore()
			local jgMaStr = tostring(displayScore:GetTapNoteScore("TapNoteScore_W1"))
			local jgPStr = tostring(displayScore:GetTapNoteScore("TapNoteScore_W2"))
			local jgGrStr = tostring(displayScore:GetTapNoteScore("TapNoteScore_W3"))
			local jgGoStr = tostring(displayScore:GetTapNoteScore("TapNoteScore_W4"))
			local jgBStr = tostring(displayScore:GetTapNoteScore("TapNoteScore_W5"))
			local jgMiStr = tostring(displayScore:GetTapNoteScore("TapNoteScore_Miss"))
		self:settextf("%s / %s / %s / %s / %s / %s", jgMaStr, jgPStr, jgGrStr, jgGoStr, jgBStr, jgMiStr)
	end
	}

	--MissCount
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(31,-35)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end,
		SetCommand = function(self)
			local score = getBestMissCount(pn, 0, getCurRate())
			if score ~= nil then
				self:settext("CB: "..getScoreComboBreaks(score))
			else
				self:settext("CB: -?-")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}


	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3,0)
			self:valign(1)
			self:halign(1)
			self:zoomto((frameWidth-75)/3,16)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0)
		end,
		SetCommand = function(self)
			if song and ctags[3] then
				if ctags[3] == GHETTOGAMESTATE.SSMTag then
					self:diffusealpha(0.6)
				else
					self:diffusealpha(0.8)
				end
			else
				self:diffusealpha(0)
			end
		end,
		BeginCommand = function(self) self:queuecommand("Set") end,
		MouseDownCommand = function(self, params)
			if song and ctags[3] then
				if ctags[3] == GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_right mouse button" then
					GHETTOGAMESTATE.SSMTag = nil
					self:linear(0.1):diffusealpha(0.8)
					updateTagFilter(nil)
				elseif ctags[3] ~= GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_left mouse button" then
					GHETTOGAMESTATE.SSMTag = ctags[3]
					self:linear(0.1):diffusealpha(0.6)
					updateTagFilter(ctags[3])
				end
			end
		end
		
	}
	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/3 - 2,0)
			self:valign(1)
			self:halign(1)
			self:zoomto((frameWidth-75)/3,16)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0)
		end,
		SetCommand = function(self)
			if song and ctags[2] then
				if ctags[2] == GHETTOGAMESTATE.SSMTag then
					self:diffusealpha(0.6)
				else
					self:diffusealpha(0.8)
				end
			else
				self:diffusealpha(0)
			end
		end,
		BeginCommand = function(self) self:queuecommand("Set") end,
		MouseDownCommand = function(self, params)
			if song and ctags[2] then
				if ctags[2] == GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_right mouse button" then
					GHETTOGAMESTATE.SSMTag = nil
					self:linear(0.1):diffusealpha(0.8)
					updateTagFilter(nil)
				elseif ctags[2] ~= GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_left mouse button" then
					GHETTOGAMESTATE.SSMTag = ctags[2]
					self:linear(0.1):diffusealpha(0.6)
					updateTagFilter(ctags[2])
				end
			end
		end
		
	}
	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/3*2 - 4,0)
			self:valign(1)
			self:halign(1)
			self:zoomto((frameWidth-75)/3,16)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0)
		end,
		SetCommand = function(self)
			if song and ctags[1] then
				if ctags[1] == GHETTOGAMESTATE.SSMTag then
					self:diffusealpha(0.6)
				else
					self:diffusealpha(0.8)
				end
			else
				self:diffusealpha(0)
			end
		end,
		BeginCommand = function(self) self:queuecommand("Set") end,
		MouseDownCommand = function(self, params)
			if song and ctags[1] then
				if ctags[1] == GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_right mouse button" then
					GHETTOGAMESTATE.SSMTag = nil
					self:linear(0.1):diffusealpha(0.8)
					updateTagFilter(nil)
				elseif ctags[1] ~= GHETTOGAMESTATE.SSMTag and params.button == "DeviceButton_left mouse button" then
					GHETTOGAMESTATE.SSMTag = ctags[1]
					self:linear(0.1):diffusealpha(0.6)
					updateTagFilter(ctags[1])
				end
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-96,-36)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(200)
		end,
		SetCommand = function(self)
			if song and steps[pn] then
				self:settext(steps[pn]:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 1))
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-96,-24)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(200)
		end,
		SetCommand = function(self)
			if song and steps[pn] then
				self:settext(steps[pn]:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 2))
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-96,-10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(200)
		end,
		SetCommand = function(self)
			if song and steps[pn] then
				self:settext(steps[pn]:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 3))
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/3*2 - 4 - (frameWidth-75)/6, -8)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(((frameWidth-75)/3-capWideScale(5,10))/0.4)
		end,
		SetCommand = function(self)
			if song and ctags[1] then
				self:settext(ctags[1])
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/3 - 2 - (frameWidth-75)/6, -8)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(((frameWidth-75)/3-capWideScale(5,10))/0.4)
		end,
		SetCommand = function(self)
			if song and ctags[2] then
				self:settext(ctags[2])
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(capWideScale(68,85) + (frameWidth-75)/3 - (frameWidth-75)/6, -8)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
			self:maxwidth(((frameWidth-75)/3-capWideScale(5,10))/0.4)
		end,
		SetCommand = function(self)
			if song and ctags[3] then
				self:settext(ctags[3])
			else
				self:settext("")
			end
		end,
		BeginCommand = function(self) self:queuecommand('Set') end
	}

	return t
end


t[#t+1] = Def.Quad {
	InitCommand = function(self)
		self:halign(0):valign(0)
		self:xy(19,240)
		self:zoomto(100,100)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)
	end
}

t[#t+1] = Def.Quad {
	InitCommand = function(self)
		self:halign(0):valign(0)
		self:xy(119,290)
		self:zoomto(55,50)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)
	end
}

t[#t+1] = Def.Quad {
	InitCommand = function(self)
		self:halign(0):valign(0)
		self:xy(240,240)
		self:zoomto(168,100)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)
	end
}

t[#t+1] = generalFrame(PLAYER_1)

return t