--[[
    Delta UI v2 Rebirth - Versão Corrigida e Atualizada
    Feito com amor pelo luay (joaopk)
    Correções:
    - Cloud totalmente funcional (busca GitHub + cards dinâmicos + search bar)
    - Checkbox agora visual (pode ser expandido depois com gameId)
    - Botões Execute/Save reposicionados (não mais pra baixo/fora da tela)
    - TextBox de nome no topo do Editor
    - Botão "+" para criar novo script em branco
    - Save usa o nome do TextBox (com .lua automático)
    - Execute continua loadstring(código)()
]]

local DeltaV2 = {}

-- Serviços
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Proteção
local parent = (gethui and gethui()) or CoreGui

if parent:FindFirstChild("DeltaV2_UI") then
    parent.DeltaV2_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaV2_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parent

-- Variáveis
local isMinimized = false
local currentTab = "Editor"
local scriptsPath = "Deltav2/Scripts/"
local cloudScripts = {}

if makefolder then
    pcall(function()
        makefolder("Deltav2")
        makefolder(scriptsPath)
    end)
end

-- Utilitários
local function createTween(obj, info, goal)
    local tween = TweenService:Create(obj, TweenInfo.new(unpack(info)), goal)
    tween:Play()
    return tween
end

local function makeDraggable(obj, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle = dragHandle or obj

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- UI Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 350)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

makeDraggable(MainFrame)

-- Botão Minimizar
local ExitBtn = Instance.new("ImageButton")
ExitBtn.Size = UDim2.new(0, 32, 0, 32)
ExitBtn.Position = UDim2.new(1, -45, 0, 10)
ExitBtn.BackgroundTransparency = 1
ExitBtn.Image = "rbxassetid://10747384394"
ExitBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
ExitBtn.Parent = MainFrame

-- Orb Minimizado
local MinimizedOrb = Instance.new("ImageButton")
MinimizedOrb.Size = UDim2.new(0, 50, 0, 50)
MinimizedOrb.Position = UDim2.new(0.05, 0, 0.5, 0)
MinimizedOrb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizedOrb.Visible = false
MinimizedOrb.Image = "rbxassetid://15286283582"
MinimizedOrb.Parent = ScreenGui
Instance.new("UICorner", MinimizedOrb).CornerRadius = UDim.new(1, 0)
makeDraggable(MinimizedOrb)

-- Título + Bolinhas
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 100, 0, 30)
Title.Position = UDim2.new(0, 110, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Delta"
Title.TextColor3 = Color3.fromRGB(160, 90, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local function createDot(color, pos)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 25, 0, 25)
    dot.Position = pos
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Parent = MainFrame
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
end

createDot(Color3.fromRGB(110, 40, 255), UDim2.new(0, 15, 0, 10))
createDot(Color3.fromRGB(255, 60, 60), UDim2.new(0, 45, 0, 10))
createDot(Color3.fromRGB(255, 210, 60), UDim2.new(0, 75, 0, 10))

-- Abas
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 200, 0, 40)
TabsFrame.Position = UDim2.new(0, 15, 0, 45)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainFrame

local function createTabIcon(id, pos, name)
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Image = id
    btn.Parent = TabsFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 1
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        currentTab = name
    end)
    return btn
end

local EditorTab = createTabIcon("rbxassetid://10734949015", UDim2.new(0, 0, 0, 0), "Editor")
local SavedTab = createTabIcon("rbxassetid://10723346958", UDim2.new(0, 40, 0, 0), "Saved")
local CloudTab = createTabIcon("rbxassetid://10723345518", UDim2.new(0, 80, 0, 0), "Cloud")
local LogsTab = createTabIcon("rbxassetid://10747373176", UDim2.new(0, 120, 0, 0), "Logs")

local function setTabActive(btn)
    for _, v in pairs(TabsFrame:GetChildren()) do
        if v:IsA("ImageButton") then v.UIStroke.Transparency = 1 end
    end
    btn.UIStroke.Transparency = 0
end
setTabActive(EditorTab)

-- Container
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -30, 1, -100)
Content.Position = UDim2.new(0, 15, 0, 90)
Content.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Content.Parent = MainFrame
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 10)

-- ======================== EDITOR ========================
local EditorPage = Instance.new("Frame")
EditorPage.Size = UDim2.new(1, 0, 1, 0)
EditorPage.BackgroundTransparency = 1
EditorPage.Visible = true
EditorPage.Parent = Content

