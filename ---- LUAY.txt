--[[
	LUAY SCRIPT HUB
	Estilo: Glassmorphism / Smooth
	Features: Syntax Highlighter, File System (Saves), Logs, ScriptBlox API, Settings.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LogService = game:GetService("LogService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Compatibilidade de Executor
local isExecutor = (makefolder and writefile and readfile and isfile and listfiles and delfile)
local GET = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local CLIPBOARD = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)

if isExecutor then
	if not isfolder("LuaySaves") then makefolder("LuaySaves") end
end

-- Limpeza de UI anterior
local oldGui = playerGui:FindFirstChild("LuayCardSystem")
if oldGui then oldGui:Destroy() end
local oldCore = game:GetService("CoreGui"):FindFirstChild("LuayCardSystem")
if oldCore then oldCore:Destroy() end

-- Função utilitária para criar instâncias rapidamente
local function create(className, props, children)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then inst[k] = v end
	end
	for _, child in pairs(children or {}) do
		child.Parent = inst
	end
	if props and props.Parent then inst.Parent = props.Parent end
	return inst
end

-- Wrapper de Tween super suave
local function tween(obj, time, style, direction, props)
	local t = TweenService:Create(obj, TweenInfo.new(time, style, direction), props)
	t:Play()
	return t
end

-- Função de Hover em Botões
local function applyHover(btn, normalColor, hoverColor)
	btn.MouseEnter:Connect(function() tween(btn, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = hoverColor}) end)
	btn.MouseLeave:Connect(function() tween(btn, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = normalColor}) end)
end

-- Configurações Básicas da Interface
local SIZES = {
	EXPANDED = UDim2.fromOffset(600, 420),
	MINIMIZED = UDim2.fromOffset(160, 42)
}
local THEME = {
	Primary = Color3.fromRGB(24, 24, 28),
	Secondary = Color3.fromRGB(34, 34, 40),
	Accent = Color3.fromRGB(80, 140, 255),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(180, 180, 190),
	Danger = Color3.fromRGB(255, 80, 80),
	Success = Color3.fromRGB(80, 220, 120),
	Warning = Color3.fromRGB(255, 180, 50)
}

-- Montagem da UI Principal
local screenGui = create("ScreenGui", {
	Name = "LuayCardSystem",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	Parent = (game:GetService("RunService"):IsStudio() and playerGui) or game:GetService("CoreGui")
})

local root = create("Frame", {
	Name = "Root", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = screenGui
})

local shadow = create("Frame", {
	Name = "Shadow", Size = SIZES.EXPANDED, AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.85, ZIndex = 1, Parent = root
}, { create("UICorner", {CornerRadius = UDim.new(0, 16)}) })

local card = create("Frame", {
	Name = "Card", Size = SIZES.EXPANDED, AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = THEME.Primary, BackgroundTransparency = 0.26, ClipsDescendants = true, ZIndex = 2, Parent = root
}, {
	create("UICorner", {CornerRadius = UDim.new(0, 16)}),
	create("UIStroke", {Color = Color3.fromRGB(220, 220, 230), Transparency = 0.6, Thickness = 1.1})
})

-- Efeito de Vidro (Glassmorphism)
local mask = create("Frame", {
	Name = "Mask", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2, Parent = card
}, {
	create("UICorner", {CornerRadius = UDim.new(0, 16)}),
	create("ImageLabel", {
		Name = "BlurImage", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "rbxassetid://138105030885560",
		ImageTransparency = 0.16, ScaleType = Enum.ScaleType.Crop, ZIndex = 2
	}, { create("UICorner", {CornerRadius = UDim.new(0, 16)}) }),
	create("Frame", {
		Name = "Tint", Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.Primary, BackgroundTransparency = 0.5, ZIndex = 3
	}, { create("UICorner", {CornerRadius = UDim.new(0, 16)}) }),
	create("Frame", {
		Name = "Frost", Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.Text, BackgroundTransparency = 0.98, ZIndex = 4
	}, { create("UICorner", {CornerRadius = UDim.new(0, 16)}) })
})

-- Botões de Minimizar / Expandir
local minimizeBar = create("Frame", {
	Name = "MinimizeBar", AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.new(0, 80, 0, 4), Position = UDim2.new(0.5, 0, 0, -8),
	BackgroundColor3 = THEME.Text, BackgroundTransparency = 0.3, ZIndex = 10, Parent = card
}, { create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

local minimizeButton = create("TextButton", {
	Name = "MinimizeButton", Size = UDim2.new(0, 100, 0, 40), Position = UDim2.new(0.5, -50, 0, -30),
	BackgroundTransparency = 1, Text = "", ZIndex = 11, Parent = card
})

local openButton = create("TextButton", {
	Name = "OpenButton", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "Luay Hub",
	Font = Enum.Font.GothamBold, TextColor3 = THEME.Text, TextSize = 18, TextTransparency = 1, Visible = false, ZIndex = 15, Parent = card
})

-- Área de Conteúdo
local contentViewport = create("Frame", {
	Name = "ContentViewport", BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, -30),
	Position = UDim2.fromOffset(15, 15), ZIndex = 6, Parent = card
})

-- Título
local titleLabel = create("TextLabel", {
	Name = "Title", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 0),
	Font = Enum.Font.GothamBold, Text = "luay", TextColor3 = THEME.Text, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7, Parent = contentViewport
})

