--[[
	Entity gates
]]
GateActions("Entity")
local format = string.format
local Clamp = math.Clamp
local pi = math.pi
local atan2 = math.atan2
local asin = math.asin
local Color = Color
local Vector = Vector
local vector_max = Vector(255, 255, 255)

local function isAllowed(gate, Entity)
    if not IsValid(gate:GetPlayer()) then return false end

    return hook.Run("PhysgunPickup", gate:GetPlayer(), Entity) ~= false
end

GateActions["entity_class"] = {
    name = "Class",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"STRING"},
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return ""
        else
            return Entity:GetClass()
        end
    end,
    label = function(Out) return format("Class = %q", Out) end
}

GateActions["entity_entid"] = {
    name = "Entity ID",
    inputs = {"A"},
    inputtypes = {"ENTITY"},
    output = function(gate, A)
        if (A and A:IsValid()) then return A:EntIndex() end

        return 0
    end,
    label = function(Out, A) return format("entID(%s) = %d", A, Out) end
}

GateActions["entity_id2ent"] = {
    name = "ID to Entity",
    inputs = {"A"},
    outputtypes = {"ENTITY"},
    output = function(gate, A)
        local Ent = Entity(A)
        if not Entity:IsValid() then return NULL end

        return Ent
    end,
    label = function(Out, A) return format("Entity(%s) = %s", A, tostring(Out)) end
}

GateActions["entity_model"] = {
    name = "Model",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"STRING"},
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return ""
        else
            return Entity:GetModel()
        end
    end,
    label = function(Out) return format("Model = %q", Out) end
}

GateActions["entity_steamid"] = {
    name = "SteamID",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"STRING"},
    output = function(gate, Entity)
        if not Entity:IsValid() or not Entity:IsPlayer() then
            return ""
        else
            return Entity:SteamID()
        end
    end,
    label = function(Out) return format("SteamID = %q", Out) end
}

GateActions["entity_pos"] = {
    name = "Position",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return Vector(0, 0, 0)
        else
            return Entity:GetPos()
        end
    end,
    label = function(Out) return format("Position = (%d,%d,%d)", Out.x, Out.y, Out.z) end
}

GateActions["entity_fruvecs"] = {
    name = "Direction - (forward, right, up)",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputs = {"Forward", "Right", "Up"},
    outputtypes = {"VECTOR", "VECTOR", "VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0)
        else
            return Entity:GetForward(), Entity:GetRight(), Entity:GetUp()
        end
    end,
    label = function(Out) return format("Forward = (%f , %f , %f)\nUp = (%f , %f , %f)\nRight = (%f , %f , %f)", Out.Forward.x, Out.Forward.y, Out.Forward.z, Out.Up.x, Out.Up.y, Out.Up.z, Out.Right.x, Out.Right.y, Out.Right.z) end
}

GateActions["entity_isvalid"] = {
    name = "Is Valid",
    inputs = {"A"},
    inputtypes = {"ENTITY"},
    timed = true,
    output = function(gate, A)
        if (A and IsEntity(A) and A:IsValid()) then return 1 end

        return 0
    end,
    label = function(Out, A) return format("isValid(%s) = %s", A, Out) end
}

GateActions["entity_vell"] = {
    name = "Velocity (local)",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return Vector(0, 0, 0)
        else
            return Entity:WorldToLocal(Entity:GetVelocity() + Entity:GetPos())
        end
    end,
    label = function(Out) return format("Velocity (local) = (%f , %f , %f)", Out.x, Out.y, Out.z) end
}

GateActions["entity_vel"] = {
    name = "Velocity",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return Vector(0, 0, 0)
        else
            return Entity:GetVelocity()
        end
    end,
    label = function(Out) return format("Velocity = (%f , %f , %f)", Out.x, Out.y, Out.z) end
}

GateActions["entity_angvel"] = {
    name = "Angular Velocity",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"ANGLE"},
    timed = true,
    output = function(gate, Entity)
        local Vec

        if not Entity:IsValid() or not Entity:GetPhysicsObject():IsValid() then
            Vec = Vector(0, 0, 0)
        else
            Vec = Entity:GetPhysicsObject():GetAngleVelocity()
        end

        return Angle(Vec.y, Vec.z, Vec.x)
    end,
    label = function(Out) return format("Angular Velocity = (%f , %f , %f)", Out.p, Out.y, Out.r) end
}

GateActions["entity_angvelvec"] = {
    name = "Angular Velocity (vector)",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return Vector(0, 0, 0) end
        local phys = Entity:GetPhysicsObject()
        if not phys:IsValid() then return Vector(0, 0, 0) end

        return phys:GetAngleVelocity()
    end,
    label = function(Out) return format("Angular Velocity = (%f , %f , %f)", Out.x, Out.y, Out.z) end
}

