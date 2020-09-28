--[[
	Angle gates
]]
GateActions("Angle")
local Angle = Angle
local format = string.format
local tostring = tostring
local NormalizeAngle = math.NormalizeAngle
local Round = math.Round
local Clamp = math.Clamp

-- Add
GateActions["angle_add"] = {
    name = "Addition",
    inputs = {"A", "B", "C", "D", "E", "F", "G", "H"},
    inputtypes = {"ANGLE", "ANGLE", "ANGLE", "ANGLE", "ANGLE", "ANGLE", "ANGLE", "ANGLE"},
    compact_inputs = 2,
    outputtypes = {"ANGLE"},
    output = function(gate, A, B, C, D, E, F, G, H)
        if not A then
            A = angle_zero
        end

        if not B then
            B = angle_zero
        end

        if not C then
            C = angle_zero
        end

        if not D then
            D = angle_zero
        end

        if not E then
            E = angle_zero
        end

        if not F then
            F = angle_zero
        end

        if not G then
            G = angle_zero
        end

        if not H then
            H = angle_zero
        end

        return (A + B + C + D + E + F + G + H)
    end,
    label = function(Out) return format("Addition = (%d,%d,%d)", Out.p, Out.y, Out.r) end
}

-- Subtract
GateActions["angle_sub"] = {
    name = "Subtraction",
    inputs = {"A", "B"},
    inputtypes = {"ANGLE", "ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A, B)
        if not A then
            A = angle_zero
        end

        if not B then
            B = angle_zero
        end

        return (A - B)
    end,
    label = function(Out, A, B) return format("%s - %s = (%d,%d,%d)", A, B, Out.p, Out.y, Out.r) end
}

-- Negate
GateActions["angle_neg"] = {
    name = "Negate",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A)
        if not A then
            A = angle_zero
        end

        return Angle(-A.p, -A.y, -A.r)
    end,
    label = function(Out, A) return format("-%s = (%d,%d,%d)", A, Out.p, Out.y, Out.r) end
}

-- Multiply/Divide by constant
GateActions["angle_mul"] = {
    name = "Multiplication",
    inputs = {"A", "B"},
    inputtypes = {"ANGLE", "ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A, B)
        if not A then
            A = angle_zero
        end

        if not B then
            B = angle_zero
        end

        return Angle(A.p * B.p, A.y * B.y, A.r * B.r)
    end,
    label = function(Out, A, B) return format("%s * %s = (%d,%d,%d)", A, B, Out.p, Out.y, Out.r) end
}

-- Component Derivative
GateActions["angle_derive"] = {
    name = "Delta",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputtypes = {"ANGLE"},
    timed = true,
    output = function(gate, A)
        local t = CurTime()

        if not A then
            A = angle_zero
        end

        local dT, dA = t - gate.LastT, A - gate.LastA
        gate.LastT, gate.LastA = t, A

        if (dT) then
            return Angle(dA.p / dT, dA.y / dT, dA.r / dT)
        else
            return angle_zero
        end
    end,
    reset = function(gate)
        gate.LastT, gate.LastA = CurTime(), angle_zero
    end,
    label = function(Out, A) return format("diff(%s) = (%d,%d,%d)", A, Out.p, Out.y, Out.r) end
}

GateActions["angle_divide"] = {
    name = "Division",
    inputs = {"A", "B"},
    inputtypes = {"ANGLE", "ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A, B)
        if not A then
            A = angle_zero
        end

        if not B or B == angle_zero then
            B = angle_zero

            return B
        end

        return Angle(A.p / B.p, A.y / B.y, A.r / B.r)
    end,
    label = function(Out, A, B) return format("%s / %s = (%d,%d,%d)", A, B, Out.p, Out.y, Out.r) end
}

-- Conversion To/From
GateActions["angle_convto"] = {
    name = "Compose",
    inputs = {"Pitch", "Yaw", "Roll"},
    inputtypes = {"NORMAL", "NORMAL", "NORMAL"},
    outputtypes = {"ANGLE"},
    output = function(gate, Pitch, Yaw, Roll) return Angle(Pitch, Yaw, Roll) end,
    label = function(Out, Pitch, Yaw, Roll) return format("angle(%s,%s,%s) = (%d,%d,%d)", Pitch, Yaw, Roll, Out.p, Out.y, Out.r) end
}

GateActions["angle_convfrom"] = {
    name = "Decompose",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputs = {"Pitch", "Yaw", "Roll"},
    output = function(gate, A)
        if A then return A.p, A.y, A.r end

        return 0, 0, 0
    end,
    label = function(Out, A) return format("%s -> Pitch:%d Yaw:%d Roll:%d", A, Out.Pitch, Out.Yaw, Out.Roll) end
}

-- Identity
GateActions["angle_ident"] = {
    name = "Identity",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A)
        if not A then
            A = angle_zero
        end

        return A
    end,
    label = function(Out, A) return format("%s = (%d,%d,%d)", A, Out.p, Out.y, Out.r) end
}

-- Shifts the components left.
GateActions["angle_shiftl"] = {
    name = "Shift Components Left",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A)
        if not A then
            A = angle_zero
        end

        return Angle(A.y, A.r, A.p)
    end,
    label = function(Out, A) return format("shiftL(%s) = (%d,%d,%d)", A, Out.p, Out.y, Out.r) end
}

