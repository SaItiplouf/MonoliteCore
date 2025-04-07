-- Configuration de la connexion à la base de données
local db_host = "127.0.0.1"
local db_user = "root"
local db_pass = ""
local db_name = "monolitecore"
local db_port = 3306

-- Création de la connexion mysqloo (variable globale pour être accessible partout)
db = mysqloo.connect(db_host, db_user, db_pass, db_name, db_port)

-- Fonction appelée en cas de connexion réussie
function db:onConnected()
    print("MonolithCore - Database connection established")
    UpdateDatabaseSchema()  -- Met à jour le schéma dès la connexion
end

-- Fonction appelée en cas d'échec de connexion
function db:onConnectionFailed(err)
    print("MonolithCore - Database failed : " .. err)
end

db:connect()

-- Définition du schéma de la base de données (table des requêtes SQL)
local db_schema = {
    [[
        CREATE TABLE IF NOT EXISTS player_characters (
            id INT AUTO_INCREMENT PRIMARY KEY,
            steamid VARCHAR(50) NOT NULL,
            head VARCHAR(50) NOT NULL,
            name VARCHAR(100) UNIQUE NOT NULL,
            playermodel VARCHAR(255) DEFAULT 'models/player/Group01/male_01.mdl' NOT NULL,
            money INT DEFAULT 0 NOT NULL,
            health INT DEFAULT 100
        )
    ]]
}


-- Fonction qui exécute les requêtes du schéma
function UpdateDatabaseSchema()
    for i, queryStr in ipairs(db_schema) do
        local q = db:query(queryStr)
        function q:onSuccess(result)
            print("[DB] Query " .. i .. " executed successfully.")
        end
        function q:onError(err)
            print("[DB] Error executing query " .. i .. ": " .. err)
        end
        q:start()
    end
end

-- Optionnel : Définir une commande pour mettre à jour manuellement le schéma en jeu
concommand.Add("updateDB", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Vous n'avez pas les permissions nécessaires.")
        return
    end
    UpdateDatabaseSchema()
    print("[DB] Database schema update triggered.")
end)