-- Sistema de Abas
local tabContainer = create("Frame", {
	Name = "TabContainer", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), Position = UDim2.new(0, 0, 0, 35), ZIndex = 7, Parent = contentViewport
}, {
	create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
})

local contentPages = create("Frame", {
	Name = "ContentPages", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -80), Position = UDim2.new(0, 0, 0, 80), ZIndex = 7, Parent = contentViewport
})

local tabs = {}
local activeTabIndicator = create("Frame", {
	Name = "Indicator", Size = UDim2.new(1, -20, 0, 2), Position = UDim2.new(0, 10, 1, -2), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0, ZIndex = 8
}, { create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

local function createTab(name, id, layoutOrder)
	local btn = create("TextButton", {
		Name = id.."Tab", Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
		Text = "  "..name.."  ", Font = Enum.Font.GothamMedium, TextColor3 = THEME.TextDim, TextSize = 14, LayoutOrder = layoutOrder, ZIndex = 8, Parent = tabContainer
	})
	
	local page = create("Frame", {
		Name = id.."Page", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 8, Parent = contentPages
	})
	
	tabs[id] = {Button = btn, Page = page}
	
	btn.MouseButton1Click:Connect(function()
		for tid, tabData in pairs(tabs) do
			if tid == id then
				tween(tabData.Button, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextColor3 = THEME.Text})
				tabData.Page.Visible = true
				tabData.Page.Position = UDim2.new(0, 10, 0, 0)
				tabData.Page.GroupTransparency = 1
				tween(tabData.Page, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Position = UDim2.new(0, 0, 0, 0)})
				-- Fallback for GroupTransparency (CanvasGroups are sometimes buggy in exploits, simulating fade)
				for _, child in pairs(tabData.Page:GetDescendants()) do
					if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
						local orig = child:GetAttribute("OrigTextTrans") or 0
						child.TextTransparency = 1
						tween(child, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = orig})
					elseif child:IsA("Frame") or child:IsA("ScrollingFrame") or child:IsA("ImageLabel") then
						local orig = child:GetAttribute("OrigBgTrans") or child.BackgroundTransparency
						if child.Name ~= "Indicator" and not child:IsA("ScrollingFrame") then
							child.BackgroundTransparency = 1
							tween(child, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = orig})
						end
					end
				end
				
				activeTabIndicator.Parent = btn
			else
				tween(tabData.Button, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextColor3 = THEME.TextDim})
				tabData.Page.Visible = false
			end
		end
	end)
	
	return page
end

-- =========================================================================
-- [ 1 ] MARCADOR DE ~100 LINHAS - SISTEMA DE DRAG E POPUPS
-- =========================================================================

-- Popups System (Overlay)
local popupOverlay = create("Frame", {
	Name = "PopupOverlay", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 1, Visible = false, ZIndex = 50, Parent = contentViewport
}, { create("UICorner", {CornerRadius = UDim.new(0, 12)}) })

local popupContainer = create("Frame", {
	Name = "PopupContainer", Size = UDim2.new(0.8, 0, 0.8, 0), Position = UDim2.new(0.5, 0, 0.6, 0), AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = THEME.Primary, BackgroundTransparency = 1, ZIndex = 51, Parent = popupOverlay
}, {
	create("UICorner", {CornerRadius = UDim.new(0, 12)}),
	create("UIStroke", {Color = THEME.TextDim, Transparency = 1, Thickness = 1})
})

local function openPopup(contentBuilder)
	popupContainer:ClearAllChildren()
	create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = popupContainer})
	create("UIStroke", {Color = THEME.TextDim, Transparency = 0.8, Thickness = 1, Parent = popupContainer})
	
	local closeBtn = create("TextButton", {
		Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -10, 0, 10), AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1, Text = "X", Font = Enum.Font.GothamBold, TextColor3 = THEME.Danger, TextSize = 16, ZIndex = 60, Parent = popupContainer
	})
	
	contentBuilder(popupContainer)
	
	popupOverlay.Visible = true
	popupContainer.Position = UDim2.new(0.5, 0, 0.55, 0)
	tween(popupOverlay, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 0.5})
	tween(popupContainer, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0})
	
	closeBtn.MouseButton1Click:Connect(function()
		tween(popupOverlay, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {BackgroundTransparency = 1})
		local t = tween(popupContainer, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {Position = UDim2.new(0.5, 0, 0.55, 0), BackgroundTransparency = 1})
		t.Completed:Connect(function() popupOverlay.Visible = false end)
	end)
end

local function closePopup()
	tween(popupOverlay, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {BackgroundTransparency = 1})
	local t = tween(popupContainer, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {Position = UDim2.new(0.5, 0, 0.55, 0), BackgroundTransparency = 1})
	t.Completed:Connect(function() popupOverlay.Visible = false end)
end

-- Drag Logic
local state = "Expanded"
local dragging = false
local activeDragInput = nil
local currentPos = Vector2.new(0, 0)
local targetPos = Vector2.new(0, 0)
local lastPosition = Vector2.new(0, 0)
local dragStartInput = Vector2.zero
local dragStartPos = Vector2.zero

