--[[
	Array gates
]]
GateActions("Array")
local format = string.format
local upper = string.upper
local lower = string.lower

local types_defaults = {
    NUMBER = 0,
    ANGLE = angle_zero,
    VECTOR = vector_origin,
    STRING = "",
    ENTITY = NULL
}

local types_formats = {
    NUMBER = function(x) return tostring(x) end,
    ANGLE = function(x) return format("(%d,%d,%d)", x.p, x.r, x.y) end,
    VECTOR = function(x) return format("(%d,%d,%d)", x.x, x.y, x.z) end,
    STRING = function(x) return x end,
    ENTITY = function(x) return tostring(x) end
}

-- used for array find gates.
local types_compare = {
    ANGLE = function(a, b) return a.p == b.p and a.y == b.y and a.r == b.r end,
    VECTOR = function(a, b) return a.x == b.x and a.y == b.y and a.z == b.z end
}

local normal_compare = function(a, b) return a == b end

for type_name, default in pairs(types_defaults) do
    local type_name2 = type_name

    if type_name2 == "NUMBER" then
        type_name2 = "NORMAL"
    end

    local compare = types_compare[type_name] or normal_compare

    GateActions["array_read_" .. type_name] = {
        name = "Array Read (" .. type_name .. ")",
        inputs = {"R", "Index"},
        inputtypes = {"ARRAY", "NORMAL"},
        outputtypes = {type_name2},
        output = function(gate, r, index)
            local var = r[math.floor(index)]
            local tp = type(var)
            if not var then return default end
            if tp == "Player" and type_name == "ENTITY" then return var end -- Special case
            if tp == "NPC" and type_name == "ENTITY" then return var end -- Special case
            if upper(tp) ~= type_name then return default end

            return var
        end,
        label = function(Out, r, index) return format("%s[%s] = %s", r, index, types_formats[type_name](Out)) end
    }

    GateActions["array_find_" .. type_name] = {
        name = "Array Find (" .. type_name .. ")",
        inputs = {"R", "Value"},
        inputtypes = {"ARRAY", type_name2},
        outputtypes = {"NORMAL"},
        output = function(gate, r, value)
            for i = 1, #r do
                if i > 10000 then return 0 end -- Stop iterating too much to prevent lag
                local var = r[i]
                if compare(var, value) then return i end
            end

            return 0
        end,
        label = function(Out, r, index) return format("find(%s,%s) = %d", r, index, Out) end
    }
    --[[
		I feel there is no need for these gates at this time.
		The only time you'll encounter arrays with gates
		are in a situation where you only need to read.
		I'll add it here for future reference

	GateActions["array_write_" .. type_name] = {
		name = "Array Write (" .. type_name .. ")",
		inputs = { "R", "Index", "Value" },
		inputtypes = { "ARRAY", "NORMAL", type_name2 },
		output = function(gate, r, index, value)
			if type(var) ~= lower(type_name) then return end
			if not var then return end

			r[math.floor(index)] = value
		end,
		label = function(Out,r,index)
			return format( "%s[%s] = %s", r, index, types_formats[type_name](Out) )
		end,
	}
	]]
end

--[[
	I feel there is no need for this gate at this time.
	The only time you'll encounter arrays with gates
	are in a situation where you only need to read.
	I'll add it here for future reference

GateActions["array_create"] = {
	name = "Array Create",
	output = function(gate)
		return {}
	end,
}
]]
GateActions["array_gettype"] = {
    name = "Array Get Type",
    inputs = {"R", "Index"},
    inputtypes = {"ARRAY", "NORMAL"},
    outputtypes = {"STRING"},
    output = function(gate, r, index)
        local tp = type(r[math.floor(index)])
        if tp == "nil" then return "NIL" end
        if tp == "Player" then return "ENTITY" end -- Special case
        if tp == "NPC" then return "ENTITY" end -- Special case
        if not types_defaults[upper(tp)] then return "TYPE NOT SUPPORTED" end

        return tp
    end,
    label = function(Out, r, index) return format("type(%s[%s]) = %s", r, index, Out) end
}

GateActions["array_count"] = {
    name = "Array Count",
    inputs = {"R"},
    inputtypes = {"ARRAY"},
    outputtypes = {"NORMAL"},
    output = function(gate, r) return #r end,
    label = function(Out, r, index) return format("#%s = %s", r, Out) end
}