-- imports modules
require("mysqloo")

-- files initialization
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_fileloader.lua")
include("shared.lua")

-- database start
include("sv_init_db.lua")
-- database end


include("sh_fileloader.lua")
GM:ImportFiles()

function GM:Initialize()
    print("MonolithCore - Server Initialisation")
end

function GM:PlayerInitialSpawn(ply)
    ply:StripWeapons()
    ply:Freeze(true)
    ply:SetNoDraw(true)

    self:CharacterMenuInit(ply)
   
    -- Vous pouvez également empêcher le spawn effectif tant que le joueur n'a pas sélectionné/créé de personnage
    -- Par exemple, en le plaçant dans une zone d'attente ou en retardant le spawn effectif.
end

function GM:PlayerDisconnected(ply)
    self:SavePlayerCharacter(ply)
end

-- Hook appelé lors de l'arrêt du serveur
function GM:ShutDown()
    for _, ply in ipairs(player.GetAll()) do
         self:SavePlayerCharacter(ply)
    end
end