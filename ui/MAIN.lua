--[[
    Delta UI v2 Rebirth
    Recriado fielmente a partir das capturas de tela.
    Funcionalidades: Editor, Script Hub, Cloud, Logs e Minimização.
]]

local DeltaV2 = {}

-- Serviços
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Certificar-se de que a pasta de salvamento existe
if makefolder then
    pcall(function()
        makefolder("Deltav2")
        makefolder("Deltav2/Scripts")
    end)
end

-- Função para criar UI Arrastável
local function makeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function DeltaV2:Init()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaV2_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    -- Icone para quando estiver minimizado
    local MiniIcon = Instance.new("ImageButton")
    MiniIcon.Name = "MiniIcon"
    MiniIcon.Size = UDim2.new(0, 50, 0, 50)
    MiniIcon.Position = UDim2.new(0.5, -25, 0.1, 0)
    MiniIcon.BackgroundColor3 = Color3.fromRGB(80, 40, 200)
    MiniIcon.Visible = false
    MiniIcon.Image = "rbxassetid://10734950309" -- Icone Delta
    Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(1, 0)
    MiniIcon.Parent = ScreenGui
    makeDraggable(MiniIcon, MiniIcon)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame
    makeDraggable(TopBar, MainFrame)

    local DotsContainer = Instance.new("Frame")
    DotsContainer.Size = UDim2.new(0, 100, 1, 0)
    DotsContainer.Position = UDim2.new(0, 15, 0, 0)
    DotsContainer.BackgroundTransparency = 1
    DotsContainer.Parent = TopBar

    local function createDot(color, pos)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 24, 0, 24)
        dot.Position = pos
        dot.BackgroundColor3 = color
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        dot.Parent = DotsContainer
    end

    createDot(Color3.fromRGB(90, 40, 240), UDim2.new(0, 0, 0.5, -12)) -- Roxo
    createDot(Color3.fromRGB(240, 50, 50), UDim2.new(0, 30, 0.5, -12)) -- Vermelho
    createDot(Color3.fromRGB(240, 200, 60), UDim2.new(0, 60, 0.5, -12)) -- Amarelo

    local Title = Instance.new("TextLabel")
    Title.Text = "Delta"
    Title.TextColor3 = Color3.fromRGB(150, 100, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.Position = UDim2.new(0, 110, 0.5, -12)
    Title.Size = UDim2.new(0, 100, 0, 24)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -47, 0.5, -16)
    CloseBtn.BackgroundTransparency = 0
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CloseBtn.Image = "rbxassetid://10747384394" -- Logout icon
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
    CloseBtn.Parent = TopBar

    -- Tabs Sidebar (Superior)
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(0, 180, 0, 40)
    TabsContainer.Position = UDim2.new(0, 15, 0, 50)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.Parent = MainFrame

    local function createTabIcon(id, pos, isActive)
        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(0, 34, 0, 34)
        btn.Position = pos
        btn.BackgroundColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
        btn.Image = id
        btn.ImageColor3 = isActive and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Enabled = isActive
        stroke.Parent = btn
        
        btn.Parent = TabsContainer
        return btn
    end

    local TabEditor = createTabIcon("rbxassetid://10747373176", UDim2.new(0, 0, 0, 0), true)
    local TabScripts = createTabIcon("rbxassetid://10747372931", UDim2.new(0, 44, 0, 0), false)
    local TabCloud = createTabIcon("rbxassetid://10747383033", UDim2.new(0, 88, 0, 0), false)
    local TabLogs = createTabIcon("rbxassetid://10747372702", UDim2.new(0, 132, 0, 0), false)

    -- Container de Conteúdo
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -30, 1, -105)
    Content.Position = UDim2.new(0, 15, 0, 95)
    Content.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 12)
    Content.Parent = MainFrame

    --------------------------------------------------------------------
    -- EDITOR PAGE (Padrão)
    --------------------------------------------------------------------
    local EditorPage = Instance.new("Frame")
    EditorPage.Size = UDim2.new(1, 0, 1, 0)
    EditorPage.BackgroundTransparency = 1
    EditorPage.Parent = Content

    local ScriptList = Instance.new("Frame")
    ScriptList.Size = UDim2.new(0, 120, 0, 25)
    ScriptList.Position = UDim2.new(0, 10, 0, 10)
    ScriptList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", ScriptList).CornerRadius = UDim.new(0, 6)
    ScriptList.Parent = EditorPage

    local ScriptTitle = Instance.new("TextLabel")
    ScriptTitle.Text = "Script 1"
    ScriptTitle.Size = UDim2.new(1, -20, 1, 0)
    ScriptTitle.Position = UDim2.new(0, 5, 0, 0)
    ScriptTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    ScriptTitle.BackgroundTransparency = 1
    ScriptTitle.Font = Enum.Font.Gotham
    ScriptTitle.TextSize = 12
    ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
    ScriptTitle.Parent = ScriptList

    local AddBtn = Instance.new("TextButton")
    AddBtn.Text = "+"
    AddBtn.Size = UDim2.new(0, 20, 0, 20)
    AddBtn.Position = UDim2.new(0, 135, 0, 12)
    AddBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    AddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", AddBtn).CornerRadius = UDim.new(0, 4)
    AddBtn.Parent = EditorPage

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0, 350, 0, 180)
    TextBox.Position = UDim2.new(0, 10, 0, 40)
    TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TextBox.TextColor3 = Color3.fromRGB(100, 255, 150)
    TextBox.Text = "Thanks use delta ui V2\nmade by luay(joaopk)\nmore: luau.gt.tc"
    TextBox.Font = Enum.Font.Code
    TextBox.TextSize = 14
    TextBox.ClearTextOnFocus = false
    TextBox.MultiLine = true
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.TextYAlignment = Enum.TextYAlignment.Top
    Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 8)
    TextBox.Parent = EditorPage

    -- Info Panels (Direita)
    local NetworkPanel = Instance.new("Frame")
    NetworkPanel.Size = UDim2.new(0, 185, 0, 85)
    NetworkPanel.Position = UDim2.new(1, -195, 0, 40)
    NetworkPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", NetworkPanel).CornerRadius = UDim.new(0, 8)
    NetworkPanel.Parent = EditorPage

    local NetTitle = Instance.new("TextLabel")
    NetTitle.Text = "Network"
    NetTitle.Size = UDim2.new(1, -20, 0, 25)
    NetTitle.Position = UDim2.new(0, 10, 0, 5)
    NetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NetTitle.Font = Enum.Font.GothamBold
    NetTitle.TextSize = 20
    NetTitle.BackgroundTransparency = 1
    NetTitle.TextXAlignment = Enum.TextXAlignment.Left
    NetTitle.Parent = NetworkPanel

    local NetStats = Instance.new("TextLabel")
    NetStats.Text = "Client status information\nN/A FPS\nN/A MS Ping\nN/A Players"
    NetStats.Size = UDim2.new(1, -20, 0, 50)
    NetStats.Position = UDim2.new(0, 10, 0, 30)
    NetStats.TextColor3 = Color3.fromRGB(150, 150, 150)
    NetStats.Font = Enum.Font.Gotham
    NetStats.TextSize = 12
    NetStats.BackgroundTransparency = 1
    NetStats.TextXAlignment = Enum.TextXAlignment.Left
    NetStats.Parent = NetworkPanel

    -- Infinite Yield Card
    local IYPanel = Instance.new("Frame")
    IYPanel.Size = UDim2.new(0, 185, 0, 60)
    IYPanel.Position = UDim2.new(1, -195, 0, 135)
    IYPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", IYPanel).CornerRadius = UDim.new(0, 8)
    IYPanel.Parent = EditorPage

    local IYTitle = Instance.new("TextLabel")
    IYTitle.Text = "INFINITE YIELD"
    IYTitle.Size = UDim2.new(1, -10, 0, 15)
    IYTitle.Position = UDim2.new(0, 10, 0, 5)
    IYTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    IYTitle.Font = Enum.Font.GothamBold
    IYTitle.TextSize = 12
    IYTitle.BackgroundTransparency = 1
    IYTitle.TextXAlignment = Enum.TextXAlignment.Left
    IYTitle.Parent = IYPanel

    local IYSub = Instance.new("TextLabel")
    IYSub.Text = "an admin script dedicated to provide the necessities of exploit."
    IYSub.Size = UDim2.new(1, -20, 0, 20)
    IYSub.Position = UDim2.new(0, 10, 0, 20)
    IYSub.TextColor3 = Color3.fromRGB(180, 180, 180)
    IYSub.TextSize = 8
    IYSub.TextWrapped = true
    IYSub.BackgroundTransparency = 1
    IYSub.TextXAlignment = Enum.TextXAlignment.Left
    IYSub.Parent = IYPanel

    local IYExec = Instance.new("TextButton")
    IYExec.Text = "Execute"
    IYExec.Size = UDim2.new(0, 70, 0, 18)
    IYExec.Position = UDim2.new(0, 10, 0, 40)
    IYExec.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    IYExec.TextColor3 = Color3.fromRGB(255, 255, 255)
    IYExec.TextSize = 12
    Instance.new("UICorner", IYExec).CornerRadius = UDim.new(0, 8)
    local iyStroke = Instance.new("UIStroke")
    iyStroke.Color = Color3.fromRGB(0, 150, 80)
    iyStroke.Thickness = 2
    iyStroke.Parent = IYExec
    IYExec.Parent = IYPanel

    -- Botões de Ação Inferiores
    local ExecuteBtn = Instance.new("TextButton")
    ExecuteBtn.Name = "Execute"
    ExecuteBtn.Text = "Execute"
    ExecuteBtn.Size = UDim2.new(0, 130, 0, 38)
    ExecuteBtn.Position = UDim2.new(0, 10, 1, -48)
    ExecuteBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 100)
    ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExecuteBtn.TextSize = 22
    ExecuteBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", ExecuteBtn).CornerRadius = UDim.new(0, 10)
    local exStroke = Instance.new("UIStroke")
    exStroke.Color = Color3.fromRGB(120, 80, 255)
    exStroke.Thickness = 2
    exStroke.Parent = ExecuteBtn
    ExecuteBtn.Parent = EditorPage

    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Name = "Save"
    SaveBtn.Text = "Save"
    SaveBtn.Size = UDim2.new(0, 130, 0, 38)
    SaveBtn.Position = UDim2.new(0, 150, 1, -48)
    SaveBtn.BackgroundColor3 = Color3.fromRGB(25, 45, 35)
    SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveBtn.TextSize = 22
    SaveBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 10)
    local svStroke = Instance.new("UIStroke")
    svStroke.Color = Color3.fromRGB(0, 200, 100)
    svStroke.Thickness = 2
    svStroke.Parent = SaveBtn
    SaveBtn.Parent = EditorPage

    --------------------------------------------------------------------
    -- SCRIPTS HUB PAGE
    --------------------------------------------------------------------
    local ScriptsPage = Instance.new("Frame")
    ScriptsPage.Size = UDim2.new(1, 0, 1, 0)
    ScriptsPage.BackgroundTransparency = 1
    ScriptsPage.Visible = false
    ScriptsPage.Parent = Content

    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "search"
    SearchBox.Text = ""
    SearchBox.Size = UDim2.new(1, -20, 0, 30)
    SearchBox.Position = UDim2.new(0, 10, 0, 10)
    SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)
    SearchBox.Parent = ScriptsPage

    local ScriptCard = Instance.new("Frame")
    ScriptCard.Size = UDim2.new(0, 180, 0, 80)
    ScriptCard.Position = UDim2.new(0, 10, 0, 50)
    ScriptCard.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", ScriptCard).CornerRadius = UDim.new(0, 8)
    ScriptCard.Parent = ScriptsPage

    local CardTitle = Instance.new("TextLabel")
    CardTitle.Text = "Script 1"
    CardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    CardTitle.Font = Enum.Font.GothamBold
    CardTitle.Position = UDim2.new(0, 10, 0, 5)
    CardTitle.Size = UDim2.new(1, -10, 0, 15)
    CardTitle.BackgroundTransparency = 1
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = ScriptCard

    local CardDesc = Instance.new("TextLabel")
    CardDesc.Text = "no description\nUse:\n--[[\nyour description\n]]"
    CardDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    CardDesc.TextSize = 8
    CardDesc.Position = UDim2.new(0, 10, 0, 20)
    CardDesc.Size = UDim2.new(1, -10, 0, 30)
    CardDesc.BackgroundTransparency = 1
    CardDesc.TextXAlignment = Enum.TextXAlignment.Left
    CardDesc.Parent = ScriptCard

    local CardExec = Instance.new("TextButton")
    CardExec.Text = "Execute"
    CardExec.Size = UDim2.new(0, 60, 0, 20)
    CardExec.Position = UDim2.new(0, 10, 1, -25)
    CardExec.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    CardExec.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", CardExec).CornerRadius = UDim.new(0, 8)
    local cdStroke = Instance.new("UIStroke")
    cdStroke.Color = Color3.fromRGB(0, 180, 100)
    cdStroke.Parent = CardExec
    CardExec.Parent = ScriptCard

    --------------------------------------------------------------------
    -- LOGS PAGE
    --------------------------------------------------------------------
    local LogsPage = Instance.new("Frame")
    LogsPage.Size = UDim2.new(1, 0, 1, 0)
    LogsPage.BackgroundTransparency = 1
    LogsPage.Visible = false
    LogsPage.Parent = Content

    local LogTitle = Instance.new("TextLabel")
    LogTitle.Text = "logs"
    LogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogTitle.Font = Enum.Font.GothamBold
    LogTitle.Position = UDim2.new(0, 10, 0, 5)
    LogTitle.Size = UDim2.new(0, 100, 0, 20)
    LogTitle.BackgroundTransparency = 1
    LogTitle.TextXAlignment = Enum.TextXAlignment.Left
    LogTitle.Parent = LogsPage

    local LogBox = Instance.new("ScrollingFrame")
    LogBox.Size = UDim2.new(0, 330, 0, 170)
    LogBox.Position = UDim2.new(0, 10, 0, 30)
    LogBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", LogBox).CornerRadius = UDim.new(0, 8)
    LogBox.Parent = LogsPage

    local ClearBtn = Instance.new("TextButton")
    ClearBtn.Text = "Clear"
    ClearBtn.Size = UDim2.new(0, 60, 0, 20)
    ClearBtn.Position = UDim2.new(0, 10, 1, -35)
    ClearBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
    ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 8)
    ClearBtn.Parent = LogsPage

    --------------------------------------------------------------------
    -- LÓGICA DE FUNCIONAMENTO
    --------------------------------------------------------------------
    
    -- Troca de Abas
    local function switchTab(tabName)
        EditorPage.Visible = (tabName == "Editor")
        ScriptsPage.Visible = (tabName == "Scripts")
        LogsPage.Visible = (tabName == "Logs")
        
        -- Reset visual icons
        TabEditor.BackgroundColor3 = (tabName == "Editor") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
        TabEditor.ImageColor3 = (tabName == "Editor") and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        TabEditor.UIStroke.Enabled = (tabName == "Editor")

        TabScripts.BackgroundColor3 = (tabName == "Scripts") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
        TabScripts.ImageColor3 = (tabName == "Scripts") and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        TabScripts.UIStroke.Enabled = (tabName == "Scripts")

        TabLogs.BackgroundColor3 = (tabName == "Logs") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
        TabLogs.ImageColor3 = (tabName == "Logs") and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        TabLogs.UIStroke.Enabled = (tabName == "Logs")
    end

    TabEditor.MouseButton1Click:Connect(function() switchTab("Editor") end)
    TabScripts.MouseButton1Click:Connect(function() switchTab("Scripts") end)
    TabLogs.MouseButton1Click:Connect(function() switchTab("Logs") end)

    -- Execução de Script
    ExecuteBtn.MouseButton1Click:Connect(function()
        local code = TextBox.Text
        local success, err = pcall(function()
            loadstring(code)()
        end)
        if not success then
            local errLabel = Instance.new("TextLabel")
            errLabel.Text = "[!] Error: " .. tostring(err)
            errLabel.Size = UDim2.new(1, -10, 0, 20)
            errLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            errLabel.BackgroundTransparency = 1
            errLabel.Parent = LogBox
        end
    end)

    -- Salvar Script
    SaveBtn.MouseButton1Click:Connect(function()
        if writefile then
            local name = ScriptTitle.Text .. ".lua"
            pcall(function()
                writefile("Deltav2/Scripts/" .. name, TextBox.Text)
                print("Delta v2: Salvo com sucesso em " .. name)
            end)
        else
            print("Delta v2: Seu executor não suporta writefile.")
        end
    end)

    -- Fechar / Minimizar para Bolinha
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MiniIcon.Visible = true
        MiniIcon.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + (MainFrame.AbsoluteSize.X / 2) - 25, 0, MainFrame.AbsolutePosition.Y)
    end)

    MiniIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MiniIcon.Visible = false
    end)

    -- Update Network Stats
    task.spawn(function()
        while task.wait(1) do
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.01))
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local players = #game:GetService("Players"):GetPlayers()
            NetStats.Text = "Client status information\n" .. fps .. " FPS\n" .. ping .. " MS Ping\n" .. players .. " Players"
        end
    end)

    -- Função para limpar os Logs
    ClearBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(LogBox:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end)

    -- Botão Infinite Yield (Exemplo de funcionalidade do Print)
    IYExec.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)

    -- Efeito de Hover nos botões de Tab
    local function addHover(btn)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageTransparency = 0.5}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
        end)
    end

    addHover(TabEditor)
    addHover(TabScripts)
    addHover(TabCloud)
    addHover(TabLogs)

end -- Fim da função Init

-- Executar a UI
DeltaV2:Init()

return DeltaV2
