local tLibs = {
    {
        name = "Pixel UI",
        path = "pixel-ui-1.4.0/lua/autorun/sh_pixelui_loader.lua"
    },
}

local function LoadFile(relPath)
    local prefix = string.sub(string.GetFileFromFilename(relPath), 1, 3)
    if prefix == "sv_" then
        if SERVER then include(relPath) end
    elseif prefix == "cl_" then
        if SERVER then
            AddCSLuaFile(relPath)
        elseif CLIENT then
            include(relPath)
        end
    elseif prefix == "sh_" then
        if SERVER then AddCSLuaFile(relPath) end
        if CLIENT then include(relPath) end
    else
        if SERVER then AddCSLuaFile(relPath) end
        include(relPath)
    end
end

local function loadDirectoryRecursive(directory)
    local files, folders = file.Find(directory .. "/*", "LUA")
    
    -- Charger tous les fichiers du dossier courant
    for _, fileName in ipairs(files) do
        local filePath = directory .. "/" .. fileName
        LoadFile(filePath)
        print("[GAMEMODE] Loaded file: " .. filePath)
    end

    -- Parcourir les sous-dossiers et appeler récursivement la fonction
    for _, folder in ipairs(folders) do
        loadDirectoryRecursive(directory .. "/" .. folder)
    end
end

function GM:ImportLibs()
    -- Chemin complet pour file.Exists (relatif à la racine de Garry's Mod)
    local basePathFull = "gamemodes/" .. GM.FolderName .. "/gamemode/libs/"
    -- Chemin relatif pour include/AddCSLuaFile (relatif au dossier gamemode)
    local basePathRel = "libs/"

    for _, lib in ipairs(tLibs) do
        local fullPath = basePathFull .. lib.path
        local relPath = basePathRel .. lib.path
        if file.Exists(fullPath, "GAME") then
            LoadFile(relPath)
            print("[IMPORTMAP] Loaded " .. lib.name .. " from " .. fullPath)
        else
            print("[IMPORTMAP] Couldn't load " .. lib.name .. " from " .. fullPath)
        end
    end

    -- Charger récursivement tous les fichiers Lua du dossier gamemode
    loadDirectoryRecursive()
end