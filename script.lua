-- Voice TTS + AI Chat (HTTP Version)
print("[VoiceTTS] Iniciando...")

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Habilita HttpService
local success, err = pcall(function()
    HttpService.HttpEnabled = true
end)

if not success then
    warn("[VoiceTTS] Aviso: HttpService pode estar bloqueado")
end

local SERVER_URL = "http://localhost:5000"

pcall(function()
    if game.CoreGui:FindFirstChild("VoiceTTSGui") then
        game.CoreGui:FindFirstChild("VoiceTTSGui"):Destroy()
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoiceTTSGui"
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 400)
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(0, 0, 0)
UIStroke.Thickness = 3

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "AS VoiceTTS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Active = true

-- Tabs Container
local TabsFrame = Instance.new("Frame")
TabsFrame.Parent = MainFrame
TabsFrame.BackgroundTransparency = 1
TabsFrame.Position = UDim2.new(0, 0, 0, 35)
TabsFrame.Size = UDim2.new(1, 0, 0, 30)

local function createTab(name, pos)
    local tab = Instance.new("TextButton")
    tab.Parent = TabsFrame
    tab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tab.Position = UDim2.new(0, pos, 0, 0)
    tab.Size = UDim2.new(0, 70, 0, 28)
    tab.Font = Enum.Font.Gotham
    tab.Text = name
    tab.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab.TextSize = 11
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tab
    return tab
end

local tab1 = createTab("Chat", 5)
local tab2 = createTab("Música", 77)
local tab3 = createTab("Player", 149)

-- Content Frames
local Content1 = Instance.new("Frame")
Content1.Parent = MainFrame
Content1.BackgroundTransparency = 1
Content1.Position = UDim2.new(0, 0, 0, 70)
Content1.Size = UDim2.new(1, 0, 1, -70)
Content1.Visible = true

local Content2 = Instance.new("Frame")
Content2.Parent = MainFrame
Content2.BackgroundTransparency = 1
Content2.Position = UDim2.new(0, 0, 0, 70)
Content2.Size = UDim2.new(1, 0, 1, -70)
Content2.Visible = false

local Content3 = Instance.new("Frame")
Content3.Parent = MainFrame
Content3.BackgroundTransparency = 1
Content3.Position = UDim2.new(0, 0, 0, 70)
Content3.Size = UDim2.new(1, 0, 1, -70)
Content3.Visible = false

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Parent = MainFrame
rejoinBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
rejoinBtn.Position = UDim2.new(1, -35, 0, 3)
rejoinBtn.Size = UDim2.new(0, 30, 0, 28)
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.Text = "R"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.TextSize = 14

local rejoinCorner = Instance.new("UICorner")
rejoinCorner.CornerRadius = UDim.new(0, 6)
rejoinCorner.Parent = rejoinBtn

-- Dragging
local dragging, dragInput, dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Buttons
local function createButton(name, parent, yPos)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local indicator = Instance.new("Frame")
    indicator.Parent = btn
    indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    indicator.Position = UDim2.new(1, -25, 0.5, -8)
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.BorderSizePixel = 0
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    return btn, indicator
end

local function createSimpleButton(name, parent, yPos)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    return btn
end

local function createModeButton(name, parent, xPos, yPos)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Position = UDim2.new(0, xPos, 0, yPos)
    btn.Size = UDim2.new(0, 95, 0, 30)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local indicator = Instance.new("Frame")
    indicator.Parent = btn
    indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    indicator.Position = UDim2.new(1, -20, 0.5, -6)
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.BorderSizePixel = 0
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    return btn, indicator
end

-- ABA 1: CHAT
local voiceInputBox = Instance.new("TextBox")
voiceInputBox.Parent = Content1
voiceInputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
voiceInputBox.Position = UDim2.new(0, 10, 0, 5)
voiceInputBox.Size = UDim2.new(0, 200, 0, 30)
voiceInputBox.Font = Enum.Font.Gotham
voiceInputBox.PlaceholderText = "Digite para falar..."
voiceInputBox.Text = ""
voiceInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
voiceInputBox.TextSize = 12
voiceInputBox.ClearTextOnFocus = false

