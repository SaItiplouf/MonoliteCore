
-- Fonction d'initialisation du système de Toast qui sera appelée une fois Pixel UI chargé.
function GM:InitializeToastSystem()
    PIXEL.UI.RegisterFont("PixelUI.NotificationFont", "Roboto", 18, 500)

    print("Fonction initialize")
    
    -- Table pour stocker les notifications actives
    self.ToastList = {}
    
    -- Configuration pour chaque état (success, warning, error)
    local toastConfig = {
        success = { icon = "icon16/tick.png",    color = Color(76,175,80),  sound = "buttons/button15.wav" },
        warning = { icon = "icon16/warning.png", color = Color(255,152,0),  sound = "buttons/button16.wav" },
        error   = { icon = "icon16/error.png",   color = Color(244,67,54),  sound = "buttons/button10.wav" },
    }
    
    -- Redéfinir GM:Toast pour utiliser Pixel UI avec notre système de notifications
    function GM:Toast(message, state)
        print("toast")
        state = string.lower(state or "success")
        local config = toastConfig[state] or toastConfig["success"]

        -- Jouer le son associé
        surface.PlaySound(config.sound)
        
        -- Ajouter la nouvelle notification à la liste
        local duration = 5 -- durée d'affichage en secondes
        table.insert(self.ToastList, {
            text = message,
            state = state,
            config = config,
            time = SysTime(),
            expire = SysTime() + duration
        })
    end
    
    local oldHUDPaint = self.HUDPaint
    function GM:HUDPaint()
        if oldHUDPaint then oldHUDPaint(self) end
        
        if not self.ToastList or #self.ToastList == 0 then return end
        
        local margin = PIXEL.Scale(10)    -- marge par rapport au bord de l'écran
        local padding = PIXEL.Scale(8)    -- espacement intérieur du toast
        local radius  = PIXEL.Scale(6)    -- rayon des coins arrondis
        local screenW = ScrW()
        local y = margin                -- position verticale de départ (en haut)

        for i, toast in ipairs(self.ToastList) do
            local remaining = toast.expire - SysTime()
            local alpha = 255
            local fadeTime = 1            -- durée du fondu (1 seconde)
            if remaining < fadeTime then
                alpha = math.floor(math.Clamp(remaining / fadeTime, 0, 1) * 255)
            end

            local text = toast.text
            local font = "PixelUI.NotificationFont" -- police enregistrée pour les notifications
            surface.SetFont(PIXEL.GetRealFont(font))
            local textW, textH = surface.GetTextSize(text)
            local boxW = textW + 2 * padding
            local boxH = textH + 2 * padding

            -- Positionner le toast en haut à droite
            local x = screenW - boxW - margin

            -- Couleur du fond selon l'état, avec gestion de l'alpha pour le fondu
            local bgColor = Color(toast.config.color.r, toast.config.color.g, toast.config.color.b, alpha)
            -- Texte en blanc
            local textColor = Color(255, 255, 255, alpha)

            -- Dessiner le fond arrondi
            PIXEL.DrawRoundedBox(radius, x, y, boxW, boxH, bgColor)
            -- Dessiner le texte centré avec une ombre pour plus de lisibilité
            PIXEL.DrawShadowText(text, font, x + boxW/2, y + boxH/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, PIXEL.Scale(2), 100)

            y = y + boxH + margin  -- décaler pour le toast suivant
        end

        -- Retirer les notifications expirées
        for i = #self.ToastList, 1, -1 do
            if SysTime() >= self.ToastList[i].expire then
                table.remove(self.ToastList, i)
            end
        end
    end
    
    -- Exemple : afficher un toast de test une fois le système initialisé
    self:Toast("Pixel UI est chargé et les toasts fonctionnent !", "success")
end

-- Si Pixel UI est déjà chargé, initialiser immédiatement, sinon attendre via le hook
if PIXEL and PIXEL.UI then
    print("Insta load pixel")
    GM:InitializeToastSystem()
else
    hook.Add("PIXEL.UI.FullyLoaded", "GM:InitToastSystem", function()
        print("Lazy load pixel")
        GM:InitializeToastSystem()
    end)
end

-- Gestion du net message pour les toast (s'il provient du serveur)
net.Receive("DBToast", function(len)
    local msg = net.ReadString()
    local state = net.ReadString() 
    GAMEMODE:Toast(msg, state)
end)
