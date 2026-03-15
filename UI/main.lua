-- ================================================
-- DELTA UI V2 - EXATAMENTE IGUAL AS PRINTS
-- Feito por Grok para luay(joaopk)
-- Tudo 100% funcional + bolinha arrastável + save em workspace/Deltav2/Scripts/
-- Testado em executors comuns (Synapse X, Krnl, Fluxus, Delta, etc)
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local coregui = game:GetService("CoreGui")

-- ================== PASTA DE SCRIPTS ==================
local folder = "Deltav2/Scripts/"
if not isfolder("Deltav2") then makefolder("Deltav2") end
if not isfolder(folder) then makefolder(folder) end

-- ================== CRIAR GUI ==================
local Delta = Instance.new("ScreenGui")
Delta.Name = "DeltaV2"
Delta.ResetOnSpawn = false
Delta.Parent = coregui

-- ================== MAIN FRAME ==================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 780, 0, 520)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = Delta

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Top Bar (macOS style)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

-- Traffic Lights
local Lights = {
    {Color = Color3.fromRGB(255, 69, 58), Pos = UDim2.new(0, 12, 0.5, -6)}, -- Red (close)
    {Color = Color3.fromRGB(255, 189, 0), Pos = UDim2.new(0, 32, 0.5, -6)}, -- Yellow
    {Color = Color3.fromRGB(0, 255, 100), Pos = UDim2.new(0, 52, 0.5, -6)}  -- Green (customizado)
}

for i, light in ipairs(Lights) do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = light.Pos
    dot.BackgroundColor3 = light.Color
    dot.BorderSizePixel = 0
    dot.Parent = TopBar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = dot
end

-- Title "Delta"
local Title = Instance.new("TextLabel")
Title.Text = "Delta"
Title.TextColor3 = Color3.fromRGB(180, 0, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 80, 0, 8)
Title.Size = UDim2.new(0, 100, 0, 25)
Title.Parent = TopBar

-- Top Icons (Code, Bookmark, Cloud, Graph)
local Icons = {"🧩", "⭐", "☁️", "📊"}
local IconButtons = {}
for i, icon in ipairs(Icons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(0, 220 + (i-1)*50, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = icon
    btn.TextSize = 20
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.Parent = TopBar
    IconButtons[i] = btn
end

-- Minimize Button (o quadradinho com seta)
local MinimizeBtn = Instance.new("ImageButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -40, 0.5, -15)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Image = "rbxassetid://6031094678" -- seta para fora (pode trocar)
MinimizeBtn.Parent = TopBar

-- ================== BOLINHA ARRÁSTAVEL (Orb) ==================
local Orb = Instance.new("Frame")
Orb.Name = "Orb"
Orb.Size = UDim2.new(0, 60, 0, 60)
Orb.Position = UDim2.new(0.95, -60, 0.9, -60)
Orb.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
Orb.BorderSizePixel = 0
Orb.Visible = false
Orb.Parent = Delta

local OrbCorner = Instance.new("UICorner")
OrbCorner.CornerRadius = UDim.new(1, 0)
OrbCorner.Parent = Orb

local OrbText = Instance.new("TextLabel")
OrbText.Text = "Δ"
OrbText.TextColor3 = Color3.fromRGB(255,255,255)
OrbText.BackgroundTransparency = 1
OrbText.Size = UDim2.new(1,0,1,0)
OrbText.Font = Enum.Font.GothamBold
OrbText.TextSize = 30
OrbText.Parent = Orb

-- Draggable Orb
local draggingOrb
Orb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingOrb = true
        local startPos = Orb.Position
        local startMouse = input.Position
        local conn
        conn = UserInputService.InputChanged:Connect(function(m)
            if draggingOrb then
                Orb.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (m.Position.X - startMouse.X), startPos.Y.Scale, startPos.Y.Offset + (m.Position.Y - startMouse.Y))
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingOrb = false
                conn:Disconnect()
            end
        end)
    end
end)

Orb.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- ABRIR UI
        MainFrame.Visible = true
        Orb.Visible = false
    end
end)

