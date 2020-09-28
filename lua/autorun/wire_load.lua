﻿--[[
Copyright 2013 Wiremod Developers
https://github.com/wiremod/

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]
--
if VERSION < 140403 and VERSION > 5 then
    -- VERSION > 5 check added June 2013, to address issues regarding the Steampipe update sometimes setting VERSION to 1.
    ErrorNoHalt("WireMod: This branch of wiremod only supports Gmod13+.\n")

    return
end

if SERVER then
    -- this file
    AddCSLuaFile("autorun/wire_load.lua")
    -- shared includes
    AddCSLuaFile("wire/wire_paths.lua")
    AddCSLuaFile("wire/wireshared.lua")
    AddCSLuaFile("wire/wireratelimit.lua")
    AddCSLuaFile("wire/wiregates.lua")
    AddCSLuaFile("wire/wiremonitors.lua")
    AddCSLuaFile("wire/gpulib.lua")
    AddCSLuaFile("wire/timedpairs.lua")
    AddCSLuaFile("wire/default_data_decompressor.lua")
    AddCSLuaFile("wire/flir.lua")
    AddCSLuaFile("wire/von.lua")
    -- client includes
    AddCSLuaFile("wire/client/cl_wirelib.lua")
    AddCSLuaFile("wire/client/cl_modelplug.lua")
    AddCSLuaFile("wire/client/cl_wire_map_interface.lua")
    AddCSLuaFile("wire/client/wiredermaexts.lua")
    AddCSLuaFile("wire/client/wiremenus.lua")
    AddCSLuaFile("wire/client/gmod_tool_auto.lua")
    AddCSLuaFile("wire/client/rendertarget_fix.lua")
    AddCSLuaFile("wire/client/customspawnmenu.lua")

    if CreateConVar("wire_force_workshop", 1, {FCVAR_ARCHIVE}, "Should Wire force all clients to download the Workshop edition of Wire, for models? (requires restart to disable)"):GetBool() then
        resource.AddWorkshop("160250458")
    end
end

-- shared includes
include("wire/wireshared.lua")
include("wire/wireratelimit.lua")
include("wire/wire_paths.lua")
include("wire/wiregates.lua")
include("wire/wiremonitors.lua")
include("wire/gpulib.lua")
include("wire/timedpairs.lua")
include("wire/default_data_decompressor.lua")
include("wire/flir.lua")
include("wire/von.lua")

-- server includes
if SERVER then
    include("wire/server/wirelib.lua")
    include("wire/server/modelplug.lua")
    include("wire/server/debuggerlib.lua")
end

-- client includes
if CLIENT then
    include("wire/client/cl_wirelib.lua")
    include("wire/client/cl_modelplug.lua")
    include("wire/client/cl_wire_map_interface.lua")
    include("wire/client/wiredermaexts.lua")
    include("wire/client/wiremenus.lua")
    include("wire/client/gmod_tool_auto.lua")
    include("wire/client/rendertarget_fix.lua")
    include("wire/client/customspawnmenu.lua")
end

-- Load UWSVN, done here so its definitely after Wire is loaded.
if file.Find("wire/uwsvn_load.lua", "LUA")[1] then
    if SERVER then
        AddCSLuaFile("wire/uwsvn_load.lua")
    end

    include("wire/uwsvn_load.lua")
end

if SERVER then
    print("Wiremod Version '" .. WireLib.GetVersion() .. "' loaded")
end