local function getInset() return GuiService:GetGuiInset() end
local function getViewport() return workspace.CurrentCamera.ViewportSize end

local function clampPosition(pos, size)
	local vp = getViewport()
	local inset = getInset()
	local halfX = size.X / 2
	local halfY = size.Y / 2
	return Vector2.new(math.clamp(pos.X, halfX, vp.X - halfX), math.clamp(pos.Y, inset.Y + halfY, vp.Y - halfY))
end

local function playMinimize()
	if state ~= "Expanded" then return end
	state = "Transitioning"
	lastPosition = targetPos  
	targetPos = Vector2.new(getViewport().X / 2, getInset().Y + (SIZES.MINIMIZED.Y.Offset / 2) + 2)
	
	tween(card, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Size = SIZES.MINIMIZED})  
	tween(shadow, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Size = SIZES.MINIMIZED, BackgroundTransparency = 0.95})  
	
	contentViewport.Visible = false  
	minimizeBar.Visible = false  
	openButton.Visible = true  
	tween(openButton, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0})  
	
	task.delay(0.5, function() state = "Minimized" end)
end

local function playExpand()
	if state ~= "Minimized" then return end
	state = "Transitioning"
	targetPos = lastPosition  
	
	tween(openButton, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 1})  
	tween(card, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Size = SIZES.EXPANDED})  
	tween(shadow, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Size = SIZES.EXPANDED, BackgroundTransparency = 0.85})  
	
	task.delay(0.4, function()  
		contentViewport.Visible = true  
		minimizeBar.Visible = true  
		openButton.Visible = false  
		state = "Expanded"  
	end)
end

minimizeButton.MouseButton1Click:Connect(playMinimize)
openButton.MouseButton1Click:Connect(playExpand)

card.InputBegan:Connect(function(input)
	if (state == "Expanded" or state == "Minimized") and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not dragging then
		local pos = input.Position
		-- Impedir arrastar se clicar num botão/textbox (checar parent)
		local allowDrag = true
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Uma verificação simples de área (arrastar pelo topo)
			if pos.Y > card.AbsolutePosition.Y + 60 and state == "Expanded" then allowDrag = false end
		end
		
		if allowDrag then
			dragging = true
			activeDragInput = input
			dragStartInput = Vector2.new(pos.X, pos.Y)
			dragStartPos = targetPos
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and activeDragInput and input == activeDragInput then
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartInput
			targetPos = dragStartPos + delta
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if activeDragInput and input == activeDragInput then
		dragging = false
		activeDragInput = nil
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local activeSize = card.AbsoluteSize
	if state == "Expanded" and not dragging then targetPos = clampPosition(targetPos, activeSize) end  
	currentPos = currentPos:Lerp(targetPos, math.clamp(dt * 14, 0, 1))  
	card.Position = UDim2.fromOffset(currentPos.X, currentPos.Y)  
	shadow.Position = UDim2.fromOffset(currentPos.X, currentPos.Y + 4)  
	shadow.Size = card.Size  
end)

local function initSystem()
	local vp = getViewport()
	local initial = Vector2.new(vp.X / 2, vp.Y / 2)
	currentPos = initial
	targetPos = initial
	lastPosition = initial
end
initSystem()

-- =========================================================================
-- [ 2 ] MARCADOR DE ~300 LINHAS - SYNTAX HIGHLIGHTER & EXECUTOR TAB
-- =========================================================================

local executePage = createTab("Execute", "Exec", 1)
local savesPage = createTab("Saves", "Saves", 2)
local logsPage = createTab("Logs", "Logs", 3)
local scriptbloxPage = createTab("ScriptBlox", "Cloud", 4)
local settingsPage = createTab("Settings", "Config", 5)

-- Ativar primeira aba
tabs["Exec"].Button.TextColor3 = THEME.Text
executePage.Visible = true
activeTabIndicator.Parent = tabs["Exec"].Button