-- Nome do Script (NOVO)
local ScriptNameBox = Instance.new("TextBox")
ScriptNameBox.Size = UDim2.new(0.4, 0, 0, 30)
ScriptNameBox.Position = UDim2.new(0, 10, 0, 5)
ScriptNameBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScriptNameBox.PlaceholderText = "Nome do Script"
ScriptNameBox.Text = "Untitled"
ScriptNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptNameBox.TextSize = 16
ScriptNameBox.Font = Enum.Font.Gotham
ScriptNameBox.Parent = EditorPage
Instance.new("UICorner", ScriptNameBox).CornerRadius = UDim.new(0, 8)

-- Botão + (NOVO)
local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 30, 0, 30)
PlusBtn.Position = UDim2.new(0.4, 15, 0, 5)
PlusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(160, 90, 255)
PlusBtn.TextSize = 20
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = EditorPage
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 8)
PlusBtn.MouseButton1Click:Connect(function()
    SourceInput.Text = "-- Novo Script\n-- Feito com Delta v2"
    ScriptNameBox.Text = "Untitled_" .. os.time()
end)

-- Script Box
local ScriptBox = Instance.new("ScrollingFrame")
ScriptBox.Size = UDim2.new(0.65, -10, 0.65, -60)
ScriptBox.Position = UDim2.new(0, 10, 0, 45)
ScriptBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScriptBox.BorderSizePixel = 0
ScriptBox.Parent = EditorPage
Instance.new("UICorner", ScriptBox).CornerRadius = UDim.new(0, 8)

local SourceInput = Instance.new("TextBox")
SourceInput.Size = UDim2.new(1, -10, 1, -10)
SourceInput.Position = UDim2.new(0, 5, 0, 5)
SourceInput.BackgroundTransparency = 1
SourceInput.MultiLine = true
SourceInput.Text = "Thanks use delta ui V2\nmade by luay(joaopk)\nmore: luau.gt.tc"
SourceInput.TextColor3 = Color3.fromRGB(100, 255, 100)
SourceInput.TextSize = 14
SourceInput.Font = Enum.Font.Code
SourceInput.TextXAlignment = Enum.TextXAlignment.Left
SourceInput.TextYAlignment = Enum.TextYAlignment.Top
SourceInput.ClearTextOnFocus = false
SourceInput.Parent = ScriptBox

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0.35, -10, 0.65, -60)
Sidebar.Position = UDim2.new(0.65, 5, 0, 45)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = EditorPage

-- Network Card
local NetCard = Instance.new("Frame")
NetCard.Size = UDim2.new(1, 0, 0, 100)
NetCard.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
NetCard.Parent = Sidebar
Instance.new("UICorner", NetCard).CornerRadius = UDim.new(0, 8)

local NetTitle = Instance.new("TextLabel")
NetTitle.Size = UDim2.new(1, -10, 0, 30)
NetTitle.Position = UDim2.new(0, 10, 0, 5)
NetTitle.Text = "Network"
NetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
NetTitle.TextSize = 18
NetTitle.Font = Enum.Font.GothamBold
NetTitle.BackgroundTransparency = 1
NetTitle.TextXAlignment = Enum.TextXAlignment.Left
NetTitle.Parent = NetCard

local NetInfo = Instance.new("TextLabel")
NetInfo.Size = UDim2.new(1, -10, 0, 60)
NetInfo.Position = UDim2.new(0, 10, 0, 35)
NetInfo.Text = "Client status information\nN/A FPS\nN/A MS Ping\nN/A Players"
NetInfo.TextColor3 = Color3.fromRGB(150, 150, 200)
NetInfo.TextSize = 12
NetInfo.Font = Enum.Font.Gotham
NetInfo.BackgroundTransparency = 1
NetInfo.TextXAlignment = Enum.TextXAlignment.Left
NetInfo.Parent = NetCard

-- Infinite Yield
local IYCard = Instance.new("Frame")
IYCard.Size = UDim2.new(1, 0, 0, 80)
IYCard.Position = UDim2.new(0, 0, 0, 110)
IYCard.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
IYCard.Parent = Sidebar
Instance.new("UICorner", IYCard).CornerRadius = UDim.new(0, 8)

local IYTitle = Instance.new("TextLabel")
IYTitle.Size = UDim2.new(1, -10, 0, 25)
IYTitle.Position = UDim2.new(0, 10, 0, 5)
IYTitle.Text = "INFINITE YIELD"
IYTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
IYTitle.Font = Enum.Font.GothamBold
IYTitle.BackgroundTransparency = 1
IYTitle.TextXAlignment = Enum.TextXAlignment.Left
IYTitle.Parent = IYCard