GateActions["entity_wor2loc"] = {
    name = "World To Local (vector)",
    inputs = {"Entity", "Vec"},
    inputtypes = {"ENTITY", "VECTOR"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity, Vec)
        if Entity:IsValid() and isvector(Vec) then
            return Entity:WorldToLocal(Vec)
        else
            return Vector(0, 0, 0)
        end
    end,
    label = function(Out) return format("World To Local = (%f , %f , %f)", Out.x, Out.y, Out.z) end
}

GateActions["entity_loc2wor"] = {
    name = "Local To World (Vector)",
    inputs = {"Entity", "Vec"},
    inputtypes = {"ENTITY", "VECTOR"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity, Vec)
        if Entity:IsValid() and isvector(Vec) then
            return Entity:LocalToWorld(Vec)
        else
            return Vector(0, 0, 0)
        end
    end,
    label = function(Out) return format("Local To World Vector = (%f , %f , %f)", Out.x, Out.y, Out.z) end
}

GateActions["entity_wor2loc"] = {
    name = "World To Local (Vector)",
    inputs = {"Entity", "Vec"},
    inputtypes = {"ENTITY", "VECTOR"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity, Vec)
        if Entity:IsValid() and isvector(Vec) then
            return Entity:WorldToLocal(Vec)
        else
            return Vector(0, 0, 0)
        end
    end,
    label = function(Out) return format("World To Local Vector = (%f , %f , %f)", Out.x, Out.y, Out.z) end
}

GateActions["entity_loc2worang"] = {
    name = "Local To World (Angle)",
    inputs = {"Entity", "Ang"},
    inputtypes = {"ENTITY", "ANGLE"},
    outputtypes = {"ANGLE"},
    timed = true,
    output = function(gate, Entity, Ang)
        if Entity:IsValid() and Ang then
            return Entity:LocalToWorldAngles(Ang)
        else
            return Angle(0, 0, 0)
        end
    end,
    label = function(Out) return format("Local To World Angles = (%d,%d,%d)", Out.p, Out.y, Out.r) end
}

GateActions["entity_wor2locang"] = {
    name = "World To Local (Angle)",
    inputs = {"Entity", "Ang"},
    inputtypes = {"ENTITY", "ANGLE"},
    outputtypes = {"ANGLE"},
    timed = true,
    output = function(gate, Entity, Ang)
        if Entity:IsValid() and Ang then
            return Entity:WorldToLocalAngles(Ang)
        else
            return Angle(0, 0, 0)
        end
    end,
    label = function(Out) return format("World To Local Angles = (%d,%d,%d)", Out.p, Out.y, Out.r) end
}

GateActions["entity_health"] = {
    name = "Health",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return 0
        else
            return Entity:Health()
        end
    end,
    label = function(Out) return format("Health = %d", Out) end
}

GateActions["entity_radius"] = {
    name = "Radius",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return 0
        else
            return Entity:BoundingRadius()
        end
    end,
    label = function(Out) return format("Radius = %d", Out) end
}

GateActions["entity_mass"] = {
    name = "Mass",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() or not Entity:GetPhysicsObject():IsValid() then
            return 0
        else
            return Entity:GetPhysicsObject():GetMass()
        end
    end,
    label = function(Out) return format("Mass = %d", Out) end
}

GateActions["entity_masscenter"] = {
    name = "Mass Center",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() or not Entity:GetPhysicsObject():IsValid() then
            return Vector(0, 0, 0)
        else
            return Entity:LocalToWorld(Entity:GetPhysicsObject():GetMassCenter())
        end
    end,
    label = function(Out) return format("Mass Center = (%d,%d,%d)", Out.x, Out.y, Out.z) end
}

GateActions["entity_masscenterlocal"] = {
    name = "Mass Center (local)",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() or not Entity:GetPhysicsObject():IsValid() then
            return Vector(0, 0, 0)
        else
            return Entity:GetPhysicsObject():GetMassCenter()
        end
    end,
    label = function(Out) return format("Mass Center (local) = (%d,%d,%d)", Out.x, Out.y, Out.z) end
}

GateActions["entity_isplayer"] = {
    name = "Is Player",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsPlayer() then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is Player = %d", Out) end
}

GateActions["entity_isnpc"] = {
    name = "Is NPC",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsNPC() then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is NPC = %d", Out) end
}

GateActions["entity_isvehicle"] = {
    name = "Is Vehicle",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsVehicle() then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is Vehicle = %d", Out) end
}

