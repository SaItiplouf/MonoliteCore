local tConfig = {
    basePath = "gamemodes/" .. GM.FolderName .. "/gamemode/",
    exclude = { "init.lua", "cl_init.lua", "shared.lua", "sv_init_db.lua" }
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
        include(relPath)
    else
        if SERVER then AddCSLuaFile(relPath) end
        include(relPath)
    end
end

-- Fonction récursive qui traite uniquement la récursion
local function ProcessDirectory(currentDir)
    local files, directories = file.Find(currentDir .. "*", "GAME")
    
    for _, filename in ipairs(files) do
        if filename:sub(-4) == ".lua" then
            -- On n'exclut que les fichiers du dossier racine
            if not (currentDir == tConfig.basePath and table.HasValue(tConfig.exclude, filename)) then
                local fullPath = currentDir .. filename
                if file.Exists(fullPath, "GAME") then
                    local relativePath = fullPath:sub(#tConfig.basePath + 1)
                    LoadFile(relativePath)
                else
                    -- print("[IMPORTMAP] Couldn't load " .. filename .. " from " .. fullPath)
                end
            else
                -- print("[IMPORTMAP] Skipped excluded file: " .. filename .. " in " .. currentDir)
            end
        else
            -- print("[IMPORTMAP] Ignored non-lua file: " .. filename .. " in " .. currentDir)
        end
    end

    for _, folder in ipairs(directories) do
        local folderPath = currentDir .. folder .. "/"
        ProcessDirectory(folderPath)
    end
end

local function PostImport()
    hook.Run("PIXEL.UI.FullyLoaded")
    print("[IMPORTMAP] All files imported. PostImport function executed.")
end

-- Fonction principale qui lance le traitement récursif et déclenche ensuite postImport
function GM:ImportFiles()
    ProcessDirectory(tConfig.basePath)
    PostImport()
end