-- Syntax Highlighter Simples e Rápido (Lexer)
local LuaKeywords = {["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,["end"]=true,["false"]=true,["for"]=true,["function"]=true,["if"]=true,["in"]=true,["local"]=true,["nil"]=true,["not"]=true,["or"]=true,["repeat"]=true,["return"]=true,["then"]=true,["true"]=true,["until"]=true,["while"]=true}
local LuaGlobals = {["game"]=true,["workspace"]=true,["script"]=true,["math"]=true,["string"]=true,["table"]=true,["task"]=true,["coroutine"]=true,["Vector2"]=true,["Vector3"]=true,["CFrame"]=true,["Color3"]=true,["UDim2"]=true,["Instance"]=true,["require"]=true,["print"]=true,["warn"]=true,["error"]=true,["pcall"]=true,["xpcall"]=true,["type"]=true,["tostring"]=true,["tonumber"]=true}

local function highlightSyntax(text)
	text = text:gsub("<", "&lt;"):gsub(">", "&gt;") -- Escape HTML tags for RichText
	
	-- Arrays temporários para preservar strings e comentários
	local strings = {}
	local comments = {}
	
	-- Preservar Strings
	text = text:gsub("(['\"])(.-)%1", function(q, cont)
		table.insert(strings, q..cont..q)
		return "\1" .. #strings .. "\1"
	end)
	
	-- Preservar Comentários
	text = text:gsub("%-%-[^\n]*", function(match)
		table.insert(comments, match)
		return "\2" .. #comments .. "\2"
	end)

	-- Destacar Números
	text = text:gsub("%b()", function(c) return c end) -- Bypass ( ) 
	text = text:gsub("[%d]+%.?[%d]*", '<font color="#FFC600">%1</font>')

	-- Destacar Palavras
	text = text:gsub("[%w_]+", function(word)
		if LuaKeywords[word] then return '<font color="#FF6E82">'..word..'</font>' end
		if LuaGlobals[word] then return '<font color="#84D6F7">'..word..'</font>' end
		return word
	end)

	-- Restaurar Comentários
	text = text:gsub("\2(%d+)\2", function(id) return '<font color="#7C7C7C">'..comments[tonumber(id)]..'</font>' end)
	
	-- Restaurar Strings
	text = text:gsub("\1(%d+)\1", function(id) return '<font color="#A5C261">'..strings[tonumber(id)]..'</font>' end)

	return text
end

-- === ABA: EXECUTE ===
local editorWindow = create("Frame", {
	Name = "EditorWindow", Size = UDim2.new(1, 0, 1, -45), BackgroundColor3 = THEME.Secondary, BackgroundTransparency = 0.5, Parent = executePage
}, {
	create("UICorner", {CornerRadius = UDim.new(0, 8)}),
	create("UIStroke", {Color = THEME.TextDim, Transparency = 0.8, Thickness = 1})
})

-- Mac Buttons (Red, Yellow, Green)
local macDots = create("Frame", {Name = "MacDots", Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Parent = editorWindow})
local colors = {THEME.Danger, THEME.Warning, THEME.Success}
for i, c in ipairs(colors) do
	create("Frame", {
		Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 10 + ((i-1)*18), 0.5, -6),
		BackgroundColor3 = c, Parent = macDots
	}, { create("UICorner", {CornerRadius = UDim.new(1, 0)}) })
end

-- Código Box
local codeScroll = create("ScrollingFrame", {
	Name = "CodeScroll", Size = UDim2.new(1, -10, 1, -35), Position = UDim2.new(0, 5, 0, 25),
	BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.XY,
	ScrollBarThickness = 4, ScrollBarImageColor3 = THEME.TextDim, Parent = editorWindow
})

local codeInput = create("TextBox", {
	Name = "CodeInput", Size = UDim2.new(1, -20, 1, -10), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1,
	Font = Enum.Font.Code, TextSize = 14, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	ClearTextOnFocus = false, MultiLine = true, TextTransparency = 1, Text = 'print("Luay Hub!")\n\nlocal player = game.Players.LocalPlayer\nwarn(player.Name)', Parent = codeScroll
})

local codeHighlight = create("TextLabel", {
	Name = "Highlight", Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0), BackgroundTransparency = 1,
	Font = Enum.Font.Code, TextSize = 14, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
	RichText = true, Text = "", ZIndex = 0, Parent = codeInput
})

local function updateSyntax()
	local text = codeInput.Text
	-- Auto-resize box
	local textBounds = game:GetService("TextService"):GetTextSize(text, 14, Enum.Font.Code, Vector2.new(math.huge, math.huge))
	codeInput.Size = UDim2.new(1, -20, 0, math.max(codeScroll.AbsoluteSize.Y, textBounds.Y + 20))
	codeHighlight.Text = highlightSyntax(text)
end

codeInput:GetPropertyChangedSignal("Text"):Connect(updateSyntax)
updateSyntax()

-- =========================================================================
-- [ 3 ] MARCADOR DE ~500 LINHAS - BOTÕES DE AÇÃO E SISTEMA DE SALVAR
-- =========================================================================

local executeActionContainer = create("Frame", {
	Name = "Actions", Size = UDim2.new(1, 0, 0, 35), Position = UDim2.new(0, 0, 1, -35), BackgroundTransparency = 1, Parent = executePage
}, {
	create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 10)})
})

local function createActionButton(name, color, parent)
	local btn = create("TextButton", {
		Name = name.."Btn", Size = UDim2.new(0, 100, 0, 30), BackgroundColor3 = THEME.Secondary, Text = name,
		Font = Enum.Font.GothamMedium, TextColor3 = THEME.Text, TextSize = 14, AutoButtonColor = false, Parent = parent
	}, {
		create("UICorner", {CornerRadius = UDim.new(0, 6)}),
		create("UIStroke", {Color = color, Transparency = 0.5, Thickness = 1})
	})
	applyHover(btn, THEME.Secondary, color)
	return btn
end

local btnClear = createActionButton("Clear", THEME.Danger, executeActionContainer)
local btnSave = createActionButton("Save", THEME.Warning, executeActionContainer)
local btnExecute = createActionButton("Execute", THEME.Success, executeActionContainer)

btnClear.MouseButton1Click:Connect(function() codeInput.Text = "" end)

btnExecute.MouseButton1Click:Connect(function()
	local src = codeInput.Text
	if isExecutor and loadstring then
		local func, err = loadstring(src)
		if func then task.spawn(func) else warn("Luay Syntax Error:\n" .. tostring(err)) end
	else
		warn("Executor doesn't support loadstring! Printing source:\n" .. src)
	end
end)