local voiceInputCorner = Instance.new("UICorner")
voiceInputCorner.CornerRadius = UDim.new(0, 6)
voiceInputCorner.Parent = voiceInputBox

local voiceSendBtn = createSimpleButton("Falar", Content1, 40)

local allChatBtn, allChatIndicator = createButton("All Chat TTS", Content1, 85)

-- Background para Fila e New
local modeBackground = Instance.new("Frame")
modeBackground.Parent = Content1
modeBackground.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
modeBackground.Position = UDim2.new(0, 10, 0, 120)
modeBackground.Size = UDim2.new(0, 200, 0, 45)
modeBackground.BorderSizePixel = 0

local modeBackgroundCorner = Instance.new("UICorner")
modeBackgroundCorner.CornerRadius = UDim.new(0, 6)
modeBackgroundCorner.Parent = modeBackground

local filaBtn, filaIndicator = createModeButton("Fila", Content1, 10, 130)
local newBtn, newIndicator = createModeButton("New", Content1, 115, 130)

local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = Content1
speedLabel.BackgroundTransparency = 1
speedLabel.Position = UDim2.new(0, 10, 0, 170)
speedLabel.Size = UDim2.new(0, 200, 0, 15)
speedLabel.Font = Enum.Font.Gotham
speedLabel.Text = "Velocidade: 1.0x"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 11
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedTrack = Instance.new("Frame")
speedTrack.Parent = Content1
speedTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedTrack.Position = UDim2.new(0, 10, 0, 190)
speedTrack.Size = UDim2.new(0, 200, 0, 6)
speedTrack.BorderSizePixel = 0

local speedTrackCorner = Instance.new("UICorner")
speedTrackCorner.CornerRadius = UDim.new(1, 0)
speedTrackCorner.Parent = speedTrack

local speedHandle = Instance.new("Frame")
speedHandle.Parent = speedTrack
speedHandle.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
speedHandle.Position = UDim2.new(0, 0, 0.5, -8)
speedHandle.Size = UDim2.new(0, 16, 0, 16)
speedHandle.BorderSizePixel = 0

local speedHandleCorner = Instance.new("UICorner")
speedHandleCorner.CornerRadius = UDim.new(1, 0)
speedHandleCorner.Parent = speedHandle

-- ABA 2: MÚSICA
local musicBtn, musicIndicator = createButton("Música YouTube", Content2, 5)

-- Background para elementos de música
local musicBackground = Instance.new("Frame")
musicBackground.Parent = Content2
musicBackground.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
musicBackground.Position = UDim2.new(0, 10, 0, 40)
musicBackground.Size = UDim2.new(0, 200, 0, 130)
musicBackground.BorderSizePixel = 0

local musicBackgroundCorner = Instance.new("UICorner")
musicBackgroundCorner.CornerRadius = UDim.new(0, 6)
musicBackgroundCorner.Parent = musicBackground

local musicInputBox = Instance.new("TextBox")
musicInputBox.Parent = Content2
musicInputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
musicInputBox.Position = UDim2.new(0, 10, 0, 50)
musicInputBox.Size = UDim2.new(0, 200, 0, 30)
musicInputBox.Font = Enum.Font.Gotham
musicInputBox.PlaceholderText = "Nome da música..."
musicInputBox.Text = ""
musicInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
musicInputBox.TextSize = 12
musicInputBox.ClearTextOnFocus = false

local musicInputCorner = Instance.new("UICorner")
musicInputCorner.CornerRadius = UDim.new(0, 6)
musicInputCorner.Parent = musicInputBox

local musicPlayBtn = Instance.new("TextButton")
musicPlayBtn.Parent = Content2
musicPlayBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
musicPlayBtn.Position = UDim2.new(0, 10, 0, 90)
musicPlayBtn.Size = UDim2.new(0, 200, 0, 30)
musicPlayBtn.Font = Enum.Font.GothamBold
musicPlayBtn.Text = "Tocar"
musicPlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
musicPlayBtn.TextSize = 13