GateActions["entity_isworld"] = {
    name = "Is World",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsWorld() then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is World = %d", Out) end
}

GateActions["entity_isongrnd"] = {
    name = "Is On Ground",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsOnGround() then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is On Ground = %d", Out) end
}

GateActions["entity_isunderwater"] = {
    name = "Is Under Water",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:WaterLevel() > 0 then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is Under Water = %d", Out) end
}

GateActions["entity_angles"] = {
    name = "Angles",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"ANGLE"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return Angle(0, 0, 0)
        else
            return Entity:GetAngles()
        end
    end,
    label = function(Out) return format("Angles = (%d,%d,%d)", Out.p, Out.y, Out.r) end
}

GateActions["entity_material"] = {
    name = "Material",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"STRING"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then
            return ""
        else
            return Entity:GetMaterial()
        end
    end,
    label = function(Out) return format("Material = %q", Out) end
}

GateActions["entity_owner"] = {
    name = "Owner",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"ENTITY"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return WireLib.GetOwner(gate) end

        return WireLib.GetOwner(Entity)
    end,
    label = function(Out, Entity) return format("owner(%s) = %s", Entity, tostring(Out)) end
}

GateActions["entity_isheld"] = {
    name = "Is Player Holding",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsPlayerHolding() then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is Player Holding = %d", Out) end
}

GateActions["entity_isonfire"] = {
    name = "Is On Fire",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsOnFire() then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is On Fire = %d", Out) end
}

GateActions["entity_isweapon"] = {
    name = "Is Weapon",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsWeapon() then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is Weapon = %d", Out) end
}

GateActions["player_invehicle"] = {
    name = "Is In Vehicle",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsPlayer() and Entity:InVehicle() then
            return 1
        else
            return 0
        end
    end,
    label = function(Out) return format("Is In Vehicle = %d", Out) end
}

GateActions["player_connected"] = {
    name = "Time Connected",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return 0 end

        if Entity:IsPlayer() then
            return Entity:TimeConnected()
        else
            return 0
        end
    end,
    label = function(Out) return format("Time Connected = %d", Out) end
}

GateActions["entity_aimentity"] = {
    name = "AimEntity",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"ENTITY"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return NULL end
        local EntR = Entity:GetEyeTraceNoCursor().Entity
        if not EntR:IsValid() then return NULL end

        return EntR
    end,
    label = function(Out) return format("Aim Entity = %s", tostring(Out)) end
}

GateActions["entity_aimenormal"] = {
    name = "AimNormal",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return Vector(0, 0, 0) end

        if (Entity:IsPlayer()) then
            return Entity:GetAimVector()
        else
            return Entity:GetForward()
        end
    end,
    label = function(Out, A) return format("Aim Normal (%s) = (%d,%d,%d)", A, Out.x, Out.y, Out.z) end
}

GateActions["entity_aimedirection"] = {
    name = "AimDirection",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() or not Entity:IsPlayer() then return Vector(0, 0, 0) end

        return Entity:GetEyeTraceNoCursor().Normal
    end,
    label = function(Out, A) return format("Aim Direction (%s) = (%d,%d,%d)", A, Out.x, Out.y, Out.z) end
}

GateActions["entity_inertia"] = {
    name = "Inertia",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() or not Entity:GetPhysicsObject():IsValid() then return Vector(0, 0, 0) end

        return Entity:GetPhysicsObject():GetInertia()
    end,
    label = function(Out, A) return format("inertia(%s) = (%d,%d,%d)", Entity, Out.x, Out.y, Out.z) end
}

GateActions["entity_equal"] = {
    name = "Equal",
    inputs = {"A", "B"},
    inputtypes = {"ENTITY", "ENTITY"},
    output = function(gate, A, B)
        if A == B then
            return 1
        else
            return 0
        end
    end,
    label = function(Out, A, B) return format("(%s  = =  %s) = %d", A, B, Out) end
}

GateActions["entity_inequal"] = {
    name = "Inequal",
    inputs = {"A", "B"},
    inputtypes = {"ENTITY", "ENTITY"},
    output = function(gate, A, B)
        if A ~= B then
            return 1
        else
            return 0
        end
    end,
    label = function(Out, A, B) return format("(%s  ! =  %s) = %d", A, B, Out) end
}