-- Mock Memória para Saves (Fallback)
local inMemorySaves = {}

local function saveScript(name, content)
	if isExecutor then
		writefile("LuaySaves/"..name..".txt", content)
	else
		inMemorySaves[name] = content
	end
end

local function loadScript(name)
	if isExecutor then
		return readfile("LuaySaves/"..name..".txt")
	else
		return inMemorySaves[name] or ""
	end
end

local function deleteScript(name)
	if isExecutor then
		delfile("LuaySaves/"..name..".txt")
	else
		inMemorySaves[name] = nil
	end
end

local function getSavedScriptsList()
	local list = {}
	if isExecutor then
		local files = listfiles("LuaySaves")
		for _, file in ipairs(files) do
			local n = file:match("LuaySaves[\\/](.+)%.txt")
			if n then table.insert(list, n) end
		end
	else
		for k, v in pairs(inMemorySaves) do table.insert(list, k) end
	end
	return list
end

-- Janela de Save
local function openSaveModal(initialName, initialContent, onSaveCallback)
	openPopup(function(popup)
		create("TextLabel", {
			Size = UDim2.new(1, -40, 0, 30), Position = UDim2.new(0, 20, 0, 15), BackgroundTransparency = 1,
			Text = "Save Script", Font = Enum.Font.GothamBold, TextColor3 = THEME.Text, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left, Parent = popup
		})
		
		local nameBox = create("TextBox", {
			Size = UDim2.new(1, -40, 0, 35), Position = UDim2.new(0, 20, 0, 55), BackgroundColor3 = THEME.Primary,
			Text = initialName or "MyScript", Font = Enum.Font.Gotham, TextColor3 = THEME.Text, TextSize = 14, PlaceholderText = "Script Name...", Parent = popup
		}, { create("UICorner", {CornerRadius = UDim.new(0, 6)}) })
		
		local contentBox = create("TextBox", {
			Size = UDim2.new(1, -40, 1, -155), Position = UDim2.new(0, 20, 0, 100), BackgroundColor3 = THEME.Primary,
			Text = initialContent or codeInput.Text, Font = Enum.Font.Code, TextColor3 = THEME.Text, TextSize = 12, MultiLine = true,
			ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = popup
		}, { create("UICorner", {CornerRadius = UDim.new(0, 6)}) })
		
		local confirmBtn = create("TextButton", {
			Size = UDim2.new(1, -40, 0, 35), Position = UDim2.new(0, 20, 1, -45), BackgroundColor3 = THEME.Success,
			Text = "Save", Font = Enum.Font.GothamBold, TextColor3 = THEME.Primary, TextSize = 14, Parent = popup
		}, { create("UICorner", {CornerRadius = UDim.new(0, 6)}) })
		
		confirmBtn.MouseButton1Click:Connect(function()
			saveScript(nameBox.Text, contentBox.Text)
			closePopup()
			if onSaveCallback then onSaveCallback() end
		end)
	end)
end

btnSave.MouseButton1Click:Connect(function() openSaveModal("", codeInput.Text, nil) end)

-- =========================================================================
-- [ 4 ] MARCADOR DE ~750 LINHAS - ABA DE SAVES
-- =========================================================================

local savesTopBar = create("Frame", {
	Name = "SavesTopBar", Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = savesPage
})

local savesSearch = create("TextBox", {
	Name = "Search", Size = UDim2.new(1, -110, 1, -10), Position = UDim2.new(0, 0, 0, 5), BackgroundColor3 = THEME.Secondary, BackgroundTransparency = 0.5,
	Text = "", PlaceholderText = "Search saved scripts...", Font = Enum.Font.Gotham, TextColor3 = THEME.Text, TextSize = 14, Parent = savesTopBar
}, { create("UICorner", {CornerRadius = UDim.new(0, 6)}), create("UIStroke", {Color = THEME.TextDim, Transparency = 0.8, Thickness = 1}) })

local savesAddBtn = createActionButton("+ New", THEME.Accent, savesTopBar)
savesAddBtn.Size = UDim2.new(0, 100, 1, -10)
savesAddBtn.Position = UDim2.new(1, -100, 0, 5)
savesAddBtn.Parent = savesTopBar

local savesScroll = create("ScrollingFrame", {
	Name = "SavesScroll", Size = UDim2.new(1, 0, 1, -45), Position = UDim2.new(0, 0, 0, 45), BackgroundTransparency = 1,
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = THEME.TextDim, Parent = savesPage
}, { create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)}) })