local musicPlayCorner = Instance.new("UICorner")
musicPlayCorner.CornerRadius = UDim.new(0, 6)
musicPlayCorner.Parent = musicPlayBtn

local playerPermissionBtn = Instance.new("TextButton")
playerPermissionBtn.Parent = Content2
playerPermissionBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
playerPermissionBtn.Position = UDim2.new(0, 10, 0, 130)
playerPermissionBtn.Size = UDim2.new(0, 200, 0, 35)
playerPermissionBtn.Font = Enum.Font.Gotham
playerPermissionBtn.Text = "Players /play"
playerPermissionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playerPermissionBtn.TextSize = 13

local playerPermissionCorner = Instance.new("UICorner")
playerPermissionCorner.CornerRadius = UDim.new(0, 6)
playerPermissionCorner.Parent = playerPermissionBtn

local playerPermissionIndicator = Instance.new("Frame")
playerPermissionIndicator.Parent = playerPermissionBtn
playerPermissionIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
playerPermissionIndicator.Position = UDim2.new(1, -25, 0.5, -8)
playerPermissionIndicator.Size = UDim2.new(0, 16, 0, 16)
playerPermissionIndicator.BorderSizePixel = 0

local playerPermissionIndicatorCorner = Instance.new("UICorner")
playerPermissionIndicatorCorner.CornerRadius = UDim.new(1, 0)
playerPermissionIndicatorCorner.Parent = playerPermissionIndicator

-- ABA 3: PLAYER
local RunService = game:GetService("RunService")
local flying, flySpeed, bodyVelocity, bodyGyro = false, 65, nil, nil
local speedEnabled, walkSpeed = false, 65
local jumpEnabled, jumpPower = false, 100
local clickTpEnabled = false
local invisEnabled = false
local freezeEnabled = false
local frozenCFrame = nil
local origTrans = {}
local origName = {}

-- Anti-Fling automático (proteção contra toque com players)
local MaxVel = 120
local MaxVert = 80

RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local v = root.Velocity
        if v.Magnitude > MaxVel then
            v = v.Unit * MaxVel
        end
        v = Vector3.new(v.X, math.clamp(v.Y, -MaxVert, MaxVert), v.Z)
        root.Velocity = v
        root.AssemblyLinearVelocity = v
    end)
end)

local function createValueBox(parent, yPos, text)
    local box = Instance.new("TextBox")
    box.Parent = parent
    box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    box.Position = UDim2.new(0, 165, 0, yPos)
    box.Size = UDim2.new(0, 45, 0, 35)
    box.Font = Enum.Font.Gotham
    box.Text = text
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 12
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box
    return box
end

local flyBtn, flyIndicator = createButton("Fly", Content3, 5)
local flySpeedBox = createValueBox(Content3, 5, "65")

local speedBtn, speedIndicator = createButton("Speed", Content3, 50)
local speedBox = createValueBox(Content3, 50, "65")

local jumpBtn, jumpIndicator = createButton("SuperJump", Content3, 95)
local jumpBox = createValueBox(Content3, 95, "100")

local invisBtn, invisIndicator = createButton("Invisibilidade", Content3, 140)

local freezeBtn, freezeIndicator = createButton("Congelar Posição", Content3, 185)

local tpBtn = Instance.new("TextButton")
tpBtn.Parent = Content3
tpBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
tpBtn.Position = UDim2.new(0, 10, 0, 230)
tpBtn.Size = UDim2.new(0, 165, 0, 35)
tpBtn.Font = Enum.Font.Gotham
tpBtn.Text = "TP Players ▼"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.TextSize = 13
local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 6)
tpCorner.Parent = tpBtn

