local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ParentGui = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
local PinkUI = {Elements = {}, Theme = {Background = Color3.fromRGB(25, 25, 25), Container = Color3.fromRGB(35, 35, 35), Accent = Color3.fromRGB(255, 105, 180), Text = Color3.fromRGB(255, 255, 255), TextDark = Color3.fromRGB(180, 180, 180), ElementBg = Color3.fromRGB(45, 45, 45)}}
local function Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do inst[k] = v end
    for _, child in pairs(children or {}) do child.Parent = inst end
    return inst
end
local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition = false, nil, nil, nil
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPosition = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
        end
    end)
end
function PinkUI:BindAction(id, callback)
    if self.Elements[id] then self.Elements[id].Callback = callback end
end
function PinkUI:CreateWindow(options)
    local title = options.Title or "PinkUI Library"
    if options.AccentColor then self.Theme.Accent = options.AccentColor end
    if ParentGui:FindFirstChild("PinkUI_Screen") then ParentGui.PinkUI_Screen:Destroy() end
    local ScreenGui = Create("ScreenGui", {Name = "PinkUI_Screen", Parent = ParentGui, ResetOnSpawn = false})
    local MainFrame = Create("Frame", {Name = "Main", Size = UDim2.new(0, 500, 0, 350), Position = UDim2.new(0.5, -250, 0.5, -175), BackgroundColor3 = self.Theme.Background, ClipsDescendants = true}, {Create("UICorner", {CornerRadius = UDim.new(0, 8)})})
    MainFrame.Parent = ScreenGui
    local TopBar = Create("Frame", {Name = "TopBar", Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = self.Theme.Container, BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(0, 8)})})
    Create("Frame", {Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 1, -8), BackgroundColor3 = self.Theme.Container, BorderSizePixel = 0, Parent = TopBar})
    TopBar.Parent = MainFrame
    MakeDraggable(TopBar, MainFrame)
    Create("TextLabel", {Text = title, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar})
    local Minimized = false
    local MinButton = Create("TextButton", {Text = "-", Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0, 5), BackgroundColor3 = self.Theme.ElementBg, TextColor3 = self.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 20, Parent = TopBar}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
    MinButton.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 500, 0, Minimized and 40 or 350)}):Play()
    end)
    local TabContainer = Create("Frame", {Size = UDim2.new(0, 130, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = self.Theme.Container, BorderSizePixel = 0, Parent = MainFrame})
    local TabList = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -10), Position = UDim2.new(0, 0, 0, 5), BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), Parent = TabContainer}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})})
    local PageContainer = Create("Frame", {Size = UDim2.new(1, -130, 1, -40), Position = UDim2.new(0, 130, 0, 40), BackgroundTransparency = 1, Parent = MainFrame})
    local Window = {Tabs = {}, CurrentTab = nil}
    function Window:CreateTab(options)
        local tabName = options.Name or "Tab"
        local TabButton = Create("TextButton", {Size = UDim2.new(0.9, 0, 0, 30), BackgroundColor3 = PinkUI.Theme.ElementBg, Text = tabName, TextColor3 = PinkUI.Theme.TextDark, Font = Enum.Font.GothamSemibold, TextSize = 14, Parent = TabList}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
        local Page = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = PinkUI.Theme.Accent, Visible = false, Parent = PageContainer}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})})
        Create("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = Page})
        if not self.CurrentTab then self.CurrentTab = Page; Page.Visible = true; TabButton.TextColor3 = PinkUI.Theme.Text; TabButton.BackgroundColor3 = PinkUI.Theme.Accent end
        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do t.Page.Visible = false; t.Button.BackgroundColor3 = PinkUI.Theme.ElementBg; t.Button.TextColor3 = PinkUI.Theme.TextDark end
            Page.Visible = true; TabButton.BackgroundColor3 = PinkUI.Theme.Accent; TabButton.TextColor3 = PinkUI.Theme.Text
        end)
        TabList.CanvasSize = UDim2.new(0, 0, 0, TabList.UIListLayout.AbsoluteContentSize.Y + 10)
        table.insert(self.Tabs, {Page = Page, Button = TabButton})
        local TabElements = {}
        function TabElements:CreateButton(opts)
            local id = opts.ID or tostring(math.random(1000,9999))
            local btnFrame = Create("TextButton", {Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = PinkUI.Theme.ElementBg, Text = opts.Text or "Button", TextColor3 = PinkUI.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            PinkUI.Elements[id] = {Type = "Button", Callback = function() end}
            btnFrame.MouseButton1Click:Connect(function()
                TweenService:Create(btnFrame, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 33)}):Play(); task.wait(0.1)
                TweenService:Create(btnFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                if PinkUI.Elements[id].Callback then PinkUI.Elements[id].Callback() end
            end)
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
        end
        function TabElements:CreateToggle(opts)
            local id = opts.ID or tostring(math.random(1000,9999))
            local state = opts.Default or false
            local TogFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = PinkUI.Theme.ElementBg, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            Create("TextLabel", {Text = opts.Text or "Toggle", Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = PinkUI.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = TogFrame})
            local TogContainer = Create("TextButton", {Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -54, 0.5, -12), BackgroundColor3 = state and PinkUI.Theme.Accent or Color3.fromRGB(60, 60, 60), Text = "", AutoButtonColor = false, Parent = TogFrame}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local Circle = Create("Frame", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, state and 22 or 2, 0.5, -10), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = TogContainer}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            PinkUI.Elements[id] = {Type = "Toggle", Value = state, Callback = function(val) end}
            TogContainer.MouseButton1Click:Connect(function()
                state = not state; PinkUI.Elements[id].Value = state
                TweenService:Create(Circle, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = state and UDim2.new(0, 22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
                TweenService:Create(TogContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = state and PinkUI.Theme.Accent or Color3.fromRGB(60, 60, 60)}):Play()
                if PinkUI.Elements[id].Callback then PinkUI.Elements[id].Callback(state) end
            end)
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
        end
        function TabElements:CreateTextBox(opts)
            local id = opts.ID or tostring(math.random(1000,9999))
            local BoxFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = PinkUI.Theme.ElementBg, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            local Input = Create("TextBox", {Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = PinkUI.Theme.Text, PlaceholderText = opts.Placeholder or "...", PlaceholderColor3 = PinkUI.Theme.TextDark, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = BoxFrame, ClearTextOnFocus = false})
            PinkUI.Elements[id] = {Type = "TextBox", Value = "", Callback = function(txt) end}
            Input.FocusLost:Connect(function(enterPressed)
                PinkUI.Elements[id].Value = Input.Text
                if PinkUI.Elements[id].Callback then PinkUI.Elements[id].Callback(Input.Text, enterPressed) end
            end)
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
        end
        function TabElements:CreateDropdown(opts)
            local id = opts.ID or tostring(math.random(1000,9999))
            local dropped = false
            local DropFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = PinkUI.Theme.ElementBg, Parent = Page, ClipsDescendants = true}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            local DropBtn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = opts.Text or "Dropdown", TextColor3 = PinkUI.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = DropFrame})
            Create("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = DropBtn})
            local Arrow = Create("TextLabel", {Text = "▼", Size = UDim2.new(0, 20, 0, 40), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, TextColor3 = PinkUI.Theme.TextDark, Font = Enum.Font.GothamBold, TextSize = 12, Parent = DropFrame})
            local ListContainer = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1, ScrollBarThickness = 2, Parent = DropFrame}, {Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})})
            PinkUI.Elements[id] = {Type = "Dropdown", Value = nil, Callback = function(val) end}
            local function RefreshOptions(newOptions)
                for _, v in pairs(ListContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                local ySize = 0
                for _, opt in pairs(newOptions) do
                    local OptBtn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = PinkUI.Theme.Container, Text = "  " .. tostring(opt), TextColor3 = PinkUI.Theme.TextDark, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = ListContainer})
                    ySize = ySize + 30
                    OptBtn.MouseButton1Click:Connect(function()
                        DropBtn.Text = (opts.Text or "Dropdown") .. ": " .. tostring(opt); PinkUI.Elements[id].Value = opt
                        if PinkUI.Elements[id].Callback then PinkUI.Elements[id].Callback(opt) end
                        dropped = false; TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    end)
                end
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, ySize); return ySize
            end
            local maxListY = RefreshOptions(opts.Options or {})
            PinkUI.Elements[id].Refresh = function(newOpts)
                maxListY = RefreshOptions(newOpts)
                if dropped then DropFrame.Size = UDim2.new(1, 0, 0, math.clamp(maxListY + 40, 40, 150)) end
            end
            DropBtn.MouseButton1Click:Connect(function()
                dropped = not dropped
                TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, dropped and math.clamp(maxListY + 40, 40, 150) or 40)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = dropped and 180 or 0}):Play()
                Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 150)
            end)
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
        end
        function TabElements:CreatePlayerList(opts)
            opts.Options = {}; for _, p in pairs(Players:GetPlayers()) do table.insert(opts.Options, p.Name) end
            opts.Text = opts.Text or "Selecionar Jogador"; self:CreateDropdown(opts)
            local function UpdatePlayers()
                local pList = {}; for _, p in pairs(Players:GetPlayers()) do table.insert(pList, p.Name) end
                PinkUI.Elements[opts.ID].Refresh(pList)
            end
            Players.PlayerAdded:Connect(UpdatePlayers); Players.PlayerRemoving:Connect(UpdatePlayers)
        end
        function TabElements:CreateColorPicker(opts)
            local id = opts.ID or tostring(math.random(1000,9999))
            local currentColor = opts.Default or Color3.fromRGB(255, 255, 255); local expanded = false
            local ColorFrame = Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = PinkUI.Theme.ElementBg, Parent = Page, ClipsDescendants = true}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            Create("TextLabel", {Text = opts.Text or "Color Picker", Size = UDim2.new(1, -60, 0, 40), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = PinkUI.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = ColorFrame})
            local ColorPreviewBtn = Create("TextButton", {Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -40, 0, 10), BackgroundColor3 = currentColor, Text = "", Parent = ColorFrame}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            local SlidersFrame = Create("Frame", {Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1, Parent = ColorFrame})
            PinkUI.Elements[id] = {Type = "ColorPicker", Value = currentColor, Callback = function(col) end}
            local function MakeSlider(name, pos, maxColor)
                local SFrame = Create("Frame", {Size = UDim2.new(1, -20, 0, 20), Position = pos, BackgroundTransparency=1, Parent = SlidersFrame})
                Create("TextLabel", {Text=name, Size=UDim2.new(0, 20, 1, 0), BackgroundTransparency=1, TextColor3=PinkUI.Theme.TextDark, Font=Enum.Font.Gotham, TextSize=12, Parent=SFrame})
                local SliderBg = Create("TextButton", {Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 30, 0.5, -3), BackgroundColor3 = Color3.fromRGB(30,30,30), Text="", AutoButtonColor=false, Parent = SFrame}, {Create("UICorner", {CornerRadius=UDim.new(1,0)})})
                local Fill = Create("Frame", {Size = UDim2.new(name=="R" and currentColor.R or name=="G" and currentColor.G or currentColor.B, 0, 1, 0), BackgroundColor3 = maxColor, Parent = SliderBg}, {Create("UICorner", {CornerRadius=UDim.new(1,0)})})
                local isDragging = false
                SliderBg.MouseButton1Down:Connect(function() isDragging = true end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((UserInputService:GetMouseLocation().X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                        Fill.Size = UDim2.new(percent, 0, 1, 0)
                        currentColor = Color3.new(name == "R" and percent or currentColor.R, name == "G" and percent or currentColor.G, name == "B" and percent or currentColor.B)
                        ColorPreviewBtn.BackgroundColor3 = currentColor; PinkUI.Elements[id].Value = currentColor
                        if PinkUI.Elements[id].Callback then PinkUI.Elements[id].Callback(currentColor) end
                    end
                end)
            end
            MakeSlider("R", UDim2.new(0, 10, 0, 10), Color3.fromRGB(255, 0, 0))
            MakeSlider("G", UDim2.new(0, 10, 0, 40), Color3.fromRGB(0, 255, 0))
            MakeSlider("B", UDim2.new(0, 10, 0, 70), Color3.fromRGB(0, 0, 255))
            ColorPreviewBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                TweenService:Create(ColorFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, expanded and 140 or 40)}):Play()
                Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 100)
            end)
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
        end
        return TabElements
    end
    return Window
end
return PinkUI