local function refreshSavesList(filterQuery)
	savesScroll:ClearAllChildren()
	create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = savesScroll})
	
	local list = getSavedScriptsList()
	local query = filterQuery and filterQuery:lower() or ""
	
	for i, name in ipairs(list) do
		if query == "" or name:lower():find(query) then
			local item = create("Frame", {
				Size = UDim2.new(1, -10, 0, 45), BackgroundColor3 = THEME.Secondary, BackgroundTransparency = 0.5, Parent = savesScroll
			}, { create("UICorner", {CornerRadius = UDim.new(0, 6)}), create("UIStroke", {Color = THEME.TextDim, Transparency = 0.9, Thickness = 1}) })
			
			create("TextLabel", {
				Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1,
				Text = name, Font = Enum.Font.GothamMedium, TextColor3 = THEME.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = item
			})
			
			local btnDel = createActionButton("Del", THEME.Danger, item)
			btnDel.Size = UDim2.new(0, 50, 0, 30); btnDel.Position = UDim2.new(1, -170, 0.5, -15)
			
			local btnEdit = createActionButton("Edit", THEME.Warning, item)
			btnEdit.Size = UDim2.new(0, 50, 0, 30); btnEdit.Position = UDim2.new(1, -115, 0.5, -15)
			
			local btnExec = createActionButton("Exec", THEME.Success, item)
			btnExec.Size = UDim2.new(0, 50, 0, 30); btnExec.Position = UDim2.new(1, -60, 0.5, -15)
			
			btnDel.MouseButton1Click:Connect(function()
				deleteScript(name)
				refreshSavesList(savesSearch.Text)
			end)
			
			btnEdit.MouseButton1Click:Connect(function()
				openSaveModal(name, loadScript(name), function() refreshSavesList(savesSearch.Text) end)
			end)
			
			btnExec.MouseButton1Click:Connect(function()
				local src = loadScript(name)
				if isExecutor and loadstring then
					local func, err = loadstring(src)
					if func then task.spawn(func) else warn("Exec Error: "..tostring(err)) end
				end
			end)
		end
	end
end

savesSearch:GetPropertyChangedSignal("Text"):Connect(function() refreshSavesList(savesSearch.Text) end)
savesAddBtn.MouseButton1Click:Connect(function() openSaveModal("", "", function() refreshSavesList(savesSearch.Text) end) end)

-- Carregar Inicial
refreshSavesList()

-- =========================================================================
-- [ 5 ] MARCADOR DE ~1000 LINHAS - ABA DE LOGS
-- =========================================================================

local logsTopBar = create("Frame", { Name = "LogsTopBar", Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = logsPage })

create("TextLabel", {
	Size = UDim2.new(0, 200, 1, 0), BackgroundTransparency = 1, Text = "Console Output", Font = Enum.Font.GothamBold,
	TextColor3 = THEME.TextDim, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = logsTopBar
})

local btnClearLogs = createActionButton("Clear Logs", THEME.Danger, logsTopBar)
btnClearLogs.Size = UDim2.new(0, 100, 1, -10)
btnClearLogs.Position = UDim2.new(1, -100, 0, 5)

local logsScroll = create("ScrollingFrame", {
	Name = "LogsScroll", Size = UDim2.new(1, 0, 1, -45), Position = UDim2.new(0, 0, 0, 45), BackgroundColor3 = THEME.Secondary, BackgroundTransparency = 0.5,
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = THEME.TextDim, Parent = logsPage
}, {
	create("UICorner", {CornerRadius = UDim.new(0, 6)}), create("UIStroke", {Color = THEME.TextDim, Transparency = 0.8, Thickness = 1}),
	create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
})

local function addLog(msg, logType)
	local color = THEME.Text
	if logType == Enum.MessageType.MessageWarning then color = THEME.Warning
	elseif logType == Enum.MessageType.MessageError then color = THEME.Danger
	elseif logType == Enum.MessageType.MessageInfo then color = THEME.Accent end
	
	local lbl = create("TextLabel", {
		Size = UDim2.new(1, -10, 0, 0), Position = UDim2.new(0, 5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = msg, Font = Enum.Font.Code, TextColor3 = color, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = logsScroll
	})
	
	-- Auto scroll to bottom
	task.defer(function()
		logsScroll.CanvasPosition = Vector2.new(0, logsScroll.AbsoluteCanvasSize.Y)
	end)
end

LogService.MessageOut:Connect(addLog)
btnClearLogs.MouseButton1Click:Connect(function()
	logsScroll:ClearAllChildren()
	create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = logsScroll})
end)

-- Adiciona um log inicial mockado
addLog("Luay Hub Injetado com sucesso.", Enum.MessageType.MessageInfo)

-- =========================================================================
-- [ 6 ] MARCADOR DE ~1200 LINHAS - ABA SCRIPTBLOX
-- =========================================================================

local sbTopBar = create("Frame", { Name = "SbTopBar", Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = scriptbloxPage })

local sbSearch = create("TextBox", {
	Name = "Search", Size = UDim2.new(1, -220, 1, -10), Position = UDim2.new(0, 0, 0, 5), BackgroundColor3 = THEME.Secondary, BackgroundTransparency = 0.5,
	Text = "", PlaceholderText = "Search ScriptBlox...", Font = Enum.Font.Gotham, TextColor3 = THEME.Text, TextSize = 14, Parent = sbTopBar
}, { create("UICorner", {CornerRadius = UDim.new(0, 6)}), create("UIStroke", {Color = THEME.TextDim, Transparency = 0.8, Thickness = 1}) })

local sbCheckboxFrame = create("Frame", {
	Size = UDim2.new(0, 110, 1, -10), Position = UDim2.new(1, -210, 0, 5), BackgroundTransparency = 1, Parent = sbTopBar
})