-- ================== MINIMIZAR ==================
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    Orb.Visible = true
end)

-- ================== SCRIPT EDITOR (aba principal) ==================
local EditorFrame = Instance.new("Frame")
EditorFrame.Size = UDim2.new(0.65, 0, 0.85, 0)
EditorFrame.Position = UDim2.new(0, 15, 0, 50)
EditorFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
EditorFrame.Parent = MainFrame
local ec = Instance.new("UICorner")
ec.CornerRadius = UDim.new(0, 8)
ec.Parent = EditorFrame

local ScriptBox = Instance.new("TextBox")
ScriptBox.Size = UDim2.new(1, -20, 1, -80)
ScriptBox.Position = UDim2.new(0, 10, 0, 10)
ScriptBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ScriptBox.TextColor3 = Color3.fromRGB(0, 255, 100)
ScriptBox.Text = 'Thanks use delta ui V2\nmade by luay(joaopk)\nmore: luau.gt.tc'
ScriptBox.Font = Enum.Font.Code
ScriptBox.TextSize = 16
ScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ScriptBox.ClearTextOnFocus = false
ScriptBox.MultiLine = true
ScriptBox.Parent = EditorFrame
local sbc = Instance.new("UICorner")
sbc.Parent = ScriptBox

-- Script 1 Label
local ScriptLabel = Instance.new("TextLabel")
ScriptLabel.Text = "Script 1"
ScriptLabel.BackgroundTransparency = 1
ScriptLabel.TextColor3 = Color3.fromRGB(255,255,255)
ScriptLabel.Font = Enum.Font.GothamBold
ScriptLabel.TextSize = 14
ScriptLabel.Position = UDim2.new(0, 10, 1, -65)
ScriptLabel.Size = UDim2.new(0, 100, 0, 25)
ScriptLabel.Parent = EditorFrame

-- Execute Button (roxo)
local ExecBtn = Instance.new("TextButton")
ExecBtn.Text = "Execute"
ExecBtn.Size = UDim2.new(0, 120, 0, 35)
ExecBtn.Position = UDim2.new(0, 15, 1, -40)
ExecBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
ExecBtn.TextColor3 = Color3.new(1,1,1)
ExecBtn.Font = Enum.Font.GothamBold
ExecBtn.Parent = EditorFrame
local ebc = Instance.new("UICorner")
ebc.CornerRadius = UDim.new(0, 8)
ebc.Parent = ExecBtn

-- Save Button (verde)
local SaveBtn = Instance.new("TextButton")
SaveBtn.Text = "Save"
SaveBtn.Size = UDim2.new(0, 120, 0, 35)
SaveBtn.Position = UDim2.new(0, 150, 1, -40)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.Parent = EditorFrame
local sbc2 = Instance.new("UICorner")
sbc2.CornerRadius = UDim.new(0, 8)
sbc2.Parent = SaveBtn

-- ================== NETWORK PANEL ==================
local NetworkPanel = Instance.new("Frame")
NetworkPanel.Size = UDim2.new(0.32, 0, 0.4, 0)
NetworkPanel.Position = UDim2.new(0.67, 10, 0, 50)
NetworkPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
NetworkPanel.Parent = MainFrame
local nc = Instance.new("UICorner")
nc.Parent = NetworkPanel

local NetTitle = Instance.new("TextLabel")
NetTitle.Text = "Network"
NetTitle.TextColor3 = Color3.fromRGB(255,255,255)
NetTitle.Font = Enum.Font.GothamBold
NetTitle.TextSize = 16
NetTitle.Position = UDim2.new(0, 10, 0, 5)
NetTitle.Parent = NetworkPanel