local clickTpBtn = Instance.new("TextButton")
clickTpBtn.Parent = Content3
clickTpBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
clickTpBtn.Position = UDim2.new(0, 180, 0, 230)
clickTpBtn.Size = UDim2.new(0, 30, 0, 35)
clickTpBtn.Text = "Q"
clickTpBtn.Font = Enum.Font.GothamBold
clickTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clickTpBtn.TextSize = 14
local clickTpCorner = Instance.new("UICorner")
clickTpCorner.CornerRadius = UDim.new(0, 6)
clickTpCorner.Parent = clickTpBtn

local clickTpIndicator = Instance.new("Frame")
clickTpIndicator.Parent = clickTpBtn
clickTpIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
clickTpIndicator.Position = UDim2.new(1, -10, 0, 3)
clickTpIndicator.Size = UDim2.new(0, 8, 0, 8)
clickTpIndicator.BorderSizePixel = 0
local clickTpIndicatorCorner = Instance.new("UICorner")
clickTpIndicatorCorner.CornerRadius = UDim.new(1, 0)
clickTpIndicatorCorner.Parent = clickTpIndicator

local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Parent = Content3
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PlayerListFrame.Position = UDim2.new(0, 10, 0, 270)
PlayerListFrame.Size = UDim2.new(0, 200, 0, 60)
PlayerListFrame.Visible = false
local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 8)
listCorner.Parent = PlayerListFrame
local listStroke = Instance.new("UIStroke")
listStroke.Parent = PlayerListFrame
listStroke.Color = Color3.fromRGB(0, 0, 0)
listStroke.Thickness = 3

local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Parent = PlayerListFrame
PlayerListScroll.BackgroundTransparency = 1
PlayerListScroll.Size = UDim2.new(1, 0, 1, 0)
PlayerListScroll.ScrollBarThickness = 4
PlayerListScroll.BorderSizePixel = 0

local function startFly()
    flying = true
    pcall(function()
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not root or not humanoid then return end
        humanoid.PlatformStand = true
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = root
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root
    end)
end

local function stopFly()
    flying = false
    pcall(function()
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if not flying or not player.Character then return end
    pcall(function()
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root or not bodyVelocity then return end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
        bodyVelocity.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * flySpeed or Vector3.zero
        bodyGyro.CFrame = cam.CFrame
    end)
end)

local function updateSpeed()
    pcall(function()
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speedEnabled and walkSpeed or 16
            end
        end
    end)
end

local function updateJump()
    pcall(function()
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = jumpEnabled and jumpPower or 50
            end
        end
    end)
end

local function updatePlayerList()
    for _, child in pairs(PlayerListScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local yPos = 0
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local frame = Instance.new("Frame")
            frame.Parent = PlayerListScroll
            frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            frame.Position = UDim2.new(0, 5, 0, yPos)
            frame.Size = UDim2.new(1, -10, 0, 40)
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = frame
            
            local img = Instance.new("ImageLabel")
            img.Parent = frame
            img.BackgroundTransparency = 1
            img.Position = UDim2.new(0, 5, 0.5, -15)
            img.Size = UDim2.new(0, 30, 0, 30)
            img.Image = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=48&h=48"
            local imgCorner = Instance.new("UICorner")
            imgCorner.CornerRadius = UDim.new(1, 0)
            imgCorner.Parent = img
            
            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 40, 0, 0)
            label.Size = UDim2.new(1, -45, 1, 0)
            label.Font = Enum.Font.Gotham
            label.Text = plr.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local btn = Instance.new("TextButton")
            btn.Parent = frame
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Text = ""
            btn.MouseButton1Click:Connect(function()
                pcall(function()
                    if player.Character and plr.Character then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if root and targetRoot then
                            root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                        end
                    end
                end)
                PlayerListFrame.Visible = false
            end)
            yPos = yPos + 45
        end
    end
    PlayerListScroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then startFly() else stopFly() end
    flyIndicator.BackgroundColor3 = flying and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    updateSpeed()
    speedIndicator.BackgroundColor3 = speedEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

jumpBtn.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    updateJump()
    jumpIndicator.BackgroundColor3 = jumpEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