-- Shifts the components right.
GateActions["angle_shiftr"] = {
    name = "Shift Components Right",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A)
        if not A then
            A = angle_zero
        end

        return Angle(A.r, A.p, A.y)
    end,
    label = function(Out, A) return format("shiftR(%s) = (%d,%d,%d)", A, Out.p, Out.y, Out.r) end
}

GateActions["angle_fruvecs"] = {
    name = "Direction - (forward, up, right)",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputs = {"Forward", "Up", "Right"},
    outputtypes = {"VECTOR", "VECTOR", "VECTOR"},
    timed = true,
    output = function(gate, A)
        if not A then
            return Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0)
        else
            return A:Forward(), A:Up(), A:Right()
        end
    end,
    label = function(Out) return format("Forward = (%f , %f , %f)\nUp = (%f , %f , %f)\nRight = (%f , %f , %f)", Out.Forward.x, Out.Forward.y, Out.Forward.z, Out.Up.x, Out.Up.y, Out.Up.z, Out.Right.x, Out.Right.y, Out.Right.z) end
}

GateActions["angle_norm"] = {
    name = "Normalize",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A)
        if not A then
            A = angle_zero
        end

        return Angle(NormalizeAngle(A.p), NormalizeAngle(A.y), NormalizeAngle(A.r))
    end,
    label = function(Out, A) return format("normalize(%s) = (%d,%d,%d)", A, Out.p, Out.y, Out.r) end
}

GateActions["angle_tostr"] = {
    name = "To String",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputtypes = {"STRING"},
    output = function(gate, A)
        if not A then
            A = angle_zero
        end

        return "[" .. tostring(A.p) .. "," .. tostring(A.y) .. "," .. tostring(A.r) .. "]"
    end,
    label = function(Out, A) return format("toString(%s) = \"" .. Out .. "\"", A) end
}

-- Equal
GateActions["angle_compeq"] = {
    name = "Equal",
    inputs = {"A", "B"},
    inputtypes = {"ANGLE", "ANGLE"},
    outputtypes = {"NORMAL"},
    output = function(gate, A, B)
        if (A == B) then return 1 end

        return 0
    end,
    label = function(Out, A, B) return format("(%s == %s) = %d", A, B, Out) end
}

-- Not Equal
GateActions["angle_compineq"] = {
    name = "Not Equal",
    inputs = {"A", "B"},
    inputtypes = {"ANGLE", "ANGLE"},
    outputtypes = {"NORMAL"},
    output = function(gate, A, B)
        if (A == B) then return 0 end

        return 1
    end,
    label = function(Out, A, B) return format("(%s != %s) = %d", A, B, Out) end
}

-- Returns a rounded angle.
GateActions["angle_round"] = {
    name = "Round",
    inputs = {"A"},
    inputtypes = {"ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A)
        if not A then
            A = angle_zero
        end

        return Angle(Round(A.p), Round(A.y), Round(A.r))
    end,
    label = function(Out, A) return format("round(%s) = (%d,%d,%d)", A, Out.p, Out.y, Out.r) end
}

GateActions["angle_select"] = {
    name = "Select",
    inputs = {"Choice", "A", "B", "C", "D", "E", "F", "G", "H"},
    inputtypes = {"NORMAL", "ANGLE", "ANGLE", "ANGLE", "ANGLE", "ANGLE", "ANGLE", "ANGLE", "ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, Choice, ...)
        Choice = Clamp(Choice, 1, 8)

        return ({...})[Choice]
    end,
    label = function(Out, Choice) return format("select(%s) = %s", Choice, Out) end
}

GateActions["angle_mulcomp"] = {
    name = "Multiplication (component)",
    inputs = {"A", "B"},
    inputtypes = {"ANGLE", "NORMAL"},
    outputtypes = {"ANGLE"},
    output = function(gate, A, B)
        if not A then
            A = angle_zero
        end

        if not B then
            B = 0
        end

        return Angle(A.p * B, A.y * B, A.r * B)
    end,
    label = function(Out, A, B) return format("%s * %s = " .. tostring(Out), A, B) end
}

GateActions["angle_clampn"] = {
    name = "Clamp (numbers)",
    inputs = {"A", "Min", "Max"},
    inputtypes = {"ANGLE", "NORMAL", "NORMAL"},
    outputtypes = {"ANGLE"},
    output = function(gate, A, Min, Max)
        if (Min > Max) then
            Min, Max = Max, Min
        end

        return Angle(Clamp(A.p, Min, Max), Clamp(A.y, Min, Max), Clamp(A.r, Min, Max))
    end,
    label = function(Out, A, Min, Max) return "Clamp(" .. A .. "," .. Min .. "," .. Max .. ") = " .. tostring(Out) end
}

GateActions["angle_clampa"] = {
    name = "Clamp (angles)",
    inputs = {"A", "Min", "Max"},
    inputtypes = {"ANGLE", "ANGLE", "ANGLE"},
    outputtypes = {"ANGLE"},
    output = function(gate, A, Min, Max)
        if (Min.p > Max.p) then
            Min.p, Max.p = Max.p, Min.p
        end

        if (Min.y > Max.y) then
            Min.y, Max.y = Max.y, Min.y
        end

        if (Min.r > Max.r) then
            Min.r, Max.r = Max.r, Min.r
        end

        return Angle(Clamp(A.p, Min.p, Max.p), Clamp(A.y, Min.y, Max.y), Clamp(A.r, Min.r, Max.r))
    end,
    label = function(Out, A, Min, Max) return "Clamp(" .. A .. "," .. Min .. "," .. Max .. ") = " .. tostring(Out) end
}

GateActions()