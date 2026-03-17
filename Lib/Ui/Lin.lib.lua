local UILib = {}
UILib.Theme = {
	Main = Color3.fromRGB(255,105,180),
	Dark = Color3.fromRGB(25,25,25),
	Light = Color3.fromRGB(40,40,40),
	Text = Color3.fromRGB(255,255,255)
}

UILib.Objects = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui
gui.Name = "CustomUILib"

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,550,0,450)
Main.Position = UDim2.new(0.5,-275,0.5,-225)
Main.BackgroundColor3 = UILib.Theme.Dark
Main.Parent = gui
Instance.new("UICorner", Main)

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,45)
Top.BackgroundColor3 = UILib.Theme.Main
Top.Parent = Main
Instance.new("UICorner", Top)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-100,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Custom UI"
Title.TextColor3 = UILib.Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Min = Instance.new("TextButton")
Min.Size = UDim2.new(0,30,0,30)
Min.Position = UDim2.new(1,-40,0,7)
Min.Text = "-"
Min.BackgroundColor3 = UILib.Theme.Light
Min.TextColor3 = UILib.Theme.Text
Min.Parent = Top
Instance.new("UICorner", Min)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1,-20,1,-60)
Container.Position = UDim2.new(0,10,0,50)
Container.CanvasSize = UDim2.new(0,0,0,1000)
Container.BackgroundTransparency = 1
Container.Parent = Main

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0,8)

local minimized = false
Min.MouseButton1Click:Connect(function()
	minimized = not minimized
	Container.Visible = not minimized
	Main.Size = minimized and UDim2.new(0,550,0,50) or UDim2.new(0,550,0,450)
end)

function UILib:SetTheme(color)
	UILib.Theme.Main = color
	Top.BackgroundColor3 = color
end

function UILib:CreateButton(id,text,callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,40)
	b.BackgroundColor3 = UILib.Theme.Light
	b.Text = text
	b.TextColor3 = UILib.Theme.Text
	b.Parent = Container
	Instance.new("UICorner", b)

	UILib.Objects[id] = b

	b.MouseButton1Click:Connect(function()
		callback()
	end)
end

function UILib:CreateToggle(id,text,mode,callback)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1,0,0,40)
	f.BackgroundColor3 = UILib.Theme.Light
	f.Parent = Container
	Instance.new("UICorner", f)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.7,0,1,0)
	lbl.Position = UDim2.new(0,10,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = UILib.Theme.Text
	lbl.Parent = f

	local t = Instance.new("TextButton")
	t.Size = UDim2.new(0,50,0,24)
	t.Position = UDim2.new(1,-60,0.5,-12)
	t.Text = ""
	t.Parent = f
	Instance.new("UICorner", t)

	local state = false

	if mode == "ios" then
		local circle = Instance.new("Frame")
		circle.Size = UDim2.new(0,20,0,20)
		circle.Position = UDim2.new(0,2,0.5,-10)
		circle.BackgroundColor3 = Color3.new(1,1,1)
		circle.Parent = t
		Instance.new("UICorner", circle)

		t.MouseButton1Click:Connect(function()
			state = not state
			circle.Position = state and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
			t.BackgroundColor3 = state and UILib.Theme.Main or Color3.fromRGB(70,70,70)
			callback(state)
		end)
	end

	UILib.Objects[id] = f
end

function UILib:CreateTextbox(id,placeholder,callback)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1,0,0,40)
	box.BackgroundColor3 = UILib.Theme.Light
	box.PlaceholderText = placeholder
	box.Text = ""
	box.TextColor3 = UILib.Theme.Text
	box.Parent = Container
	Instance.new("UICorner", box)

	UILib.Objects[id] = box

	box.FocusLost:Connect(function()
		callback(box.Text)
	end)
end

function UILib:CreateDropdown(id,title,list,callback)
	local drop = Instance.new("TextButton")
	drop.Size = UDim2.new(1,0,0,40)
	drop.BackgroundColor3 = UILib.Theme.Light
	drop.Text = title
	drop.TextColor3 = UILib.Theme.Text
	drop.Parent = Container
	Instance.new("UICorner", drop)

	UILib.Objects[id] = drop

	drop.MouseButton1Click:Connect(function()
		callback(list[1])
	end)
end

function UILib:CreatePlayerList(id,callback)
	local names = {}

	for _,p in pairs(Players:GetPlayers()) do
		table.insert(names,p.Name)
	end

	UILib:CreateDropdown(id,"Players",names,function(v)
		callback(v)
	end)
end

function UILib:CreateSlider(id,text,min,max,callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,50)
	frame.BackgroundColor3 = UILib.Theme.Light
	frame.Parent = Container
	Instance.new("UICorner", frame)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,0,1,0)
	btn.Text = text.." ["..min.."]"
	btn.TextColor3 = UILib.Theme.Text
	btn.BackgroundTransparency = 1
	btn.Parent = frame

	local value = min

	btn.MouseButton1Click:Connect(function()
		value = value + 1
		if value > max then value = min end
		btn.Text = text.." ["..value.."]"
		callback(value)
	end)

	UILib.Objects[id] = frame
end

function UILib:Update(id,newtext)
	local obj = UILib.Objects[id]
	if obj and obj:IsA("TextButton") then
		obj.Text = newtext
	end
end

function UILib:Notify(text)
	local n = Instance.new("TextLabel")
	n.Size = UDim2.new(0,250,0,40)
	n.Position = UDim2.new(1,-260,1,-60)
	n.BackgroundColor3 = UILib.Theme.Main
	n.Text = text
	n.TextColor3 = Color3.new(1,1,1)
	n.Parent = gui
	Instance.new("UICorner", n)

	task.wait(2)
	n:Destroy()
end

UILib:SetTheme(Color3.fromRGB(255,105,180))

UILib:CreateButton("btn1","Botão Teste",function()
	UILib:Notify("clicou")
end)

UILib:CreateToggle("tg1","Auto Farm","ios",function(v)
	print(v)
end)

UILib:CreateTextbox("tb1","Digite aqui",function(txt)
	print(txt)
end)

UILib:CreateDropdown("dp1","Escolha",{"A","B","C"},function(v)
	print(v)
end)

UILib:CreatePlayerList("players",function(player)
	print(player)
end)

UILib:CreateSlider("sl1","Velocidade",1,10,function(v)
	print(v)
end)

return UILib