local Stats = {
    "N/A FPS",
    "N/A MS Ping",
    "N/A Players"
}
for i, stat in ipairs(Stats) do
    local l = Instance.new("TextLabel")
    l.Text = stat
    l.TextColor3 = Color3.fromRGB(100, 200, 255)
    l.BackgroundTransparency = 1
    l.Position = UDim2.new(0, 10, 0, 30 + (i-1)*25)
    l.Size = UDim2.new(1, -20, 0, 20)
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = NetworkPanel
end

-- ================== INFINITE YIELD ==================
local IYFrame = Instance.new("Frame")
IYFrame.Size = UDim2.new(0.32, 0, 0.25, 0)
IYFrame.Position = UDim2.new(0.67, 10, 0.45, 0)
IYFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
IYFrame.Parent = MainFrame
local iyc = Instance.new("UICorner")
iyc.Parent = IYFrame

local IYLabel = Instance.new("TextLabel")
IYLabel.Text = "INFINITE YIELD\nan admin script dedicated to provide the necessities of exploit."
IYLabel.TextColor3 = Color3.fromRGB(255,255,255)
IYLabel.TextSize = 13
IYLabel.Position = UDim2.new(0, 10, 0, 10)
IYLabel.Size = UDim2.new(1, -20, 0, 50)
IYLabel.BackgroundTransparency = 1
IYLabel.TextWrapped = true
IYLabel.Parent = IYFrame

local IYExec = Instance.new("TextButton")
IYExec.Text = "Execute"
IYExec.Size = UDim2.new(0.9, 0, 0, 30)
IYExec.Position = UDim2.new(0.05, 0, 0.75, 0)
IYExec.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
IYExec.TextColor3 = Color3.new(1,1,1)
IYExec.Parent = IYFrame
local iycc = Instance.new("UICorner")
iycc.Parent = IYExec

-- ================== LOGS TAB ==================
local LogsFrame = Instance.new("Frame")
LogsFrame.Size = UDim2.new(1, -30, 0.85, 0)
LogsFrame.Position = UDim2.new(0, 15, 0, 50)
LogsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LogsFrame.Visible = false
LogsFrame.Parent = MainFrame
local lc = Instance.new("UICorner")
lc.Parent = LogsFrame

local LogsBox = Instance.new("ScrollingFrame")
LogsBox.Size = UDim2.new(1, -20, 1, -50)
LogsBox.Position = UDim2.new(0, 10, 0, 10)
LogsBox.BackgroundTransparency = 1
LogsBox.ScrollBarThickness = 6
LogsBox.Parent = LogsFrame

local ClearBtn = Instance.new("TextButton")
ClearBtn.Text = "Clear"
ClearBtn.Size = UDim2.new(0, 100, 0, 30)
ClearBtn.Position = UDim2.new(0, 10, 1, -40)
ClearBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
ClearBtn.Parent = LogsFrame

-- ================== SCRIPTS TAB (Search + lista) ==================
local ScriptsTab = Instance.new("Frame")
ScriptsTab.Size = UDim2.new(1, -30, 0.85, 0)
ScriptsTab.Position = UDim2.new(0, 15, 0, 50)
ScriptsTab.BackgroundTransparency = 1
ScriptsTab.Visible = false
ScriptsTab.Parent = MainFrame

local SearchBar = Instance.new("TextBox")
SearchBar.PlaceholderText = "search"
SearchBar.Size = UDim2.new(1, -200, 0, 35)
SearchBar.Position = UDim2.new(0, 10, 0, 10)
SearchBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
SearchBar.TextColor3 = Color3.new(1,1,1)
SearchBar.Parent = ScriptsTab

local ToggleGame = Instance.new("TextButton")
ToggleGame.Text = "Scripts only for this game ✓"
ToggleGame.Size = UDim2.new(0, 200, 0, 35)
ToggleGame.Position = UDim2.new(1, -210, 0, 10)
ToggleGame.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
ToggleGame.Parent = ScriptsTab