local function setInvisibility(enabled)
    pcall(function()
        local char = player.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if enabled then
                origName[hum] = { hum.DisplayDistanceType, hum.NameDisplayDistance }
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                hum.NameDisplayDistance = 0
            elseif origName[hum] then
                hum.DisplayDistanceType = origName[hum][1]
                hum.NameDisplayDistance = origName[hum][2]
            end
        end
        
        for _, o in ipairs(char:GetDescendants()) do
            if o:IsA("BasePart") or o:IsA("Decal") or o:IsA("Texture") or o:IsA("MeshPart") then
                if enabled then
                    if origTrans[o] == nil then
                        origTrans[o] = o.Transparency
                    end
                    o.Transparency = 1
                else
                    if origTrans[o] ~= nil then
                        o.Transparency = origTrans[o]
                    end
                end
            end
        end
        
        if not enabled then
            origTrans = {}
        end
    end)
end

invisBtn.MouseButton1Click:Connect(function()
    invisEnabled = not invisEnabled
    setInvisibility(invisEnabled)
    invisIndicator.BackgroundColor3 = invisEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

freezeBtn.MouseButton1Click:Connect(function()
    freezeEnabled = not freezeEnabled
    if freezeEnabled then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then frozenCFrame = root.CFrame end
    end
    freezeIndicator.BackgroundColor3 = freezeEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

RunService.Heartbeat:Connect(function()
    if freezeEnabled and frozenCFrame then
        pcall(function()
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = frozenCFrame
                root.Velocity = Vector3.new()
            end
        end)
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    PlayerListFrame.Visible = not PlayerListFrame.Visible
    if PlayerListFrame.Visible then updatePlayerList() end
end)

clickTpBtn.MouseButton1Click:Connect(function()
    clickTpEnabled = not clickTpEnabled
    clickTpIndicator.BackgroundColor3 = clickTpEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

flySpeedBox.FocusLost:Connect(function()
    local value = tonumber(flySpeedBox.Text)
    if value and value >= 1 and value <= 500 then
        flySpeed = value
    else
        flySpeed = 65
        flySpeedBox.Text = "65"
    end
end)

speedBox.FocusLost:Connect(function()
    local value = tonumber(speedBox.Text)
    if value and value >= 1 and value <= 500 then
        walkSpeed = value
        updateSpeed()
    else
        walkSpeed = 65
        speedBox.Text = "65"
        updateSpeed()
    end
end)

jumpBox.FocusLost:Connect(function()
    local value = tonumber(jumpBox.Text)
    if value and value >= 1 and value <= 500 then
        jumpPower = value
        updateJump()
    else
        jumpPower = 100
        jumpBox.Text = "100"
        updateJump()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if speedEnabled then updateSpeed() end
    if jumpEnabled then updateJump() end
    if flying then startFly() end
    if invisEnabled then
        task.wait(1)
        setInvisibility(true)
    end
end)

-- Tab System Logic
tab1.MouseButton1Click:Connect(function()
    Content1.Visible = true
    Content2.Visible = false
    Content3.Visible = false
    tab1.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    tab2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tab3.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

tab2.MouseButton1Click:Connect(function()
    Content1.Visible = false
    Content2.Visible = true
    Content3.Visible = false
    tab1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tab2.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    tab3.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

tab3.MouseButton1Click:Connect(function()
    Content1.Visible = false
    Content2.Visible = false
    Content3.Visible = true
    tab1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tab2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tab3.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
end)

tab1.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- Variables
local allChatEnabled = false
local PROXIMITY_DISTANCE = 50
local ttsSpeed = 1.0
local musicEnabled = false
local musicPlaying = false
local musicSearching = false
local musicToggling = false
local playerCanPlay = false

-- Queue System
local queueMode = true
local messageQueue = {}
local messageQueueNew = {}
local isProcessingQueue = false
local currentTTSId = 0
local isPlayingNew = false

-- Speed Slider Logic
local speedDragging = false

speedHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if speedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UIS:GetMouseLocation()
        local trackPos = speedTrack.AbsolutePosition.X
        local trackSize = speedTrack.AbsoluteSize.X
        local relativePos = math.clamp(mousePos.X - trackPos, 0, trackSize)
        local percentage = relativePos / trackSize
        
        ttsSpeed = 1.0 + (percentage * 1.5)
        speedHandle.Position = UDim2.new(percentage, 0, 0.5, -8)
        speedLabel.Text = string.format("Velocidade: %.1fx", ttsSpeed)
        
        task.spawn(function()
            pcall(function()
                request({
                    Url = SERVER_URL .. "/speed",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({speed = ttsSpeed})
                })
            end)
        end)
    end
end)

-- HTTP Functions
local function sendTTS(text, ttsId, priority)
    print("[DEBUG] Enviando TTS:", text, "ID:", ttsId, "Prioridade:", priority)
    task.spawn(function()
        local success, result = pcall(function()
            local response = request({
                Url = SERVER_URL .. "/tts",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode({text = text, priority = priority, speed = ttsSpeed})
            })
            return response
        end)
        if success then
            print("[TTS] Sucesso! ID:", ttsId)
        else
            warn("[TTS] Erro:", result)
        end
    end)
end

local function processNewMode()
    if isPlayingNew then return end
    isPlayingNew = true
    
    task.spawn(function()
        while allChatEnabled and not queueMode do
            if #messageQueueNew > 0 then
                -- Sempre pega a última mensagem e descarta todas as outras
                local msg = messageQueueNew[#messageQueueNew]
                messageQueueNew = {}
                
                print("[NEW] Lendo mensagem mais recente:", msg.text)
                sendTTS(msg.text, msg.id, "low")
                
                local textLength = #msg.text
                local waitTime = math.max(1, textLength * 0.08)
                task.wait(waitTime)
                
                -- Aguarda 1 segundo antes de procurar próxima mensagem
                task.wait(1)
            else
                -- Se não há mensagens, aguarda até ter
                task.wait(0.5)
            end
        end
        isPlayingNew = false
    end)
end

local function processQueue()
    if isProcessingQueue then return end
    isProcessingQueue = true
    
    task.spawn(function()
        while #messageQueue > 0 and allChatEnabled and queueMode do
            local msg = table.remove(messageQueue, 1)
            sendTTS(msg.text, msg.id, "low")
            
            local textLength = #msg.text
            local waitTime = math.max(1, textLength * 0.08)
            print("[FILA] Aguardando", waitTime, "segundos")
            task.wait(waitTime)
            
            -- Aguarda 1 segundo entre mensagens
            task.wait(1)
        end
        isProcessingQueue = false
    end)
end

local function handleTTS(text, priority)
    currentTTSId = currentTTSId + 1
    local ttsId = currentTTSId
    
    if priority == "high" then
        print("[VOICE TTS] Prioridade alta - limpando fila antiga")
        messageQueue = {}
        messageQueueNew = {}
        isProcessingQueue = false
        isPlayingNew = false
        sendTTS(text, ttsId, "high")
        
        task.spawn(function()
            task.wait(5)
            if allChatEnabled then
                if queueMode then
                    print("[FILA] Iniciando nova fila do zero")
                    processQueue()
                else
                    print("[NEW] Reiniciando modo New")
                    processNewMode()
                end
            end
        end)
    elseif queueMode then
        table.insert(messageQueue, {text = text, id = ttsId})
        print("[FILA] Adicionado:", text, "| Total:", #messageQueue)
        processQueue()
    else
        -- Modo New: usa fila separada
        table.insert(messageQueueNew, {text = text, id = ttsId})
        print("[NEW] Nova mensagem adicionada (total:", #messageQueueNew, ")")
        if not isPlayingNew then
            processNewMode()
        end
    end
end

local function isPlayerNearby(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
    return distance <= PROXIMITY_DISTANCE
end

-- Music Functions
local function searchMusic(query, playerName)
    print("[MUSIC] Buscando:", query)
    
    if musicPlaying then
        print("[MUSIC] Parando música anterior...")
        musicPlaying = false
        stopMusic()
        task.wait(1.5)
    end
    
    musicSearching = true
    musicPlayBtn.Text = "Tocar"
    musicPlayBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    
    task.spawn(function()
        local success, result = pcall(function()
            return request({
                Url = SERVER_URL .. "/music/search",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({query = query, player_name = playerName})
            })
        end)
        
        if not musicSearching then
            print("[MUSIC] Busca cancelada")
            return
        end
        
        if success and result then
            print("[MUSIC] Resposta recebida:", result.StatusCode)
            local data = HttpService:JSONDecode(result.Body)
            if data.found and musicSearching then
                print("[MUSIC] Encontrada:", data.title)
                musicPlaying = true
                musicSearching = false
                musicPlayBtn.Text = "Interromper"
                musicPlayBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            else
                print("[MUSIC] Não encontrada")
                musicPlaying = false
                musicSearching = false
                musicPlayBtn.Text = "Tocar"
                musicPlayBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
            end
        else
            warn("[MUSIC] Erro na requisição:", result)
            musicPlaying = false
            musicSearching = false
            musicPlayBtn.Text = "Tocar"
            musicPlayBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
        end
    end)
end

local function stopMusic()
    task.spawn(function()
        pcall(function()
            request({
                Url = SERVER_URL .. "/music/stop",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({})
            })
        end)
    end)
end

-- Button Events
voiceSendBtn.MouseButton1Click:Connect(function()
    local text = voiceInputBox.Text
    if text == "" or #text < 1 then
        print("[Voice TTS] Texto vazio")
        return
    end
    
    print("[Voice TTS] Enviando:", text)
    voiceInputBox.Text = ""
    
    -- Pausa All Chat TTS
    messageQueue = {}
    isProcessingQueue = false
    isPlayingNew = false
    
    task.spawn(function()
        pcall(function()
            request({
                Url = SERVER_URL .. "/stop",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({action = "stop"})
            })
        end)
        task.wait(0.3)
        handleTTS(text, "high")
    end)
end)

filaBtn.MouseButton1Click:Connect(function()
    if not queueMode then
        queueMode = true
        filaIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        newIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        print("[MODO] Fila ativado")
    end
end)

newBtn.MouseButton1Click:Connect(function()
    if queueMode then
        queueMode = false
        -- Limpa TODAS as filas imediatamente
        messageQueue = {}
        messageQueueNew = {}
        isProcessingQueue = false
        isPlayingNew = false
        filaIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        newIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        print("[MODO] New ativado - Fila cancelada e voz parada")
        
        -- Para qualquer áudio que esteja tocando
        task.spawn(function()
            pcall(function()
                request({
                    Url = SERVER_URL .. "/stop",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({action = "stop"})
                })
            end)
        end)
        
        -- Aguarda um pouco antes de iniciar modo New
        task.wait(0.3)
        
        -- Inicia modo New
        if allChatEnabled then
            processNewMode()
        end
    end
end)

allChatBtn.MouseButton1Click:Connect(function()
    allChatEnabled = not allChatEnabled
    allChatIndicator.BackgroundColor3 = allChatEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    if allChatEnabled then
        queueMode = true
        filaIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        newIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        print("[All Chat] Ativado - Iniciando fila nova")
    else
        -- Limpa filas imediatamente
        messageQueue = {}
        messageQueueNew = {}
        isProcessingQueue = false
        isPlayingNew = false
        filaIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        newIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        print("[All Chat] Desativado - Parando voz IMEDIATAMENTE")
        
        -- Para o áudio instantaneamente no servidor
        task.spawn(function()
            pcall(function()
                request({
                    Url = SERVER_URL .. "/stop",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({action = "stop"})
                })
            end)
        end)
    end
    
    print("[All Chat]", allChatEnabled and "Ativado" or "Desativado")
end)


musicBtn.MouseButton1Click:Connect(function()
    if musicToggling then
        print("[MUSIC] Aguarde...")
        return
    end
    
    musicToggling = true
    
    -- Muda visual imediatamente para feedback instantâneo
    musicEnabled = not musicEnabled
    musicIndicator.BackgroundColor3 = musicEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    -- Se desativar, para a música imediatamente e desativa Players /play
    if not musicEnabled then
        playerCanPlay = false
        playerPermissionIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        musicPlaying = false
        musicSearching = false
        musicPlayBtn.Text = "Tocar"
        musicPlayBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
        print("[MUSIC] Players /play desativado automaticamente")
        print("[MUSIC] Parando música imediatamente")
        stopMusic()
    end
    
    print("[MUSIC]", musicEnabled and "ATIVANDO..." or "DESATIVANDO...")
    
    -- Envia para servidor em background
    task.spawn(function()
        local success, response = pcall(function()
            return request({
                Url = SERVER_URL .. "/music/toggle",
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({})
            })
        end)
        
        if success and response then
            local data = HttpService:JSONDecode(response.Body)
            musicEnabled = data.enabled
            musicIndicator.BackgroundColor3 = musicEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
            print("[MUSIC]", musicEnabled and "ATIVADO!" or "DESATIVADO!")
        else
            warn("[MUSIC] Erro ao alternar estado")
            -- Reverte em caso de erro
            musicEnabled = not musicEnabled
            musicIndicator.BackgroundColor3 = musicEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        end
        
        task.wait(0.2)
        musicToggling = false
    end)
end)

playerPermissionBtn.MouseButton1Click:Connect(function()
    playerCanPlay = not playerCanPlay
    playerPermissionIndicator.BackgroundColor3 = playerCanPlay and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    print("[MUSIC] Players podem tocar:", playerCanPlay and "SIM" or "NÃO")
end)

musicPlayBtn.MouseButton1Click:Connect(function()
    if not musicEnabled then
        print("[MUSIC] Sistema desativado - Ative o botão 'Música YouTube' primeiro (deixe verde)")
        return
    end
    
    -- Se está buscando, cancela a busca
    if musicSearching then
        print("[MUSIC] Cancelando busca")
        musicSearching = false
        musicPlaying = false
        musicPlayBtn.Text = "Tocar"
        musicPlayBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
        stopMusic()
        return
    end
    
    if musicPlaying then
        -- Interromper
        musicPlaying = false
        musicPlayBtn.Text = "Tocar"
        musicPlayBtn.BackgroundColor3 = Color3.fromRGB(30, 215, 96)
        stopMusic()
        print("[MUSIC] Parado")
    else
        -- Tocar
        local query = musicInputBox.Text
        if query == "" or #query < 2 then
            print("[MUSIC] Nome muito curto")
            return
        end
        
        searchMusic(query, nil)
    end
end)

local function setupPlayerChat(plr)
    if plr == player then return end
    
    plr.Chatted:Connect(function(message)
        print("[DEBUG] Player", plr.DisplayName, "falou:", message)
        
        -- Detecta comando "/play" (case insensitive)
        local lowerMsg = string.lower(message)
        if musicEnabled and playerCanPlay and string.sub(lowerMsg, 1, 5) == "/play" then
            local songName = string.sub(message, 7)  -- Pega do caractere 7 em diante (após "/play ")
            if #songName > 0 then
                print("[MUSIC] Comando detectado de", plr.DisplayName, ":", songName)
                musicInputBox.Text = plr.DisplayName .. " tocou: " .. songName
                searchMusic(songName, plr.DisplayName)
                return
            end
        end
        
        if allChatEnabled then
            local textToSpeak = plr.DisplayName .. " falou " .. message
            print("[DEBUG] Falando:", textToSpeak)
            handleTTS(textToSpeak, "low")
        end
    end)
end

rejoinBtn.MouseButton1Click:Connect(function()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, player)
end)

for _, plr in pairs(game.Players:GetPlayers()) do
    setupPlayerChat(plr)
end

game.Players.PlayerAdded:Connect(setupPlayerChat)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.Q and clickTpEnabled then
        pcall(function()
            if not player.Character then return end
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local mouse = player:GetMouse()
            if mouse.Target then
                root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    end
end)

print("[VoiceTTS] Carregado! Z=Menu | Server:", SERVER_URL)

