--[[
	Rangerdata gates
]]
GateActions("Ranger")
local format = string.format

GateActions["rd_trace"] = {
    name = "Trace",
    inputs = {"Startpos", "Endpos"},
    inputtypes = {"VECTOR", "VECTOR"},
    outputtypes = {"RANGER"},
    timed = true,
    output = function(gate, Startpos, Endpos)
        if not isvector(Startpos) then
            Startpos = vector_origin
        end

        if not isvector(Endpos) then
            Endpos = vector_origin
        end

        local tracedata = {}
        tracedata.start = Startpos
        tracedata.endpos = Endpos

        return util.TraceLine(tracedata)
    end,
    label = function(Out, Startpos, Endpos) return format("trace(%s , %s)", Startpos, Endpos) end
}

GateActions["rd_hitpos"] = {
    name = "Hit Position",
    inputs = {"A"},
    inputtypes = {"RANGER"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, A)
        if not A then return vector_origin end
        if A.StartSolid then return A.StartPos end

        return A.HitPos
    end,
    label = function(Out, A) return format("hitpos(%s) = (%d,%d,%d)", A, Out.x, Out.y, Out.z) end
}

GateActions["rd_hitnorm"] = {
    name = "Hit Normal",
    inputs = {"A"},
    inputtypes = {"RANGER"},
    outputtypes = {"VECTOR"},
    timed = true,
    output = function(gate, A)
        if not A then return vector_origin end

        return A.HitNormal
    end,
    label = function(Out, A) return format("hitnormal(%s) = (%d,%d,%d)", A, Out.x, Out.y, Out.z) end
}

GateActions["rd_entity"] = {
    name = "Entity",
    inputs = {"A"},
    inputtypes = {"RANGER"},
    outputtypes = {"ENTITY"},
    timed = true,
    output = function(gate, A)
        if not A then return NULL end

        return A.Entity
    end,
    label = function(Out, A) return format("hitentity(%s) = %s", A, tostring(Out)) end
}

GateActions["rd_hitworld"] = {
    name = "Hit World",
    inputs = {"A"},
    inputtypes = {"RANGER"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, A)
        if not A then return 0 end

        return A.HitWorld and 1 or 0
    end,
    label = function(Out, A) return format("hitworld(%s) = %d", A, Out and 1 or 0) end
}

GateActions["rd_hit"] = {
    name = "Hit",
    inputs = {"A"},
    inputtypes = {"RANGER"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, A)
        if not A then return 0 end

        return A.Hit and 1 or 0
    end,
    label = function(Out, A) return format("hit(%s) = %d", A, Out and 1 or 0) end
}

GateActions["rd_distance"] = {
    name = "Distance",
    inputs = {"A"},
    inputtypes = {"RANGER"},
    outputtypes = {"NORMAL"},
    timed = true,
    output = function(gate, A)
        if not A then return 0 end
        if A.StartSolid then return A.StartPos:Distance(A.HitPos) * (1 / (1 - A.FractionLeftSolid) - 1) end

        return A.StartPos:Distance(A.HitPos)
    end,
    label = function(Out, A) return format("distance(%s) = %d", A, Out) end
}

GateActions()