local IYExec = Instance.new("TextButton")
IYExec.Size = UDim2.new(0, 80, 0, 25)
IYExec.Position = UDim2.new(0, 10, 1, -35)
IYExec.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
IYExec.Text = "Execute"
IYExec.TextColor3 = Color3.fromRGB(255, 255, 255)
IYExec.Parent = IYCard
Instance.new("UICorner", IYExec).CornerRadius = UDim.new(0, 12)
local IYS = Instance.new("UIStroke", IYExec)
IYS.Color = Color3.fromRGB(0, 150, 80)
IYS.Thickness = 2

IYExec.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

-- Botões Execute e Save (REPOSICIONADOS)
local ExecuteBtn = Instance.new("TextButton")
ExecuteBtn.Size = UDim2.new(0, 150, 0, 45)
ExecuteBtn.Position = UDim2.new(0, 10, 0.8, 5)
ExecuteBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
ExecuteBtn.Text = "Execute"
ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteBtn.TextSize = 24
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.Parent = EditorPage
Instance.new("UICorner", ExecuteBtn).CornerRadius = UDim.new(0, 10)
local EBS = Instance.new("UIStroke", ExecuteBtn)
EBS.Color = Color3.fromRGB(80, 40, 255)
EBS.Thickness = 2

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 150, 0, 45)
SaveBtn.Position = UDim2.new(0, 170, 0.8, 5)
SaveBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 30)
SaveBtn.Text = "Save"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.TextSize = 24
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.Parent = EditorPage
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 10)
local SBS = Instance.new("UIStroke", SaveBtn)
SBS.Color = Color3.fromRGB(0, 150, 80)
SBS.Thickness = 2

-- Lógica Execute / Save
ExecuteBtn.MouseButton1Click:Connect(function()
    local success, err = pcall(function()
        loadstring(SourceInput.Text)()
    end)
    if not success then warn("Delta v2 Error: " .. err) end
end)

SaveBtn.MouseButton1Click:Connect(function()
    if writefile then
        local name = ScriptNameBox.Text
        if name == "" or name == "Untitled" then name = "Script_" .. os.time() end
        if not name:find("%.lua$") then name = name .. ".lua" end
        pcall(function()
            writefile(scriptsPath .. name, SourceInput.Text)
        end)
    end
end)

-- ======================== SAVED ========================
local SavedPage = Instance.new("Frame")
SavedPage.Size = UDim2.new(1, 0, 1, 0)
SavedPage.BackgroundTransparency = 1
SavedPage.Visible = false
SavedPage.Parent = Content

local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(1, -20, 0, 30)
SearchBar.Position = UDim2.new(0, 10, 0, 10)
SearchBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SearchBar.PlaceholderText = " search"
SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBar.TextXAlignment = Enum.TextXAlignment.Left
SearchBar.Parent = SavedPage
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 8)

local SavedList = Instance.new("ScrollingFrame")
SavedList.Size = UDim2.new(1, -20, 1, -50)
SavedList.Position = UDim2.new(0, 10, 0, 50)
SavedList.BackgroundTransparency = 1
SavedList.ScrollBarThickness = 4
SavedList.Parent = SavedPage
local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.new(0, 150, 0, 100)
UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)
UIGrid.Parent = SavedList

local function updateSavedList()
    for _, v in pairs(SavedList:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    
    if listfiles then
        local files = listfiles(scriptsPath)
        for _, file in pairs(files) do
            local card = Instance.new("Frame")
            card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            card.Parent = SavedList
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
            
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, 0, 0, 30)
            t.Text = file:gsub(scriptsPath, "")
            t.TextColor3 = Color3.fromRGB(255, 255, 255)
            t.BackgroundTransparency = 1
            t.Parent = card
            
            local exec = Instance.new("TextButton")
            exec.Size = UDim2.new(0.8, 0, 0, 25)
            exec.Position = UDim2.new(0.1, 0, 0.4, 0)
            exec.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            exec.Text = "Execute"
            exec.TextColor3 = Color3.fromRGB(255, 255, 255)
            exec.Parent = card
            Instance.new("UIStroke", exec).Color = Color3.fromRGB(0, 150, 80)
            Instance.new("UICorner", exec).CornerRadius = UDim.new(0, 12)
            
            local del = Instance.new("TextButton")
            del.Size = UDim2.new(0.8, 0, 0, 20)
            del.Position = UDim2.new(0.1, 0, 0.75, 0)
            del.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            del.Text = "Delete"
            del.TextColor3 = Color3.fromRGB(255, 100, 100)
            del.Parent = card
            Instance.new("UICorner", del).CornerRadius = UDim.new(0, 12)

            exec.MouseButton1Click:Connect(function()
                loadstring(readfile(file))()
            end)
            
            del.MouseButton1Click:Connect(function()
                delfile(file)
                updateSavedList()
            end)
        end
    end
