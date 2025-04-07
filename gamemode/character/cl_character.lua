-- Enregistrement des polices (Roboto stylé moderne)
hook.Add("PIXEL.UI.FullyLoaded", "GM:InitCharacterUI", function()
    GM:InitializeCharacterInterface()
end)

function GM:InitializeCharacterInterface()
    PIXEL.RegisterFont("PXUI.Title", "Roboto", 24, 800)
    PIXEL.RegisterFont("PXUI.Normal", "Roboto", 18, 500)

    local function PaintBlurBackground(pnl, w, h)
        PIXEL.DrawBlur(pnl, 0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
    end

    local function OpenCharacterMenu(charList)
        local frame = vgui.Create("PIXEL.Frame")
        frame:SetSize(ScrW() * 0.9, ScrH() * 0.9)
        frame:Center()
        frame:SetTitle("")
        frame.CloseButton:Remove()
        frame:SetDraggable(false)
        frame:MakePopup()
        frame.Paint = function(self, w, h)
            PaintBlurBackground(self, w, h)
            draw.SimpleText("Menu Personnage", PIXEL.GetRealFont("PXUI.Title"), w / 2, 10, color_white, TEXT_ALIGN_CENTER)
        end

        -- Panneau de gauche : liste des personnages
        local listPanel = vgui.Create("PIXEL.ScrollPanel", frame)
        listPanel:Dock(LEFT)
        listPanel:SetWide(frame:GetWide() * 0.35)
        listPanel:DockMargin(20, 60, 10, 20)

        -- Panneau de droite : zone de détail ou de création
        local detailPanel = vgui.Create("EditablePanel", frame)
        detailPanel:Dock(FILL)
        detailPanel:DockMargin(0, 60, 20, 20)
        detailPanel.Paint = function(self, w, h)
            surface.SetDrawColor(28, 28, 28, 180)
            surface.DrawRect(0, 0, w, h)
        end

        local function ShowCharacterDetails(char)
            if not (char and char.name) then return end 
            PrintTable(char)
            detailPanel:Clear()

            local detailTitle = vgui.Create("PIXEL.Label", detailPanel)
            detailTitle:Dock(TOP)
            detailTitle:SetText(char.name)
            detailTitle:SetFont("PXUI.Title")
            detailTitle:SetTextColor(color_white)

            local modelPanel = vgui.Create("DModelPanel", detailPanel)
            modelPanel:Dock(FILL)
            modelPanel:SetModel(char.model or "models/player/kleiner.mdl")
            modelPanel:SetFOV(60)
            modelPanel:SetCamPos(Vector(45, 0, 65))
            modelPanel:SetLookAt(Vector(0, 0, 64))
            modelPanel.LayoutEntity = function(pnl, ent) ent:SetAngles(Angle(0, 35, 0)) end
                
            local playBtn = vgui.Create("PIXEL.TextButton", detailPanel)
            playBtn:Dock(BOTTOM)
            playBtn:SetTall(40)
            playBtn:DockMargin(20, 10, 20, 10)
            playBtn:SetText("Sélectionner")
            playBtn.DoClick = function()
                net.Start("SelectCharacter")
                    net.WriteUInt(tonumber(char.id), 16)
                net.SendToServer()
                frame:Remove()
            end
        end

        local function ShowCharacterCreation()
            detailPanel:Clear()

            detailTitle = vgui.Create("PIXEL.Label", detailPanel)
            detailTitle:Dock(TOP)
            detailTitle:SetText("Création d'un personnage")
            detailTitle:SetFont("PXUI.Title")
            detailTitle:SetTextColor(color_white)

            local nameEntry = vgui.Create("PIXEL.TextEntry", detailPanel)
            nameEntry:Dock(TOP)
            nameEntry:SetTall(30)
            nameEntry:SetPlaceholderText("Entrez un nom")

            local modelChoice = vgui.Create("PIXEL.ComboBox", detailPanel)
            modelChoice:Dock(TOP)
            modelChoice:SetTall(30)
            modelChoice:AddChoice("models/player/kleiner.mdl", nil, true)
            modelChoice:AddChoice("models/player/alyx.mdl")
            modelChoice:AddChoice("models/player/barney.mdl")

            local modelPanel = vgui.Create("DModelPanel", detailPanel)
            modelPanel:Dock(FILL)
            modelPanel:SetModel("models/player/kleiner.mdl")
            modelPanel:SetFOV(60)
            modelPanel:SetCamPos(Vector(45, 0, 65))
            modelPanel:SetLookAt(Vector(0, 0, 64))
            modelPanel.LayoutEntity = function(pnl, ent) ent:SetAngles(Angle(0, 35, 0)) end

            modelChoice.OnSelect = function(_, _, val)
                modelPanel:SetModel(val)
            end

            local createBtn = vgui.Create("PIXEL.TextButton", detailPanel)
            createBtn:Dock(BOTTOM)
            createBtn:SetTall(40)
            createBtn:DockMargin(20, 10, 20, 10)
            createBtn:SetText("Créer le personnage")
            createBtn:SetFont("PXUI.Normal")
            createBtn.DoClick = function()
                local name = nameEntry:GetValue()
                local mdl = modelChoice:GetSelected() or "models/player/kleiner.mdl"
                if name == "" then return end
                net.Start("CreateCharacter")
                net.WriteString(name)
                net.WriteString(mdl)
                net.SendToServer()
                frame:Remove()
            end
        end

        if charList and #charList > 0 then
            for _, char in ipairs(charList) do
                local btn = vgui.Create("PIXEL.TextButton", listPanel)
                btn:Dock(TOP)
                btn:DockMargin(0, 0, 0, 5)
                btn:SetTall(30)
                btn:SetText(char.name)
                btn:SetFont("PXUI.Normal")
                btn.DoClick = function() ShowCharacterDetails(char) end
            end
        end

        local newCharBtn = vgui.Create("PIXEL.TextButton", listPanel)
        newCharBtn:Dock(TOP)
        newCharBtn:SetTall(40)
        newCharBtn:SetText("+")
        newCharBtn:SetFont("PXUI.Title")
        newCharBtn.DoClick = ShowCharacterCreation

        -- Par défaut, si des personnages existent, on sélectionne le premier
        if not charList or #charList == 0 then
            ShowCharacterCreation()
        else
            ShowCharacterDetails(charList[1])
        end
    end

    net.Receive("OpenCharMenu", function()
        OpenCharacterMenu(net.ReadTable() or {})
    end)
end
