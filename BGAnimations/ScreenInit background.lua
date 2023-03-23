local t = Def.ActorFrame {}

local minanyms = {
"Gekizi"
}

math.random()

t[#t + 1] =
	Def.Quad {
	InitCommand = function(self)
		self:xy(0, 0):halign(0):valign(0):zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):diffuse(color("#111111")):diffusealpha(0):linear(
			1
		):diffusealpha(1):sleep(1.75):linear(2):diffusealpha(0)
	end
}


	t[#t + 1] =
		LoadActor(THEME:GetPathG("", "_InitGreyBar")) .. {
			OnCommand = function(self)
				self:Center():zoomto(768, 150)
				self:diffuse(ColorMultiplier(getMainColor("positive"),1.5))
				self:diffusealpha(0):sleep(0.5)
				self:linear(1):diffusealpha(1):sleep(1.75):linear(2):diffusealpha(0)
			end
		}
	t[#t + 1] =
		LoadActor(THEME:GetPathG("", "_InitGreyBar")) .. {
			OnCommand = function(self)
				self:Center():zoomto(768, 150)
				self:diffuse(ColorMultiplier(getMainColor("positive"),0.75)):blend(Blend.Add)
				self:diffusealpha(0):sleep(0.5)
				self:linear(1):diffusealpha(0.2):sleep(1.75):linear(2):diffusealpha(0)
			end
		}
t[#t + 1] =
	Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end,
	LeftClickMessageCommand = function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
	Def.ActorFrame {
		OnCommand = function(self)
			self:playcommandonchildren("ChildrenOn")
		end,
		ChildrenOnCommand = function(self)
			self:diffusealpha(0):sleep(0.5):linear(0.5):diffusealpha(1)
		end,
		LoadFont("Common Normal") ..
			{
				Text = getThemeName(),
				InitCommand = function(self)
					self:y(-24)
				end,
				OnCommand = function(self)
					self:sleep(1):linear(3):diffuse(color("#111111")):diffusealpha(0)
				end
			},
		Def.ActorFrame {
			VibrateCommand = function(self)
				self:vibrate():effectmagnitude(5,5,0)
			end,
			LoadFont("Common Normal") ..
				{
					Text = "Created by " .. minanyms[math.random(#minanyms)],
					InitCommand = function(self)
						self:y(16):zoom(0.75):maxwidth(SCREEN_WIDTH)
					end,
					OnCommand = function(self)
						local scoob = ""
						if math.random(7777) == 777 then
							for i = 1, math.random(7) + 3 do
								local zoinks = math.random(#minanyms % 13)
								for ii = 1, zoinks do
									local raggy = minanyms[math.random(#minanyms)]
									scoob = scoob .. string.sub(raggy, math.random(#raggy), math.random(#raggy))
								end
							end

							self:GetParent():queuecommand("Vibrate")
							self:settext("Concatenated by " .. scoob)
							self:rainbow(bro):accelerate(7):zoom(7)
						else
							self:sleep(1):linear(3):diffuse(color("#111111")):diffusealpha(0)
						end
					end
				}
		},
	}
}

return t