local sbCheckBtn = create("TextButton", {
	Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0, 0, 0.5, -10), BackgroundColor3 = THEME.Secondary, Text = "", Parent = sbCheckboxFrame
}, { create("UICorner", {CornerRadius = UDim.new(0, 4)}), create("UIStroke", {Color = THEME.TextDim, Transparency = 0.5, Thickness = 1}) })
local sbCheckMark = create("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "✓", Font = Enum.Font.GothamBold, TextColor3 = THEME.Accent, TextSize = 14, Visible = false, Parent = sbCheckBtn
})

create("TextLabel", {
	Size = UDim2.new(1, -25, 1, 0), Position = UDim2.new(0, 25, 0, 0), BackgroundTransparency = 1, Text = "Only Game", Font = Enum.Font.Gotham,
	TextColor3 = THEME.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = sbCheckboxFrame
})

local isOnlyGame = false
sbCheckBtn.MouseButton1Click:Connect(function()
	isOnlyGame = not isOnlyGame
	sbCheckMark.Visible = isOnlyGame
end)

local sbSearchBtn = createActionButton("Search", THEME.Accent, sbTopBar)
sbSearchBtn.Size = UDim2.new(0, 90, 1, -10)
sbSearchBtn.Position = UDim2.new(1, -90, 0, 5)

local sbScroll = create("ScrollingFrame", {
	Name = "SbScroll", Size = UDim2.new(1, 0, 1, -45), Position = UDim2.new(0, 0, 0, 45), BackgroundTransparency = 1,
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = THEME.TextDim, Parent = scriptbloxPage
}, { create("UIGridLayout", {CellSize = UDim2.new(0.5, -5, 0, 80), CellPadding = UDim2.new(0, 10, 0, 10), SortOrder = Enum.SortOrder.LayoutOrder}) })

-- ScriptBlox Popup Detail
local function openSbDetail(scriptData)
	openPopup(function(popup)
		create("TextLabel", {
			Size = UDim2.new(1, -40, 0, 30), Position = UDim2.new(0, 20, 0, 15), BackgroundTransparency = 1,
			Text = scriptData.title, Font = Enum.Font.GothamBold, TextColor3 = THEME.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = popup
		})
		
		local typ = scriptData.game and scriptData.game.name or "Universal"
		create("TextLabel", {
			Size = UDim2.new(1, -40, 0, 20), Position = UDim2.new(0, 20, 0, 45), BackgroundTransparency = 1,
			Text = "Game: " .. typ, Font = Enum.Font.Gotham, TextColor3 = THEME.TextDim, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = popup
		})
		
		local preview = create("ScrollingFrame", {
			Size = UDim2.new(1, -40, 1, -135), Position = UDim2.new(0, 20, 0, 75), BackgroundColor3 = THEME.Primary,
			CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.XY, Parent = popup
		}, { create("UICorner", {CornerRadius = UDim.new(0,6)}) })
		
		create("TextLabel", {
			Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY,
			Text = scriptData.script or "-- No preview available", Font = Enum.Font.Code, TextColor3 = THEME.TextDim, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = preview
		})
		
		local actions = create("Frame", { Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 1, -50), BackgroundTransparency = 1, Parent = popup }, {
			create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 10)})
		})
		
		local cBtn = createActionButton("Copy", THEME.Warning, actions)
		local sBtn = createActionButton("Save", THEME.Accent, actions)
		local eBtn = createActionButton("Execute", THEME.Success, actions)
		
		cBtn.MouseButton1Click:Connect(function() if CLIPBOARD then CLIPBOARD(scriptData.script) else warn("Clipboard not supported") end end)
		sBtn.MouseButton1Click:Connect(function() saveScript(scriptData.title:gsub("[%p%c]", ""), scriptData.script); closePopup() end)
		eBtn.MouseButton1Click:Connect(function()
			if isExecutor and loadstring then
				local f, err = loadstring(scriptData.script)
				if f then task.spawn(f) end
			end
		end)
	end)
end

