-- StepMania 5 Default Theme Preferences Handler
local function OptionNameString(str)
	return THEME:GetString('OptionNames',str)
end

		--[[ option rows ]]
			
			-- screen filter
			function OptionRowScreenFilter()
				return {
					Name="ScreenFilter",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = { THEME:GetString('OptionNames','Off'), '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1.0', },
					LoadSelections = function(self, list, pn)
						local pName = ToEnumShortString(pn)
						local filterValue = playerConfig:get_data(pn_to_profile_slot(pn)).ScreenFilter
						local value = scale(filterValue,0,1,1,#list )
						list[value] = true
					end,
					SaveSelections = function(self, list, pn)
						local pName = ToEnumShortString(pn)
						local found = false
						local value = 0
						for i=1,#list do
							if not found then
								if list[i] == true then
									value = scale(i,1,#list,0,1)
									found = true
								end
							end
						end
						playerConfig:get_data(pn_to_profile_slot(pn)).ScreenFilter = value
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end,
				}
			end
			
			function JudgeType()
				local t = {
					Name = "JudgeType",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = { THEME:GetString('OptionNames','Off'),'No Highlights','On'},
					LoadSelections = function(self, list, pn)
						local prefs = playerConfig:get_data(pn_to_profile_slot(pn)).JudgeType
						list[prefs+1] = true
					end,
					SaveSelections = function(self, list, pn)
						local value
						if list[3] then
							value = 2
						elseif list[2] then
							value = 1
						else
							value = 0
						end
						playerConfig:get_data(pn_to_profile_slot(pn)).JudgeType = value
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable( t, t )
				return t
			end	
			
			
			function TargetTracker()
				local t = {
					Name = "TargetTracker",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = {THEME:GetString("OptionNames", "Off"), THEME:GetString("OptionNames", "On")},
					LoadSelections = function(self, list, pn)
						local pref = playerConfig:get_data(pn_to_profile_slot(pn)).TargetTracker
						if pref then
							list[2] = true
						else
							list[1] = true
						end
					end,
					SaveSelections = function(self, list, pn)
						local value
						value = list[2]
						playerConfig:get_data(pn_to_profile_slot(pn)).TargetTracker = value
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable(t, t)
				return t
			end
			
			local tChoices = {}
			for i = 0, 96 do
				tChoices[i] = tostring(i) .. "%"
			end
			local tChoices2 = {
				"96.50%", -- AA.
				"97.00%",
				"97.50%",
				"98.00%",
				"98.50%",
				"99.00%", -- AA:
				"99.50%",
				"99.60%",
				"99.70%", -- AAA
				"99.75%", -- Prenerf AAA
				"99.80%", -- AAA.
				"99.85%", -- Prenerf AAA.
				"99.90%", -- AAA:
				"99.92%", -- prenerf AAA:
				"99.955%", -- AAAA
				"99.97%", -- AAAA.
				"99.98%", -- AAAA:
				"99.99%", -- prenerf AAAA:
				"99.9935%", -- AAAAA
				"99.995%", -- might need this
				"99.999%", -- prenerf AAAAA
				"100%" -- X rank confirmed????
			}
			for _,v in ipairs(tChoices2) do
				tChoices[#tChoices+1] = v
			end
			function TargetGoal()
				local t = {
					Name = "TargetGoal",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = tChoices,
					LoadSelections = function(self, list, pn)
						local prefsval = playerConfig:get_data(pn_to_profile_slot(pn)).TargetGoal
						local index = IndexOf(tChoices, prefsval .. "%")
						list[index] = true
					end,
					SaveSelections = function(self, list, pn)
						local found = false
						for i = 1, #list do
							if not found then
								if list[i] == true then
									local value = i
									playerConfig:get_data(pn_to_profile_slot(pn)).TargetGoal =
										tonumber(string.sub(tChoices[value], 1, #tChoices[value] - 1))
									found = true
								end
							end
						end
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable(t, t)
				return t
			end
			
			function TargetTrackerMode()
				local t = {
					Name = "TargetTrackerMode",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = {THEME:GetString("OptionNames", "SetPercent"), THEME:GetString("OptionNames", "PersonalBest")},
					LoadSelections = function(self, list, pn)
						local pref = playerConfig:get_data(pn_to_profile_slot(pn)).TargetTrackerMode
						list[pref + 1] = true
					end,
					SaveSelections = function(self, list, pn)
						local value
						if list[2] then
							value = 1
						else
							value = 0
						end
						playerConfig:get_data(pn_to_profile_slot(pn)).TargetTrackerMode = value
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable(t, t)
				return t
			end
			
			function ErrorBar()
				local t = {
					Name = "ErrorBar",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = {THEME:GetString("OptionNames", "Off"), THEME:GetString("OptionNames", "On"), THEME:GetString("OptionNames", "EWMA")},
					LoadSelections = function(self, list, pn)
						local pref = playerConfig:get_data(pn_to_profile_slot(pn)).ErrorBar
						list[pref + 1] = true
					end,
					SaveSelections = function(self, list, pn)
						local value
						if list[1] == true then
							value = 0
						elseif list[2] == true then
							value = 1
						else
							value = 2
						end
						playerConfig:get_data(pn_to_profile_slot(pn)).ErrorBar = value
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable(t, t)
				return t
			end
			
			function PaceMaker()
				local t = {
					Name = "PaceMaker",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = { THEME:GetString('OptionNames','Off'),'On'},
					LoadSelections = function(self, list, pn)
						local pref = playerConfig:get_data(pn_to_profile_slot(pn)).PaceMaker
						if pref then
							list[2] = true
						else
							list[1] = true
						end
					end,
					SaveSelections = function(self, list, pn)
						local value
						value = list[2]
						playerConfig:get_data(pn_to_profile_slot(pn)).PaceMaker = value
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable( t, t )
				return t
			end	
			
			function LaneCover()
				local t = {
					Name = "LaneCover",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = { THEME:GetString('OptionNames','Off'),'Sudden','Hidden'},
					LoadSelections = function(self, list, pn)
						local pref = playerConfig:get_data(pn_to_profile_slot(pn)).LaneCover
						list[pref+1] = true
					end,
					SaveSelections = function(self, list, pn)
						local value
						if list[1] == true then
							value = 0
						elseif list[2] == true then
							value = 1
						else
							value = 2
						end
						playerConfig:get_data(pn_to_profile_slot(pn)).LaneCover = value
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable( t, t )
				return t
			end	
			
			function NPSDisplay()
				local t = {
					Name = "NPSDisplay",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectMultiple",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = {"NPS Display","NPS Graph"},
					LoadSelections = function(self, list, pn)
						local npsDisplay = playerConfig:get_data(pn_to_profile_slot(pn)).NPSDisplay
						local npsGraph = playerConfig:get_data(pn_to_profile_slot(pn)).NPSGraph
						if npsDisplay then
							list[1] = true
						end
						if npsGraph then 
							list[2] = true
						end
					end,
					SaveSelections = function(self, list, pn)
						playerConfig:get_data(pn_to_profile_slot(pn)).NPSDisplay = list[1]
						playerConfig:get_data(pn_to_profile_slot(pn)).NPSGraph = list[2]
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable( t, t )
				return t
			end
			
			function CBHighlight()
				local t = {
					Name = "CBHighlight",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = { THEME:GetString('OptionNames','Off'),'On'},
					LoadSelections = function(self, list, pn)
						local pref = playerConfig:get_data(pn_to_profile_slot(pn)).CBHighlight
						if pref then
							list[2] = true
						else
							list[1] = true
						end
					end,
					SaveSelections = function(self, list, pn)
						local value
						value = list[2]
						playerConfig:get_data(pn_to_profile_slot(pn)).CBHighlight = value
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable( t, t )
				return t
			end

			function LeaderBoard()
				local t = {
					Name = "Leaderboard",
					LayoutType = "ShowAllInRow",
					SelectType = "SelectOne",
					OneChoiceForAllPlayers = false,
					ExportOnChange = true,
					Choices = {THEME:GetString("OptionNames", "Off"), THEME:GetString("OptionNames", "On")},
					LoadSelections = function(self, list, pn)
						local pref = playerConfig:get_data(pn_to_profile_slot(pn)).leaderboardEnabled
						if pref then
							list[2] = true
						else
							list[1] = true
						end
					end,
					SaveSelections = function(self, list, pn)
						local value
						value = list[2]
						playerConfig:get_data(pn_to_profile_slot(pn)).leaderboardEnabled = value
						playerConfig:set_dirty(pn_to_profile_slot(pn))
						playerConfig:save(pn_to_profile_slot(pn))
					end
				}
				setmetatable(t, t)
				return t
			end
			
			--===============================================
			--Globals

function DefaultScoreType()
	local t = {
		Name = "DefaultScoreType",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "DP","PS","MIGS"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.DefaultScoreType
			if pref == 1 then
				list[1] = true
			elseif pref == 2 then
				list[2] = true
			else 
				list[3] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] == true then
				value = 1
			elseif list[2] == true then
				value = 2
			else
				value = 3
			end
			themeConfig:get_data().global.DefaultScoreType = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end	

function TipType()
	local t = {
		Name = "TipType",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","Tips","Random Phrases"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.TipType
			if pref == 1 then
				list[1] = true
			elseif pref == 2 then
				list[2] = true
			else 
				list[3] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] == true then
				value = 1
			elseif list[2] == true then
				value = 2
			else
				value = 3
			end
			themeConfig:get_data().global.TipType = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end	

function PlayerInfoType()
	local t = {
		Name = "PlayerInfoType",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Minimal","Full"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.PlayerInfoType
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.PlayerInfoType = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end	

function SongBGEnabled()
	local t = {
		Name = "SongBGEnabled",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.SongBGEnabled
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.SongBGEnabled = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end	

function SongBGMouseEnabled()
	local t = {
		Name = "SongBGMouseEnabled",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.SongBGMouseEnabled
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.SongBGMouseEnabled = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end	

function EvalBGType()
	local t = {
		Name = "EvalBGType",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Song Background","Clear+Grade Background","Grade Background only"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().eval.SongBGType
			if pref == 1 then
				list[1] = true
			elseif pref == 2 then
				list[2] = true
			else 
				list[3] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] == true then
				value = 1
			elseif list[2] == true then
				value = 2
			else
				value = 3
			end
			themeConfig:get_data().eval.SongBGType = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end

function Particles()
	local t = {
		Name = "Particles",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.Particles
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.Particles = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end	


function RateSort()
	local t = {
		Name = "RateSort",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.RateSort
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.RateSort = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end	

function HelpMenu()
	local t = {
		Name = "HelpMenu",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.HelpMenu
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.HelpMenu = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end	

function MeasureLines()
	local t = {
		Name = "MeasureLines",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.MeasureLines
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.MeasureLines = value
			themeConfig:set_dirty()
			themeConfig:save()
			THEME:ReloadMetrics()
		end
	}
	setmetatable( t, t )
	return t
end

function EvalScoreboard()
	local t = {
		Name = "EvalScoreboard",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Old","New"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.EvalScoreboard
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.EvalScoreboard = value
			themeConfig:set_dirty()
			themeConfig:save()
			THEME:ReloadMetrics()
		end
	}
	setmetatable( t, t )
	return t
end

function SimpleEval()
	local t = {
		Name = "SimpleEval",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = {"Classic","Simple"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.SimpleEval
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.SimpleEval = value
			themeConfig:set_dirty()
			themeConfig:save()
			THEME:ReloadMetrics()
		end
	}
	setmetatable( t, t )
	return t
end

function InstantSearch()
	local t = {
		Name = "InstantSearch",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = {THEME:GetString("OptionNames", "Off"), THEME:GetString("OptionNames", "On")},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.InstantSearch
			if pref then
				list[2] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.InstantSearch = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable(t, t)
	return t
end

function ShowScoreboardOnSimple()
	local t = {
		Name = "ShowScoreboardOnSimple",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = {"Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.ShowScoreboardOnSimple
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.ShowScoreboardOnSimple = value
			themeConfig:set_dirty()
			themeConfig:save()
			THEME:ReloadMetrics()
		end
	}
	setmetatable( t, t )
	return t
end

function ProgressBar()
	local t = {
		Name = "ProgressBar",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","Bottom", "Top",},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.ProgressBar
			if pref then
				list[pref+1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] == true then
				value = 0
			elseif list[2] == true then
				value = 1
			else
				value = 2
			end
			themeConfig:get_data().global.ProgressBar = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end

function CustomizeGameplay()
	local t = {
		Name = "CustomizeGameplay",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = {THEME:GetString("OptionNames", "Off"), THEME:GetString("OptionNames", "On")},
		LoadSelections = function(self, list, pn)
			local pref = playerConfig:get_data(pn_to_profile_slot(pn)).CustomizeGameplay
			if pref then
				list[2] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			playerConfig:get_data(pn_to_profile_slot(pn)).CustomizeGameplay = list[2]
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end
	}
	setmetatable(t, t)
	return t
end

local RSChoices = {}
for i = 1, 250 do
	RSChoices[i] = tostring(i) .. "%"
end
function ReceptorSize()
	local t = {
		Name = "ReceptorSize",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = RSChoices,
		LoadSelections = function(self, list, pn)
			local prefs = playerConfig:get_data(pn_to_profile_slot(pn)).ReceptorSize
			list[prefs] = true
		end,
		SaveSelections = function(self, list, pn)
			local found = false
			for i = 1, #list do
				if not found then
					if list[i] == true then
						local value = i
						playerConfig:get_data(pn_to_profile_slot(pn)).ReceptorSize = value
						found = true
					end
				end
			end
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end
	}
	setmetatable(t, t)
	return t
end

local LBChoices = {}
for i = 1, 15 do
	LBChoices[i] = tostring(i)
end
function LeaderboardSlots()
	local t = {
		Name = "LeaderboardSlots",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = LBChoices,
		LoadSelections = function(self, list, pn)
			local prefs = themeConfig:get_data().global.LeaderboardSlots
			list[prefs] = true
		end,
		SaveSelections = function(self, list, pn)
			local found = false
			for i = 1, #list do
				if not found then
					if list[i] == true then
						local value = i
						themeConfig:get_data().global.LeaderboardSlots = value
						found = true
					end
				end
			end
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable(t, t)
	return t
end

function DisplayPercent()
	local t = {
		Name = "DisplayPercent",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = {THEME:GetString("OptionNames", "Off"), THEME:GetString("OptionNames", "On")},
		LoadSelections = function(self, list, pn)
			local pref = playerConfig:get_data(pn_to_profile_slot(pn)).DisplayPercent
			if pref then
				list[2] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			value = list[2]
			playerConfig:get_data(pn_to_profile_slot(pn)).DisplayPercent = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end
	}
	setmetatable(t, t)
	return t
end

function DisplayMean()
	local t = {
		Name = "DisplayMean",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = {THEME:GetString("OptionNames", "Off"), THEME:GetString("OptionNames", "On")},
		LoadSelections = function(self, list, pn)
			local pref = playerConfig:get_data(pn_to_profile_slot(pn)).DisplayMean
			if pref then
				list[2] = true
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			value = list[2]
			playerConfig:get_data(pn_to_profile_slot(pn)).DisplayMean = value
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
		end
	}
	setmetatable(t, t)
	return t
end

function NPSWindow()
	local t = {
		Name = "NPSWindow",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = {"1","2","3","4","5"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().NPSDisplay.MaxWindow
			if pref then
				list[pref] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			for k,v in ipairs(list) do
				if v then
					value = k
				end
			end
			themeConfig:get_data().NPSDisplay.MaxWindow = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end

function SongPreview()
	local t = {
		Name = "SongPreview",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = {"SM Style","osu! Style (Current)","osu! Style (Old)"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.SongPreview
			if pref then
				list[pref] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			for k,v in ipairs(list) do
				if v then
					value = k
				end
			end
			themeConfig:get_data().global.SongPreview = value
			themeConfig:set_dirty()
			themeConfig:save()
			THEME:ReloadMetrics()
		end
	}
	setmetatable( t, t )
	return t
end

function AnimatedLeaderboard()
	local t = {
		Name = "AnimatedLeaderboard",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.AnimatedLeaderboard
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.AnimatedLeaderboard = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end

function BannerWheel()
	local t = {
		Name = "BannerWheel",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.BannerWheel
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.BannerWheel = value
			themeConfig:set_dirty()
			themeConfig:save()
			THEME:ReloadMetrics()
		end
	}
	setmetatable( t, t )
	return t
end


function JudgmentEnabled()
	local t = {
		Name = "JudgmentEnabled",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.JudgmentEnabled
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.JudgmentEnabled = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end
function JudgmentTween()
	local t = {
		Name = "JudgmentTween",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.JudgmentTween
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.JudgmentTween = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end
function ComboTween()
	local t = {
		Name = "ComboTween",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.ComboTween
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.ComboTween = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end
function ComboWords()
	local t = {
		Name = "ComboWords",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = { "Off","On"},
		LoadSelections = function(self, list, pn)
			local pref = themeConfig:get_data().global.ComboWords
			if pref then
				list[2] = true
			else 
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local value
			if list[1] then
				value = false
			else
				value = true
			end
			themeConfig:get_data().global.ComboWords = value
			themeConfig:set_dirty()
			themeConfig:save()
		end
	}
	setmetatable( t, t )
	return t
end