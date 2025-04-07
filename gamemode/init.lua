-- imports modules
require("mysqloo")

-- files initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_fileloader.lua")
include("shared.lua")
include("sh_fileloader.lua")

GM:ImportFiles()

-- database start
include("sv_init_db.lua")
-- database end


function GM:Initialize()
    print("MonolithCore - Server Initialisation")
end