end

-- ======================== CLOUD (AGORA FUNCIONANDO) ========================
local CloudPage = Instance.new("Frame")
CloudPage.Size = UDim2.new(1, 0, 1, 0)
CloudPage.BackgroundTransparency = 1
CloudPage.Visible = false
CloudPage.Parent = Content

-- Search Bar Cloud
local CloudSearchBar = Instance.new("TextBox")
CloudSearchBar.Size = UDim2.new(1, -240, 0, 30)
CloudSearchBar.Position = UDim2.new(0, 10, 0, 10)
CloudSearchBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CloudSearchBar.PlaceholderText = "Search cloud scripts..."
CloudSearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
CloudSearchBar.TextXAlignment = Enum.TextXAlignment.Left
CloudSearchBar.Parent = CloudPage
Instance.new("UICorner", CloudSearchBar).CornerRadius = UDim.new(0, 8)

-- Checkbox (mantido + visual)
local CheckboxFrame = Instance.new("Frame")
CheckboxFrame.Size = UDim2.new(0, 200, 0, 30)
CheckboxFrame.Position = UDim2.new(1, -210, 0, 10)
CheckboxFrame.BackgroundTransparency = 1
CheckboxFrame.Parent = CloudPage

local CheckText = Instance.new("TextLabel")
CheckText.Size = UDim2.new(1, -35, 1, 0)
CheckText.Text = "Scripts only for this game"
CheckText.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckText.TextXAlignment = Enum.TextXAlignment.Right
CheckText.BackgroundTransparency = 1
CheckText.Parent = CheckboxFrame

local CheckBox = Instance.new("TextButton")
CheckBox.Size = UDim2.new(0, 25, 0, 25)
CheckBox.Position = UDim2.new(1, -30, 0, 2)
CheckBox.BackgroundColor3 = Color3.fromRGB(110, 40, 255)
CheckBox.Text = ""
CheckBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBox.Parent = CheckboxFrame
Instance.new("UICorner", CheckBox).CornerRadius = UDim.new(0, 5)

local gameOnly = false
CheckBox.MouseButton1Click:Connect(function()
    gameOnly = not gameOnly
    CheckBox.Text = gameOnly and "✓" or ""
    -- Futuro: filtro por gameId (ainda não tem no repo)
end)

-- Lista Cloud
local CloudList = Instance.new("ScrollingFrame")
CloudList.Size = UDim2.new(1, -20, 1, -55)
CloudList.Position = UDim2.new(0, 10, 0, 50)
CloudList.BackgroundTransparency = 1
CloudList.ScrollBarThickness = 4
CloudList.Parent = CloudPage
local CloudGrid = Instance.new("UIGridLayout")
CloudGrid.CellSize = UDim2.new(0, 150, 0, 120)
CloudGrid.CellPadding = UDim2.new(0, 10, 0, 10)
CloudGrid.Parent = CloudList

-- Carregar scripts do GitHub
local function loadCloudScripts()
    cloudScripts = {}
    pcall(function()
        local apiUrl = "https://api.github.com/repos/higuysdorobloxjoaopk-maker/-src_.exe-lua.exe-/contents/Cloud/Scripts"
        local contents = HttpService:JSONDecode(game:HttpGet(apiUrl))
        
        for _, item in ipairs(contents) do
            if item.type == "dir" then
                local folderId = item.name
                pcall(function()
                    local dirUrl = "https://api.github.com/repos/higuysdorobloxjoaopk-maker/-src_.exe-lua.exe-/contents/Cloud/Scripts/" .. folderId
                    local dirData = HttpService:JSONDecode(game:HttpGet(dirUrl))
                    
                    local dataFile = nil
                    for _, f in ipairs(dirData) do
                        if f.name == "data.json" then dataFile = f break end
                    end
                    
                    if dataFile then
                        local jsonStr = game:HttpGet(dataFile.download_url)
                        local data = HttpService:JSONDecode(jsonStr)
                        
                        table.insert(cloudScripts, {
                            name = data.name or "Unknown",
                            description = data.description or "Sem descrição",
                            loadstring = data.loadstring or ""
                        })
                    end
                end)
            end
        end
    end)
end