GateActions["entity_setcol"] = {
    name = "Set Color",
    inputs = {"Entity", "Col"},
    inputtypes = {"ENTITY", "VECTOR"},
    outputs = {"Entity", "Col"},
    outputtypes = {"ENTITY", "VECTOR"},
    output = function(gate, Entity, Col)
        if not Entity:IsValid() then return end
        if not gamemode.Call("CanTool", WireLib.GetOwner(gate), WireLib.dummytrace(Entity), "color") then return end

        if not isvector(Col) then
            Col = vector_max
        end

        Entity:SetColor(Color(Col.x, Col.y, Col.z, 255))

        return Entity, Col
    end,
    label = function(Out, Entity)
        if istable(Out) then
            Col = Out.Col
        end

        return format(Entity .. ":SetColor(%d, %d, %d)", Col.x, Col.y, Col.z)
    end
}

GateActions["entity_driver"] = {
    name = "Driver",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"ENTITY"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() or not Entity:IsVehicle() then return NULL end

        return Entity:GetDriver()
    end,
    label = function(Out, A)
        local Name = "NULL"

        if Out:IsValid() then
            Name = Out:Nick()
        end

        return format("Driver: %s", Name)
    end
}

GateActions["entity_clr"] = {
    name = "Color",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() then return Vector(0, 0, 0) end
        local c = Entity:GetColor()

        return Vector(c.r, c.g, c.b)
    end,
    label = function(Out, Entity) return format("color(%s) = (%d,%d,%d)", Entity, Out.x, Out.y, Out.z) end
}

GateActions["entity_name"] = {
    name = "Name",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"STRING"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() or not Entity:IsPlayer() then
            return ""
        else
            return Entity:Nick()
        end
    end,
    label = function(Out, Entity) return format("name(%s) = %s", Entity, Out) end
}

GateActions["entity_aimpos"] = {
    name = "AimPosition",
    inputs = {"Entity"},
    inputtypes = {"ENTITY"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, Entity)
        if not Entity:IsValid() or not Entity:IsPlayer() then
            return Vector(0, 0, 0)
        else
            return Entity:GetEyeTraceNoCursor().HitPos
        end
    end,
    label = function(Out) return format("Aim Position = (%f , %f , %f)", Out.x, Out.y, Out.z) end
}

GateActions["entity_select"] = {
    name = "Select",
    inputs = {"Choice", "A", "B", "C", "D", "E", "F", "G", "H"},
    inputtypes = {"NORMAL", "ENTITY", "ENTITY", "ENTITY", "ENTITY", "ENTITY", "ENTITY", "ENTITY", "ENTITY"},
    outputtypes = {"ENTITY"},
    output = function(gate, Choice, ...)
        Clamp(Choice, 1, 8)

        return ({...})[Choice]
    end,
    label = function(Out, Choice) return format("select(%s) = %s", Choice, Out) end
}

-- Bearing and Elevation, copied from E2
GateActions["entity_bearing"] = {
    name = "Bearing",
    inputs = {"Entity", "Position"},
    inputtypes = {"ENTITY", "VECTOR", "NORMAL"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity, Position)
        if (not Entity:IsValid()) then return 0 end
        Position = Entity:WorldToLocal(Position)

        return 180 / pi * atan2(Position.y, Position.x)
    end,
    label = function(Out, Entity, Position) return Entity .. ":Bearing(" .. Position .. ") = " .. Out end
}

GateActions["entity_elevation"] = {
    name = "Elevation",
    inputs = {"Entity", "Position"},
    inputtypes = {"ENTITY", "VECTOR", "NORMAL"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, Entity, Position)
        if (not Entity:IsValid()) then return 0 end
        Position = Entity:WorldToLocal(Position)
        local len = Position:Length()

        return 180 / pi * asin(Position.z / len)
    end,
    label = function(Out, Entity, Position) return Entity .. ":Elevation(" .. Position .. ") = " .. Out end
}

GateActions["entity_heading"] = {
    name = "Heading",
    inputs = {"Entity", "Position"},
    inputtypes = {"ENTITY", "VECTOR", "NORMAL"},
    outputs = {"Bearing", "Elevation", "Heading"},
    outputtypes = {"NORMAL", "NORMAL", "ANGLE"},
    timed = true,
    output = function(gate, Entity, Position)
        if (not Entity:IsValid()) then return 0, 0, Angle(0, 0, 0) end
        Position = Entity:WorldToLocal(Position)
        -- Bearing
        local bearing = 180 / pi * atan2(Position.y, Position.x)
        -- Elevation
        local len = Position:Length()
        elevation = 180 / pi * asin(Position.z / len)

        return bearing, elevation, Angle(bearing, elevation, 0)
    end,
    label = function(Out, Entity, Position) return Entity .. ":Heading(" .. Position .. ") = " .. tostring(Out.Heading) end
}

GateActions()