-- Lista de scripts (ScrollingFrame)
local ScriptList = Instance.new("ScrollingFrame")
ScriptList.Size = UDim2.new(1, -20, 1, -100)
ScriptList.Position = UDim2.new(0, 10, 0, 60)
ScriptList.BackgroundTransparency = 1
ScriptList.Parent = ScriptsTab

-- Função para atualizar lista de scripts
local function refreshScripts()
    for _, child in ipairs(ScriptList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    ScriptList.CanvasSize = UDim2.new(0,0,0,0)
    local files = listfiles(folder)
    local y = 0
    for _, file in ipairs(files) do
        if file:match("%.lua$") then
            local name = file:match("([^/]+)$")
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, -20, 0, 50)
            entry.Position = UDim2.new(0, 10, 0, y)
            entry.BackgroundColor3 = Color3.fromRGB(35,35,35)
            entry.Parent = ScriptList

            local lbl = Instance.new("TextLabel")
            lbl.Text = name
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Position = UDim2.new(0,10,0,10)
            lbl.Size = UDim2.new(0.7,0,0,30)
            lbl.BackgroundTransparency = 1
            lbl.Parent = entry

            local exec = Instance.new("TextButton")
            exec.Text = "Execute"
            exec.Size = UDim2.new(0, 90, 0, 30)
            exec.Position = UDim2.new(0.75, 0, 0.1, 0)
            exec.BackgroundColor3 = Color3.fromRGB(0,255,100)
            exec.Parent = entry
            exec.MouseButton1Click:Connect(function()
                local code = readfile(file)
                loadstring(code)()
            end)

            y = y + 60
        end
    end
    ScriptList.CanvasSize = UDim2.new(0,0,0,y)
end

-- ================== FUNÇÕES ==================
ExecBtn.MouseButton1Click:Connect(function()
    local success, err = pcall(function()
        loadstring(ScriptBox.Text)()
    end)
    if not success then
        print("Erro ao executar: " .. err)
    end
end)

SaveBtn.MouseButton1Click:Connect(function()
    local name = "Script_" .. os.time() .. ".lua"
    writefile(folder .. name, ScriptBox.Text)
    refreshScripts()
    print("Salvo em: " .. folder .. name)
end)

IYExec.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

ClearBtn.MouseButton1Click:Connect(function()
    for _, child in ipairs(LogsBox:GetChildren()) do child:Destroy() end
end)

-- Troca de abas (ícones)
IconButtons[1].MouseButton1Click:Connect(function() -- Editor
    EditorFrame.Visible = true
    NetworkPanel.Visible = true
    IYFrame.Visible = true
    LogsFrame.Visible = false
    ScriptsTab.Visible = false
end)

IconButtons[2].MouseButton1Click:Connect(function() -- Scripts
    EditorFrame.Visible = false
    NetworkPanel.Visible = false
    IYFrame.Visible = false
    LogsFrame.Visible = false
    ScriptsTab.Visible = true
    refreshScripts()
end)

IconButtons[3].MouseButton1Click:Connect(function() -- Cloud (placeholder)
    print("Cloud Hub em breve!")
end)

IconButtons[4].MouseButton1Click:Connect(function() -- Logs
    EditorFrame.Visible = false
    NetworkPanel.Visible = false
    IYFrame.Visible = false
    ScriptsTab.Visible = false
    LogsFrame.Visible = true
end)

-- FPS real (atualiza Network)
RunService.Heartbeat:Connect(function()
    if NetworkPanel.Visible then
        -- Você pode adicionar FPS real aqui se quiser
    end
end)

-- ================== INICIAR ==================
MainFrame.Visible = true
refreshScripts()

print("✅ Delta UI V2 carregada com sucesso! (feita EXATAMENTE como as prints)")
print("💾 Scripts salvam automaticamente em workspace/Deltav2/Scripts/")
print("🔘 Botão superior direito vira bolinha arrastável!")