local function updateCloudList(query)
    query = string.lower(query or "")
    for _, v in pairs(CloudList:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    
    for _, s in ipairs(cloudScripts) do
        if query == "" or string.find(string.lower(s.name), query) or string.find(string.lower(s.description), query) then
            local card = Instance.new("Frame")
            card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            card.Parent = CloudList
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
            
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, 0, 0, 30)
            nameLbl.Text = s.name
            nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 14
            nameLbl.BackgroundTransparency = 1
            nameLbl.Parent = card
            
            local descLbl = Instance.new("TextLabel")
            descLbl.Size = UDim2.new(1, 0, 0, 50)
            descLbl.Position = UDim2.new(0, 0, 0, 30)
            descLbl.Text = s.description
            descLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
            descLbl.TextSize = 12
            descLbl.TextWrapped = true
            descLbl.BackgroundTransparency = 1
            descLbl.Parent = card
            
            local execBtn = Instance.new("TextButton")
            execBtn.Size = UDim2.new(0.9, 0, 0, 25)
            execBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
            execBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            execBtn.Text = "Execute"
            execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            execBtn.Parent = card
            Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 12)
            Instance.new("UIStroke", execBtn).Color = Color3.fromRGB(0, 150, 80)
            
            execBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    loadstring(s.loadstring)()
                end)
            end)
        end
    end
end

CloudSearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    updateCloudList(CloudSearchBar.Text)
end)

-- ======================== LOGS ========================
local LogsPage = Instance.new("Frame")
LogsPage.Size = UDim2.new(1, 0, 1, 0)
LogsPage.BackgroundTransparency = 1
LogsPage.Visible = false
LogsPage.Parent = Content

local LogLabel = Instance.new("TextLabel")
LogLabel.Text = "logs"
LogLabel.Size = UDim2.new(0, 100, 0, 20)
LogLabel.Position = UDim2.new(0, 10, 0, 5)
LogLabel.BackgroundTransparency = 1
LogLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogLabel.Font = Enum.Font.GothamBold
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.Parent = LogsPage

local LogBox = Instance.new("ScrollingFrame")
LogBox.Size = UDim2.new(1, -20, 1, -60)
LogBox.Position = UDim2.new(0, 10, 0, 30)
LogBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LogBox.BorderSizePixel = 0
LogBox.Parent = LogsPage
Instance.new("UICorner", LogBox).CornerRadius = UDim.new(0, 8)

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -10, 1, -10)
LogText.Position = UDim2.new(0, 5, 0, 5)
LogText.BackgroundTransparency = 1
LogText.Text = ""
LogText.TextColor3 = Color3.fromRGB(200, 200, 200)
LogText.TextSize = 12
LogText.Font = Enum.Font.Code
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.Parent = LogBox

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 80, 0, 25)
ClearBtn.Position = UDim2.new(0, 10, 1, -25)
ClearBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Parent = LogsPage
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 12)

ClearBtn.MouseButton1Click:Connect(function()
    LogText.Text = ""
end)

game:GetService("LogService").MessageOut:Connect(function(msg, type)
    LogText.Text = LogText.Text .. "[" .. type.Name .. "] " .. msg .. "\n"
end)

-- Troca de Abas
local function showPage(page, btn)
    EditorPage.Visible = false
    SavedPage.Visible = false
    CloudPage.Visible = false
    LogsPage.Visible = false
    
    page.Visible = true
    setTabActive(btn)
    
    if page == SavedPage then updateSavedList() end
    if page == CloudPage then
        loadCloudScripts()
        updateCloudList(CloudSearchBar.Text)
    end
end

EditorTab.MouseButton1Click:Connect(function() showPage(EditorPage, EditorTab) end)
SavedTab.MouseButton1Click:Connect(function() showPage(SavedPage, SavedTab) end)
CloudTab.MouseButton1Click:Connect(function() showPage(CloudPage, CloudTab) end)
LogsTab.MouseButton1Click:Connect(function() showPage(LogsPage, LogsTab) end)

-- Minimizar
local function toggleUI()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true)
        task.delay(0.3, function() 
            MainFrame.Visible = false
            MinimizedOrb.Visible = true
        end)
    else
        MinimizedOrb.Visible = false
        MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 580, 0, 350), "Out", "Quad", 0.3, true)
    end
end

ExitBtn.MouseButton1Click:Connect(toggleUI)
MinimizedOrb.MouseButton1Click:Connect(toggleUI)

-- Update FPS/Ping
RunService.RenderStepped:Connect(function(dt)
    if EditorPage.Visible then
        local fps = math.floor(1/dt)
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        local players = #game:GetService("Players"):GetPlayers()
        NetInfo.Text = string.format("Client status information\n%d FPS\n%d MS Ping\n%d Players", fps, ping, players)
    end
end)

print("Delta v2 Loaded Successfully! (versão corrigida por luay)")
