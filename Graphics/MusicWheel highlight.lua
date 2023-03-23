-- Controls the dot next to the MusicWheel

return Def.ActorFrame {
    LoadActor("pointer"),
    InitCommand = function(self)
        self:xy(13,0)
        self:zoom(0.1,0.1)
        end,
        SetCommand = function(self)
            self:diffuse(color("#FFFFFF"))
        end,
        BeginCommand = function(self)
            self:queuecommand("Set")
        end,
        OffCommand = function(self)
            self:visible(false)
        end
    }

