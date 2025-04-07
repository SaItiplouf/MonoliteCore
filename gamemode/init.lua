-- imports modules
require("mysqloo")

-- files initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_loadlibs.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("sh_loadlibs.lua")
GM:ImportLibs()

-- database start
include("sv_init_db.lua")
-- database end


function GM:Initialize()
    print("MonolithCore - Server Initialisation")
end