WireLib.RateLimit = WireLib.RateLimit or {}
WireLib.RateLimit.Tasks = {}
WireLib.RateLimit.Tracker = {}
WireLib.RateLimit.LastTick = 0
WireLib.RateLimit.MaxPerTick = 10
WireLib.RateLimit.TrackerTick = 1
WireLib.RateLimit.Halted = false
local Wire_MaxTickRate = CreateConVar("wire_max_tickrate", 10, {FCVAR_ARCHIVE}, "The amount of wiremod ticks to do each update.")
WireLib.RateLimit.MaxPerTick = Wire_MaxTickRate:GetInt()

cvars.AddChangeCallback("wire_max_tickrate", function(cvar, old, new)
    if not tonumber(new) then
        new = old
    end

    PrintMessage(HUD_PRINTTALK, "[Wiremod]: Max ticks per update has been changed to " .. new)
    WireLib.RateLimit.MaxPerTick = tonumber(new)
end, "notify_wire_update")

concommand.Add("wire_halt_activity", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    WireLib.RateLimit.Halted = not WireLib.RateLimit.Halted
    PrintMessage(HUD_PRINTTALK, "[Wiremod]: All server intensive activty has been " .. (WireLib.RateLimit.Halted and "halted" or "resumed") .. ".")
end)

function WireLib.RateLimit:Limit(ply)
    self.Tracker[ply] = self.Tracker[ply] or {
        Count = 1,
        Last = CurTime()
    }

    if WireLib.RateLimit.Halted then return true end
    if self.Tracker[ply].Count >= self.MaxPerTick then return true end
    self.Tracker[ply].Count = self.Tracker[ply].Count + self.TrackerTick
    self.Tracker[ply].Last = CurTime()
end

function WireLib.RateLimit:DecayTicks()
    for ply, info in pairs(self.Tracker) do
        if self.LastTick ~= info.Last then
            self.Tracker[ply] = nil
        end

        self.LastTick = info.Last
    end
end

function WireLib.RateLimit:Tick()
    self:DecayTicks()
end

hook.Add("Tick", "WireLib.RateLimit:Tick", function()
    WireLib.RateLimit:Tick()
end)