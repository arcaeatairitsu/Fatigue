local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)

local user = playerConfig:get_data(pn_to_profile_slot(pn)).Username
local pass = playerConfig:get_data(pn_to_profile_slot(pn)).Password
if isAutoLogin() then
	DLMAN:LoginWithToken(user, pass)
end


local screenChoices = {
	ScreenNetSelectMusic = true,
	ScreenSelectMusic = true,
}

local replayScore
local isEval

local t = Def.ActorFrame{
	LoginFailedMessageCommand = function(self)
		SCREENMAN:SystemMessage("Login Failed!")
	end,

	LoginMessageCommand=function(self)
		SCREENMAN:SystemMessage("Login Successful!")
		GHETTOGAMESTATE:setOnlineStatus("Online")
	end,

	LogOutMessageCommand=function(self)
		SCREENMAN:SystemMessage("Logged Out!")
		GHETTOGAMESTATE:setOnlineStatus("Local")
	end,

	TriggerReplayBeginMessageCommand = function(self, params)
		replayScore = params.score
		isEval = params.isEval
		self:sleep(0.1)
		self:queuecommand("DelayedReplayBegin")
	end,

	DelayedReplayBeginCommand = function(self)
		if isEval then
			SCREENMAN:GetTopScreen():ShowEvalScreenForScore(replayScore)
		else
			SCREENMAN:GetTopScreen():PlayReplay(replayScore)
		end
	end,
	CurrentSongChangedMessageCommand = function(self)
		if profile:IsCurrentChartPermamirror() then
			local modslevel = "ModsLevel_Preferred"
			local playeroptions = GAMESTATE:GetPlayerState():GetPlayerOptions(modslevel)
			playeroptions:Mirror(false)
		end
	end,

	PlayingSampleMusicMessageCommand = function(self)
		local leaderboardEnabled =
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).leaderboardEnabled and DLMAN:IsLoggedIn()
		if leaderboardEnabled and GAMESTATE:GetCurrentSteps() then
			local chartkey = GAMESTATE:GetCurrentSteps():GetChartKey()
			if screenChoices[SCREENMAN:GetTopScreen():GetName()] then
				if SCREENMAN:GetTopScreen():GetMusicWheel():IsSettled() then
					DLMAN:RequestChartLeaderBoardFromOnline(
						chartkey,
						function(leaderboard)
						end
					)
				end
			end
		end
	end
}


t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:y(SCREEN_HEIGHT):halign(0):valign(1):zoomto(SCREEN_WIDTH,200):diffuse(getMainColor("background")):fadetop(1)
	end
}




t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("tabs")
t[#t+1] = LoadActor("currentsort")
t[#t+1] = LoadActor("profilecard")
t[#t+1] = LoadActor("songinfo")
t[#t+1] = StandardDecorationFromFileOptional("BPMDisplay","BPMDisplay")
t[#t+1] = StandardDecorationFromFileOptional("BPMLabel","BPMLabel")
t[#t+1] = LoadActor("../_cursor")
t[#t+1] = LoadActor("bgm")


t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:rotationz(-90):xy(SCREEN_CENTER_X/2-WideScale(get43size(150),150),270)
		self:delayedFadeIn(5)
	end,
	OffCommand=function(self)
		self:stoptweening()
		self:sleep(0.025)
		self:smooth(0.2)
		self:diffusealpha(0) 
	end,

	OnCommand=function(self)
		wheel = SCREENMAN:GetTopScreen():GetMusicWheel()
	end,
	CurrentSongChangedMessageCommand=function(self)
		self:playcommand("PositionSet")
	end,
	Def.StepsDisplayList {
		Name="StepsDisplayListRow",
		CursorP1 = Def.ActorFrame {
			InitCommand=function(self)
				self:player(PLAYER_1):rotationz(90):diffusealpha(0.6)
			end,
			PlayerJoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_1 then
					self:visible(true)
					self:zoom(0):bounceend(1):zoom(1)
				end
			end,
			PlayerUnjoinedMessageCommand=function(self, params)
				if params.Player == PLAYER_1 then
					self:visible(true)
					self:zoom(0):bounceend(1):zoom(1)
				end
			end,
			Def.Quad{
				InitCommand=function(self)
					self:zoomto(65,65):diffuseshift():effectperiod(1):effectcolor1(Alpha(PlayerColor(PLAYER_1), 0.5)):effectcolor2(PlayerColor(PLAYER_1))
				end
			}
		},
		CursorP2 = Def.ActorFrame {
		},
		CursorP1Frame = Def.Actor{
			ChangeCommand=function(self)
				self:stoptweening():easeOut(0.5)
			end
		},
		CursorP2Frame = Def.Actor{
		}
	}
}

local largeImageText = string.format("%s: %5.2f",profile:GetDisplayName(), profile:GetPlayerRating())
GAMESTATE:UpdateDiscordMenu(largeImageText)

return t