local function fetchScriptBlox()
	sbScroll:ClearAllChildren()
	create("UIGridLayout", {CellSize = UDim2.new(0.5, -5, 0, 80), CellPadding = UDim2.new(0, 10, 0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sbScroll})
	
	create("TextLabel", { Name="Loading", Size=UDim2.new(2,0,0,30), BackgroundTransparency=1, Text="Searching...", Font=Enum.Font.Gotham, TextColor3=THEME.TextDim, TextSize=14, Parent=sbScroll })
	
	task.spawn(function()
		local query = sbSearch.Text
		local endpoint = "https://scriptblox.com/api/script/fetch?page=1"
		
		if query ~= "" then
			endpoint = "https://scriptblox.com/api/script/search?q="..HttpService:UrlEncode(query).."&mode=free&page=1"
		end
		
		-- Try to get Game Name if checkbox is checked
		if isOnlyGame then
			local s, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
			if s and info and info.Name then
				endpoint = "https://scriptblox.com/api/script/search?q="..HttpService:UrlEncode(info.Name).."&mode=free&page=1"
			end
		end
		
		local success, response
		if GET then
			success, response = pcall(function() return GET({Url = endpoint, Method = "GET"}).Body end)
		else
			-- Fallback para testar no studio, não vai funcionar real, mockup data
			task.wait(1)
			success = true
			response = '{"result":{"scripts":[{"title":"Mock Universal Admin","slug":"admin","game":{"name":"Universal"},"script":"print(\'Admin Executed\')"},{"title":"Aimbot Pro","slug":"aim","game":{"name":"Arsenal"},"script":"print(\'Aimbot On\')"}]}}'
		end
		
		sbScroll:ClearAllChildren()
		create("UIGridLayout", {CellSize = UDim2.new(0.5, -5, 0, 80), CellPadding = UDim2.new(0, 10, 0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sbScroll})
		
		if success and response then
			local data = HttpService:JSONDecode(response)
			if data and data.result and data.result.scripts then
				for _, scriptObj in ipairs(data.result.scripts) do
					local typ = scriptObj.game and scriptObj.game.name or "Universal"
					
					local card = create("TextButton", {
						Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = THEME.Secondary, BackgroundTransparency = 0.5, Text = "", AutoButtonColor = false, Parent = sbScroll
					}, { create("UICorner", {CornerRadius = UDim.new(0, 8)}), create("UIStroke", {Color = THEME.TextDim, Transparency = 0.8, Thickness = 1}) })
					
					applyHover(card, THEME.Secondary, Color3.fromRGB(44, 44, 50))
					
					create("TextLabel", {
						Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1,
						Text = scriptObj.title, Font = Enum.Font.GothamBold, TextColor3 = THEME.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = card
					})
					
					create("TextLabel", {
						Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 45), BackgroundTransparency = 1,
						Text = "Game: " .. typ, Font = Enum.Font.Gotham, TextColor3 = THEME.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = card
					})
					
					card.MouseButton1Click:Connect(function() openSbDetail(scriptObj) end)
				end
			end
		else
			create("TextLabel", { Name="Err", Size=UDim2.new(2,0,0,30), BackgroundTransparency=1, Text="Failed to fetch API.", Font=Enum.Font.Gotham, TextColor3=THEME.Danger, TextSize=14, Parent=sbScroll })
		end
	end)
end

sbSearchBtn.MouseButton1Click:Connect(fetchScriptBlox)
sbSearch.FocusLost:Connect(function(enter) if enter then fetchScriptBlox() end end)
fetchScriptBlox() -- Iniciar puxando recentes

-- =========================================================================
-- [ 7 ] MARCADOR DE ~1600 LINHAS - ABA DE SETTINGS E FINALIZAÇÃO
-- =========================================================================

local settingsScroll = create("ScrollingFrame", {
	Name = "SettingsScroll", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
	CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0, Parent = settingsPage
}, { create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)}) })

local function createSettingToggle(name, defaultState, callback)
	local container = create("Frame", {
		Size = UDim2.new(1, -10, 0, 50), BackgroundColor3 = THEME.Secondary, BackgroundTransparency = 0.5, Parent = settingsScroll
	}, { create("UICorner", {CornerRadius = UDim.new(0, 8)}), create("UIStroke", {Color = THEME.TextDim, Transparency = 0.8, Thickness = 1}) })
	
	create("TextLabel", {
		Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1,
		Text = name, Font = Enum.Font.GothamMedium, TextColor3 = THEME.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = container
	})
	
	local toggleBg = create("TextButton", {
		Size = UDim2.fromOffset(50, 24), Position = UDim2.new(1, -65, 0.5, -12), BackgroundColor3 = defaultState and THEME.Accent or THEME.Primary, Text = "", Parent = container
	}, { create("UICorner", {CornerRadius = UDim.new(1, 0)}), create("UIStroke", {Color = THEME.TextDim, Transparency = 0.5, Thickness = 1}) })
	
	local toggleDot = create("Frame", {
		Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0, defaultState and 29 or 3, 0.5, -9), BackgroundColor3 = THEME.Text, Parent = toggleBg
	}, { create("UICorner", {CornerRadius = UDim.new(1, 0)}) })
	
	local state = defaultState
	toggleBg.MouseButton1Click:Connect(function()
		state = not state
		tween(toggleBg, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = state and THEME.Accent or THEME.Primary})
		tween(toggleDot, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Position = UDim2.new(0, state and 29 or 3, 0.5, -9)})
		callback(state)
	end)
end

createSettingToggle("Enable Glass Blur", true, function(val)
	tween(mask.BlurImage, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {ImageTransparency = val and 0.16 or 1})
end)

createSettingToggle("Enable Frost Effect", true, function(val)
	tween(mask.Frost, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = val and 0.98 or 1})
end)

createSettingToggle("Darker Background", false, function(val)
	tween(mask.Tint, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = val and 0.2 or 0.5})
end)

-- Botão final de Destroy
local killBtn = createActionButton("Destroy Hub", THEME.Danger, settingsScroll)
killBtn.Size = UDim2.new(1, -10, 0, 40)
killBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Animação Inicial Suave
card.Size = UDim2.fromOffset(0, 0)
shadow.Size = UDim2.fromOffset(0, 0)
card.BackgroundTransparency = 1
contentViewport.GroupTransparency = 1 -- Hide contents initially
tween(card, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Size = SIZES.EXPANDED, BackgroundTransparency = 0.26})
tween(shadow, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Size = SIZES.EXPANDED})
task.wait(0.4)
tween(contentViewport, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {GroupTransparency = 0})

print("Luay Hub Loaded Successfully!")

