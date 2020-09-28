--[[
		Selection Gates
]]
GateActions("Selection")
local min = math.min
local max = math.max
local floor = math.floor
local fmod = math.fmod
local abs = math.abs
local sub = string.sub

GateActions["min"] = {
    name = "Minimum (Smallest)",
    inputs = {"A", "B", "C", "D", "E", "F", "G", "H"},
    compact_inputs = 2,
    output = function(gate, ...) return min(unpack({...})) end,
    label = function(Out, ...)
        local txt = "min("

        for k, v in ipairs({...}) do
            if (v) then
                txt = txt .. v .. ", "
            end
        end

        return sub(txt, 1, -3) .. ") = " .. Out
    end
}

GateActions["max"] = {
    name = "Maximum (Largest)",
    inputs = {"A", "B", "C", "D", "E", "F", "G", "H"},
    compact_inputs = 2,
    output = function(gate, ...) return max(unpack({...})) end,
    label = function(Out, ...)
        local txt = "max("

        for k, v in ipairs({...}) do
            if (v) then
                txt = txt .. v .. ", "
            end
        end

        return sub(txt, 1, -3) .. ") = " .. Out
    end
}

GateActions["minmax"] = {
    name = "Value Range",
    inputs = {"Min", "Max", "Value"},
    output = function(gate, Min, Max, Value)
        local temp = Min

        if Min > Max then
            Min = Max
            Max = temp
        end

        if Value < Min then return Min end
        if Value > Max then return Max end

        return Value
    end,
    label = function(Out, Min, Max, Value)
        local temp = Min

        if Min > Max then
            Min = Max
            Max = temp
        end

        return "Min: " .. Min .. "  Max: " .. Max .. "  Value: " .. Value .. " = " .. Out
    end
}

GateActions["if"] = {
    name = "If Then Else",
    inputs = {"A", "B", "C"},
    output = function(gate, A, B, C)
        if (A) and (A > 0) then return B end

        return C
    end,
    label = function(Out, A, B, C) return "if " .. A .. " then " .. B .. " else " .. C .. " = " .. Out end
}

GateActions["select"] = {
    name = "Select (Choice)",
    inputs = {"Choice", "A", "B", "C", "D", "E", "F", "G", "H"},
    output = function(gate, Choice, ...)
        local idx = floor(Choice)
        if (idx > 0) and (idx <= 8) then return ({...})[idx] end

        return 0
    end,
    label = function(Out, Choice) return "Select Choice:" .. Choice .. " Out:" .. Out end
}

GateActions["router"] = {
    name = "Router",
    inputs = {"Path", "Data"},
    outputs = {"A", "B", "C", "D", "E", "F", "G", "H"},
    output = function(gate, Path, Data)
        local result = {0, 0, 0, 0, 0, 0, 0, 0}
        local idx = floor(Path)

        if (idx > 0) and (idx <= 8) then
            result[idx] = Data
        end

        return unpack(result)
    end,
    label = function(Out, Path, Data) return "Router Path:" .. Path .. " Data:" .. Data end
}

local SegmentInfo = {
    None = {0, 0, 0, 0, 0, 0, 0},
    [0] = {1, 1, 1, 1, 1, 1, 0},
    [1] = {0, 1, 1, 0, 0, 0, 0},
    [2] = {1, 1, 0, 1, 1, 0, 1},
    [3] = {1, 1, 1, 1, 0, 0, 1},
    [4] = {0, 1, 1, 0, 0, 1, 1},
    [5] = {1, 0, 1, 1, 0, 1, 1},
    [6] = {1, 0, 1, 1, 1, 1, 1},
    [7] = {1, 1, 1, 0, 0, 0, 0},
    [8] = {1, 1, 1, 1, 1, 1, 1},
    [9] = {1, 1, 1, 1, 0, 1, 1}
}

GateActions["7seg"] = {
    name = "7 Segment Decoder",
    inputs = {"A", "Clear"},
    outputs = {"A", "B", "C", "D", "E", "F", "G"},
    output = function(gate, A, Clear)
        if (Clear > 0) then return unpack(SegmentInfo.None) end
        local idx = fmod(abs(floor(A)), 10)
        if idx > #SegmentInfo then return unpack(SegmentInfo.None) end

        return unpack(SegmentInfo[idx]) -- same as: return SegmentInfo[idx][1], SegmentInfo[idx][2], ...
    end,
    label = function(Out, A) return "7-Seg In:" .. A .. " Out:" .. Out.A .. Out.B .. Out.C .. Out.D .. Out.E .. Out.F .. Out.G end
}

GateActions["timedec"] = {
    name = "Time/Date decoder",
    inputs = {"Time", "Date"},
    outputs = {"Hours", "Minutes", "Seconds", "Year", "Day"},
    output = function(gate, Time, Date) return floor(Time / 3600), floor(Time / 60) % 60, floor(Time) % 60, floor(Date / 366), floor(Date) % 366 end,
    label = function(Out, A) return "Date decoder" end
}

GateActions()