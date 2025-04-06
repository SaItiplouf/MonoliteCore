-- Configuration de la connexion à la base de données
local db_host = "127.0.0.1"
local db_user = "root"
local db_pass = ""
local db_name = "monolitecore"
local db_port = 3306

-- Création de la connexion mysqloo
local db = mysqloo.connect(db_host, db_user, db_pass, db_name, db_port)

-- Fonction appelée en cas de connexion réussie
function db:onConnected()
    print("MonolithCore - Database connection established")
end

-- Fonction appelée en cas d'échec de connexion
function db:onConnectionFailed(err)
    print("MonolithCore - Database failed : " .. err)
end

db:connect()