-- Ajout des messages réseau utilisés
util.AddNetworkString("OpenCharMenu")
util.AddNetworkString("CreateCharacter")
util.AddNetworkString("SelectCharacter")
util.AddNetworkString("DBToast")

-- Fonction appelée au spawn d’un joueur pour ouvrir le menu de sélection/création
function GM:PlayerInitialSpawn(ply)
    self:CharacterMenuInit(ply)
end

-- Récupération et envoi des personnages du joueur
function GM:CharacterMenuInit(ply)
    local steamID = ply:SteamID()
    local queryStr = "SELECT * FROM player_characters WHERE steamid = " .. sql.SQLStr(steamID)

    local q = db:query(queryStr)

    function q:onSuccess(result)
        net.Start("OpenCharMenu")
            net.WriteTable(result or {})
        net.Send(ply)
    end

    function q:onError(err)
        print("[MySQL] Query error (CharacterMenuInit): " .. err)
    end

    q:start()
end

-- Création d’un nouveau personnage
net.Receive("CreateCharacter", function(len, ply)
    local name = net.ReadString()
    local playermodel = net.ReadString()
    local steamID = ply:SteamID()
    local head = "default"

    if not name or name == "" then
        ply:PrintMessage(HUD_PRINTTALK, "Nom invalide.")
        return
    end

    local query = string.format(
        "INSERT INTO player_characters (steamid, head, name, playermodel) VALUES (%s, %s, %s, %s)",
        sql.SQLStr(steamID), sql.SQLStr(head), sql.SQLStr(name), sql.SQLStr(playermodel)
    )

    local q = db:query(query)

    function q:onSuccess()
        ply:PrintMessage(HUD_PRINTTALK, "Personnage créé avec succès.")
        GAMEMODE:CharacterMenuInit(ply)
    end

    function q:onError(err)
        print("[MySQL] Insert error (CreateCharacter): " .. err)
    end

    q:start()
end)

-- Sélection d’un personnage existant
net.Receive("SelectCharacter", function(len, ply)
    local characterID = net.ReadUInt(16)

    if not characterID or characterID <= 0 then
        ply:PrintMessage(HUD_PRINTTALK, "ID de personnage invalide.")
        return
    end

    local query = "SELECT * FROM player_characters WHERE id = " .. characterID .. " LIMIT 1"
    local q = db:query(query)

    function q:onSuccess(result)
        if result and #result > 0 then
            local charData = result[1]

            ply:SetModel(charData.playermodel)
            ply:SetHealth(charData.health or 100)
            ply:SetNWInt("Money", charData.money or 0)
            ply:SetNWString("RPName", charData.name or "Inconnu")
            ply:Spawn()
            
            net.Start("DBToast")
                net.WriteString("Vous incarnez désormais : " .. (charData.name or "Inconnu"))
                net.WriteString("success")
            net.Send(ply)
            
        else
            net.Start("DBToast")
                net.WriteString("Personnage introuvable")
                net.WriteString("error")
            net.Send(ply)
        end
    end

    function q:onError(err)
        print("[MySQL] Select error (SelectCharacter): " .. err)
    end

    q:start()
end)
