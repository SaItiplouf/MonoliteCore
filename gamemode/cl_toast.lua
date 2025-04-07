
-- Fonction d'initialisation du système de Toast qui sera appelée une fois Pixel UI chargé.
function GM:InitializeToastSystem()
    PIXEL.RegisterFont("PixelUI.NotificationFont", "Roboto", 18, 500)
    
    -- Table pour stocker les notifications actives
    self.ToastList = {}
    
    -- Configuration pour chaque état (success, warning, error)
    local toastConfig = {
        success = { icon = "icon16/tick.png",    color = Color(76, 175, 80),  sound = "buttons/button15.wav" },
        warning = { icon = "icon16/warning.png", color = Color(255, 152, 0),  sound = "buttons/button16.wav" },
        error   = { icon = "icon16/error.png",   color = Color(244, 67, 54),  sound = "buttons/button10.wav" },
    }
    
    self.ToastDarkMode = true      -- Active le darkmode pour les toasts
    self.ToastProgressBar = true   -- Active l'affichage de la barre de progression

    -- Redéfinir GM:Toast pour utiliser Pixel UI avec notre système de notifications
    function GM:Toast(message, state, duration)
        state = string.lower(state or "success")
        local config = toastConfig[state] or toastConfig["success"]

        -- Jouer le son associé
        surface.PlaySound(config.sound)

        duration = duration or 5
        table.insert(self.ToastList, {
            text = message,
            state = state,
            config = config,
            time = SysTime(),
            expire = SysTime() + duration,
            duration = duration -- durée totale pour le calcul de la barre de progression
        })
    end
    
    local oldHUDPaint = self.HUDPaint
    function GM:HUDPaint()
        if oldHUDPaint then oldHUDPaint(self) end

        if not self.ToastList or #self.ToastList == 0 then return end

        local margin  = PIXEL.Scale(10)   -- marge par rapport au bord de l'écran
        local padding = PIXEL.Scale(12)   -- padding intérieur (plus grand pour un toast plus spacieux)
        local radius  = PIXEL.Scale(8)    -- rayon des coins arrondis
        local screenW = ScrW()
        local y = margin                -- position verticale de départ (en haut de l'écran)

        for i, toast in ipairs(self.ToastList) do
            local remaining = toast.expire - SysTime()
            local alpha = 255
            local fadeTime = 1            -- temps de fondu (1 seconde)
            if remaining < fadeTime then
                alpha = math.floor(math.Clamp(remaining / fadeTime, 0, 1) * 255)
            end

            -- Préparation du texte
            local text = toast.text
            local font = "PixelUI.NotificationFont"
            surface.SetFont(PIXEL.GetRealFont(font))
            local textW, textH = surface.GetTextSize(text)

            -- Définir la taille de l'icône (plus grande)
            local iconSize = PIXEL.Scale(24)
            -- Calcul de la largeur totale : icône + espace + texte + padding double
            local totalWidth = textW + iconSize + (3 * padding)
            -- Hauteur du toast : tenir compte du texte ou de l'icône et ajouter un espace pour la barre de progression
            local boxH = math.max(textH + 2 * padding, iconSize + 2 * padding) + PIXEL.Scale(10)

            -- Positionnement : en haut à droite de l'écran
            local x = screenW - totalWidth - margin

            -- Définir la couleur de fond en fonction du mode (dark ou light)
            local bgColor = self.ToastDarkMode and Color(40, 40, 40, alpha) or Color(255, 255, 255, alpha)
            -- La couleur d'accent (pour la barre de progression et bordures éventuelles)
            local accentColor = Color(toast.config.color.r, toast.config.color.g, toast.config.color.b, alpha)

            -- Dessiner le fond arrondi
            PIXEL.DrawRoundedBox(radius, x, y, totalWidth, boxH, bgColor)

            -- Dessiner l'icône à gauche
            local iconX = x + padding
            local iconY = y + padding
            local iconMat = Material(toast.config.icon)
            surface.SetMaterial(iconMat)
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)

            -- Dessiner le texte à côté de l'icône
            local textX = iconX + iconSize + padding
            -- Centrage vertical du texte dans la zone (ajustement possible)
            local textY = y + (boxH - textH - PIXEL.Scale(10)) / 2
            local textColor = Color(255, 255, 255, alpha)
            PIXEL.DrawShadowText(text, font, textX, textY, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, PIXEL.Scale(2), 100)

            -- Affichage de la barre de progression en bas
            if self.ToastProgressBar then
                local progressBarHeight = PIXEL.Scale(4)
                local progressBarWidth = totalWidth - 2 * padding
                local progressX = x + padding
                local progressY = y + boxH - progressBarHeight - padding / 2
                local progressFraction = math.Clamp((toast.expire - SysTime()) / toast.duration, 0, 1)

                -- Fond de la barre (selon le mode)
                local progressBg = self.ToastDarkMode and Color(60, 60, 60, alpha) or Color(200, 200, 200, alpha)
                PIXEL.DrawRoundedBox(radius / 2, progressX, progressY, progressBarWidth, progressBarHeight, progressBg)
                -- Barre de progression colorée
                PIXEL.DrawRoundedBox(radius / 2, progressX, progressY, progressBarWidth * progressFraction, progressBarHeight, accentColor)
            end

            y = y + boxH + margin
        end

        -- Nettoyage des toasts expirés
        for i = #self.ToastList, 1, -1 do
            if SysTime() >= self.ToastList[i].expire then
                table.remove(self.ToastList, i)
            end
        end
    end
    
    -- Exemple : afficher un toast de test une fois le système initialisé
    self:Toast("Welcome to MonoliteCore gamemode")
end

hook.Add("PIXEL.UI.FullyLoaded", "GM:InitToastSystem", function()
        GM:InitializeToastSystem()
end)

-- Gestion du net message pour les toast (s'il provient du serveur)
net.Receive("DBToast", function(len)
    local msg = net.ReadString()
    local state = net.ReadString() 
    GAMEMODE:Toast(msg, state)
end)
