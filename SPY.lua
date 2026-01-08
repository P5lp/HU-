local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

-- متغيرات الحالة
local selectedLocation = nil
local selectedPlayer = nil
local isOnCooldownLocations = false
local isOnCooldownPlayers = false
local cooldownTime = 9

-- إحداثيات Min (مسطح مع 90° كما طلبت أخيرًا)
local MinArmoryPos = CFrame.new(196, 23.23, -215)
local MinSecretDropPos = CFrame.new(-3.63, 30.07, -57.13)
local MinDropCFrame = MinSecretDropPos * CFrame.Angles(math.rad(90), 0, 0)
local MinCamArmoryPos = CFrame.new(197.10, 24.68, -215.00)
local MinCamDropPos = CFrame.new(-4.40027905, 28.6965332, -52.30336, 0.999962628, 0.00840886775, -0.00199508853, 0, 0.230851427, 0.972989082, 0.00864230469, -0.972952724, 0.230842814)

-- إحداثيات Max
local MaxArmoryPos = CFrame.new(196, 23.23, -215)
local MaxSecretDropPos = CFrame.new(86.40, 3.72, -123.01)
local MaxDropCFrame = MaxSecretDropPos * CFrame.Angles(math.rad(90), 0, 0)
local MaxCamArmoryPos = CFrame.new(197.10, 24.68, -215.00)
local MaxCamDropPos = CFrame.new(87.8526535, -0.884054422, -138.253372, -0.999785066, -0.0151582891, 0.0141448993, 0, 0.682245076, 0.731123507, -0.0207328703, 0.730966389, -0.682098448)

-- إحداثيات Booking
local BookingDropCFrame = CFrame.new(190.80, 19.13, -155.41) * CFrame.Angles(-1.763, -0.006, -3.108)
local BookingCamDropPos = CFrame.new(196.15538, 16.8420944, -161.746475, -0.88024509, -0.283127189, 0.380798608, 0, 0.802493393, 0.596661031, -0.474519312, 0.525207937, -0.706390858)

-- إحداثيات عامة
local ArmoryTeleport = CFrame.new(189.40, 23.10, -214.47)
local FinalFarmPos = CFrame.new(20.06, 11.23, -117.39)

-- دالة لجعل اللون أكثر وضوحًا
local function brightenColor(c)
    return Color3.new(
        math.min(1, c.R * 1.3 + 0.1),
        math.min(1, c.G * 1.3 + 0.1),
        math.min(1, c.B * 1.3 + 0.1)
    )
end

-- ===================================
-- سكربت فتح الأبواب / Vents / الجدران (يشتغل فقط أثناء الدروب)
-- ===================================
getgenv().AllCellPartsOpen = false

local CellDoorParts = {}
local VentParts = {}
local MapBarrierParts = {}

local function updateRoot()
    if player.Character then
        return player.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local root = updateRoot()

player.CharacterAdded:Connect(function(char)
    root = char:WaitForChild("HumanoidRootPart")
end)

local function refreshVents()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("vent") then
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    VentParts[part] = true
                end
            end
        end
    end
end

local function scanDoors()
    local doorsFolder = workspace.Map.Functional:FindFirstChild("Doors")
    if not doorsFolder then return end

    for _, cell in pairs(doorsFolder:GetChildren()) do
        local doorMain = cell:FindFirstChild("DoorMain") or cell
        if doorMain then
            for _, part in pairs(doorMain:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    CellDoorParts[part] = true
                end
            end
        end
    end
end

local function scanMapWallsAndBarriers()
    for _, part in pairs(workspace.Map:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and not MapBarrierParts[part] then
            if part.Name == "Baseplate" or 
               part.Name == "Grass" or 
               part.Name:lower():find("floor") or 
               part.Name:lower():find("ground") or 
               part.Name:lower():find("terrain") or
               part.Name:lower():find("base") then
                continue 
            end

            part.CanCollide = false
            MapBarrierParts[part] = true
        end
    end
end

spawn(function()
    while task.wait(1.5) do
        if getgenv().AllCellPartsOpen then
            scanDoors()
            refreshVents()
            scanMapWallsAndBarriers()
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not getgenv().AllCellPartsOpen then return end
    
    root = updateRoot()
    if not root then return end

    local function openIfNear(tbl)
        for part, _ in pairs(tbl) do
            if part and part.Parent then
                local dist = (root.Position - part.Position).Magnitude
                if dist <= 18 then
                    part.CanCollide = false
                else
                    part.CanCollide = true
                end
            end
        end
    end

    openIfNear(CellDoorParts)
    openIfNear(VentParts)
end)

-- ===================================
-- إنشاء الواجهة الرسومية
-- ===================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GunSpawnerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 580)
mainFrame.Position = UDim2.new(0, 20, 0.5, -290)
mainFrame.BackgroundColor3 = Color3.new(1, 1, 1)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 50, 82)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 22, 44)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 19))
})
gradient.Rotation = 0
gradient.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 3
mainStroke.Color = Color3.fromRGB(0, 0, 0)
mainStroke.Parent = mainFrame

-- التبويبات
local tabNames = {"Locations", "Players", "Teleport", "Player"}
local tabButtons = {}
local tabContents = {}

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(0.9, 0, 0, 50)
tabsFrame.Position = UDim2.new(0.05, 0, 0, 20)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = mainFrame

local tabPadding = 5
local totalWidth = 360 * 0.9
local buttonWidth = (totalWidth - (#tabNames - 1) * tabPadding) / #tabNames

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 1, 0)
    btn.Position = UDim2.new(0, (i-1) * (buttonWidth + tabPadding), 0, 0)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(62, 39, 78) or Color3.fromRGB(102, 65, 129)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = tabsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    tabButtons[name] = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(0.9, 0, 0, 500)
    content.Position = UDim2.new(0.05, 0, 0, 80)
    content.BackgroundTransparency = 1
    content.Visible = (i == 1)
    content.Parent = mainFrame
    tabContents[name] = content
end

for _, name in ipairs(tabNames) do
    tabButtons[name].MouseButton1Click:Connect(function()
        for k, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
            tabContents[k].Visible = false
        end
        tabButtons[name].BackgroundColor3 = Color3.fromRGB(62, 39, 78)
        local newContent = tabContents[name]
        newContent.Position = UDim2.new(0.05, 0, 0, 80)
        newContent.Visible = true
    end)
end

-- ==================== Locations Tab ====================
local locContent = tabContents["Locations"]

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0.9, 0, 0, 70)
minBtn.Position = UDim2.new(0.05, 0, 0, 20)
minBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
minBtn.Text = "Min Lobby"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextSize = 30
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = locContent
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 14)

local maxBtn = Instance.new("TextButton")
maxBtn.Size = UDim2.new(0.9, 0, 0, 70)
maxBtn.Position = UDim2.new(0.05, 0, 0, 110)
maxBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
maxBtn.Text = "Max"
maxBtn.TextColor3 = Color3.new(1,1,1)
maxBtn.TextSize = 30
maxBtn.Font = Enum.Font.GothamBold
maxBtn.Parent = locContent
Instance.new("UICorner", maxBtn).CornerRadius = UDim.new(0, 14)

local bookingBtn = Instance.new("TextButton")
bookingBtn.Size = UDim2.new(0.9, 0, 0, 70)
bookingBtn.Position = UDim2.new(0.05, 0, 0, 200)
bookingBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
bookingBtn.Text = "Booking"
bookingBtn.TextColor3 = Color3.new(1,1,1)
bookingBtn.TextSize = 30
bookingBtn.Font = Enum.Font.GothamBold
bookingBtn.Parent = locContent
Instance.new("UICorner", bookingBtn).CornerRadius = UDim.new(0, 14)

minBtn.MouseButton1Click:Connect(function()
    minBtn.BackgroundColor3 = Color3.fromRGB(62, 39, 78)
    maxBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
    bookingBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
    selectedLocation = "Min"
end)

maxBtn.MouseButton1Click:Connect(function()
    maxBtn.BackgroundColor3 = Color3.fromRGB(62, 39, 78)
    minBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
    bookingBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
    selectedLocation = "Max"
end)

bookingBtn.MouseButton1Click:Connect(function()
    bookingBtn.BackgroundColor3 = Color3.fromRGB(62, 39, 78)
    minBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
    maxBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
    selectedLocation = "Booking"
end)

local locSpawnBtn = Instance.new("TextButton")
locSpawnBtn.Size = UDim2.new(0.9, 0, 0, 60)
locSpawnBtn.Position = UDim2.new(0.05, 0, 0, 290)
locSpawnBtn.BackgroundColor3 = Color3.fromRGB(52, 50, 82)
locSpawnBtn.Text = "Spawn"
locSpawnBtn.TextColor3 = Color3.new(1,1,1)
locSpawnBtn.TextSize = 30
locSpawnBtn.Font = Enum.Font.GothamBold
locSpawnBtn.Parent = locContent
Instance.new("UICorner", locSpawnBtn).CornerRadius = UDim.new(0, 14)

local locLoadingDot = Instance.new("Frame")
locLoadingDot.Size = UDim2.new(0, 20, 0, 20)
locLoadingDot.Position = UDim2.new(1, -30, 0.5, -10)
locLoadingDot.BackgroundColor3 = Color3.fromHex("#22B365")
locLoadingDot.Visible = false
locLoadingDot.Parent = locSpawnBtn
Instance.new("UICorner", locLoadingDot).CornerRadius = UDim.new(1, 0)

-- ==================== Players Tab ====================
local playersContent = tabContents["Players"]

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,0.65,0)
scroll.Position = UDim2.new(0,0,0,0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.Parent = playersContent

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,8)
list.Parent = scroll

local viewBtn = Instance.new("TextButton")
viewBtn.Size = UDim2.new(0.9, 0, 0, 55)
viewBtn.Position = UDim2.new(0.05, 0, 0.68, 0)
viewBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
viewBtn.Text = "View Player"
viewBtn.TextColor3 = Color3.new(1,1,1)
viewBtn.TextSize = 26
viewBtn.Font = Enum.Font.GothamBold
viewBtn.Parent = playersContent
Instance.new("UICorner", viewBtn).CornerRadius = UDim.new(0, 14)

local playersSpawnBtn = Instance.new("TextButton")
playersSpawnBtn.Size = UDim2.new(0.9, 0, 0, 60)
playersSpawnBtn.Position = UDim2.new(0.05, 0, 0.80, 0)
playersSpawnBtn.BackgroundColor3 = Color3.fromRGB(52, 50, 82)
playersSpawnBtn.Text = "Spawn"
playersSpawnBtn.TextColor3 = Color3.new(1,1,1)
playersSpawnBtn.TextSize = 30
playersSpawnBtn.Font = Enum.Font.GothamBold
playersSpawnBtn.Parent = playersContent
Instance.new("UICorner", playersSpawnBtn).CornerRadius = UDim.new(0, 14)

local playersLoadingDot = Instance.new("Frame")
playersLoadingDot.Size = UDim2.new(0, 20, 0, 20)
playersLoadingDot.Position = UDim2.new(1, -30, 0.5, -10)
playersLoadingDot.BackgroundColor3 = Color3.fromHex("#22B365")
playersLoadingDot.Visible = false
playersLoadingDot.Parent = playersSpawnBtn
Instance.new("UICorner", playersLoadingDot).CornerRadius = UDim.new(1, 0)

-- متغيرات الـ View/Spectate
local isViewing = false
local viewConnection
local oldCamType, oldCamSubject
local lastTargetPos = nil

local function toggleView()
    if not selectedPlayer then
        game.StarterGui:SetCore("SendNotification",{Title="خطأ",Text="اختر لاعب أولاً!",Duration=3})
        return
    end

    if isViewing then
        isViewing = false
        viewBtn.Text = "View Player"
        viewBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
        if viewConnection then viewConnection:Disconnect() end
        camera.CameraType = oldCamType
        camera.CameraSubject = oldCamSubject
        lastTargetPos = nil
        game.StarterGui:SetCore("SendNotification",{Title="View",Text="تم إيقاف المشاهدة",Duration=2})
    else
        oldCamType = camera.CameraType
        oldCamSubject = camera.CameraSubject
        
        isViewing = true
        viewBtn.Text = "Stop View"
        viewBtn.BackgroundColor3 = Color3.fromRGB(62, 39, 78)
        camera.CameraType = Enum.CameraType.Scriptable
        
        local function updateView()
            local targetChar = selectedPlayer.Character
            if targetChar then
                local targetHead = targetChar:FindFirstChild("Head")
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                local pos = (targetHead and targetHead.Position) or (targetHRP and targetHRP.Position) or lastTargetPos
                if pos then
                    lastTargetPos = pos
                    camera.CFrame = CFrame.lookAt(pos + Vector3.new(0, 2, 8), pos)
                end
            end
        end
        
        viewConnection = RunService.RenderStepped:Connect(updateView)
        
        local charAddedConn
        charAddedConn = selectedPlayer.CharacterAdded:Connect(function()
            if isViewing then
                task.wait(1)
                updateView()
            end
        end)
        
        game.StarterGui:SetCore("SendNotification",{Title="View",Text="تتبع اللاعب: "..selectedPlayer.Name.." (حتى بعد الموت، يمكنك التدوير بالماوس)",Duration=3})
    end
end

viewBtn.MouseButton1Click:Connect(toggleView)

local function getPlayerTeamInfo(p)
    if p.Team and p.Team.Name then
        local teamName = p.Team.Name
        if teamName == "Maximum Security" then
            return "Max", brightenColor(p.Team.TeamColor.Color)
        elseif teamName == "Minimum Security" then
            return "Min", brightenColor(p.Team.TeamColor.Color)
        end
    end
    return nil, nil
end

local function refreshPlayers()
    for _,v in scroll:GetChildren() do if v:IsA("TextButton") then v:Destroy() end end
    
    local maxPlayers = {}
    local minPlayers = {}
    
    for _, p in Players:GetPlayers() do
        if p ~= player then
            local teamType, textColor = getPlayerTeamInfo(p)
            if teamType == "Max" then
                table.insert(maxPlayers, {player = p, color = textColor})
            elseif teamType == "Min" then
                table.insert(minPlayers, {player = p, color = textColor})
            end
        end
    end
    
    for _, info in ipairs(maxPlayers) do
        local p = info.player
        local textColor = info.color
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95,0,0,50)
        btn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
        btn.Text = p.Name .. " (Max)"
        btn.TextColor3 = textColor
        btn.TextSize = 24
        btn.Font = Enum.Font.Gotham
        btn.AutoButtonColor = false
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        
        btn.MouseButton1Click:Connect(function()
            selectedPlayer = p
            for _,b in scroll:GetChildren() do 
                if b:IsA("TextButton") then 
                    b.BackgroundColor3 = Color3.fromRGB(102, 65, 129) 
                end 
            end
            btn.BackgroundColor3 = Color3.fromRGB(62, 39, 78)
            game.StarterGui:SetCore("SendNotification",{Title="Target Selected",Text="Drop at: "..p.Name.." (Max)",Duration=3})
        end)
    end
    
    for _, info in ipairs(minPlayers) do
        local p = info.player
        local textColor = info.color
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95,0,0,50)
        btn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
        btn.Text = p.Name .. " (Min)"
        btn.TextColor3 = textColor
        btn.TextSize = 24
        btn.Font = Enum.Font.Gotham
        btn.AutoButtonColor = false
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        
        btn.MouseButton1Click:Connect(function()
            selectedPlayer = p
            for _,b in scroll:GetChildren() do 
                if b:IsA("TextButton") then 
                    b.BackgroundColor3 = Color3.fromRGB(102, 65, 129) 
                end 
            end
            btn.BackgroundColor3 = Color3.fromRGB(62, 39, 78)
            game.StarterGui:SetCore("SendNotification",{Title="Target Selected",Text="Drop at: "..p.Name.." (Min)",Duration=3})
        end)
    end
    
    local totalPlayers = #maxPlayers + #minPlayers
    scroll.CanvasSize = UDim2.new(0,0,0,totalPlayers * 58)
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

-- ==================== Teleport Tab ====================
local tpContent = tabContents["Teleport"]

local teleportButtons = {
    {name = "Gun", action = "gun"},
    {name = "Keycard", action = "keycard"},
    {name = "Maintenance", pos = CFrame.new(172.34, 23.10, -143.87)},
    {name = "Security", pos = CFrame.new(224.47, 23.10, -167.90)},
    {name = "OC Lockers", pos = CFrame.new(137.60, 23.10, -169.93)},
    {name = "RIOT Lockers", pos = CFrame.new(165.63, 23.10, -192.25)},
    {name = "Ventilation", pos = CFrame.new(76.96, -7.02, -19.21)},
    {name = "Maximum", pos = CFrame.new(99.85, -8.87, -156.13)},
    {name = "Generator", pos = CFrame.new(100.95, -8.82, -57.59)},
    {name = "Outside", pos = CFrame.new(350.22, 5.40, -171.09)},
    {name = "Escape Base", pos = CFrame.new(749.02, -0.97, -470.45)},
    {name = "Escape", pos = CFrame.new(307.06, 5.40, -177.88)},
    {name = "Keycard (💳)", pos = CFrame.new(-13.36, 22.13, -27.47)},
    {name = "GAS STATION", pos = CFrame.new(274.30, 6.21, -612.77)},
    {name = "armory", pos = CFrame.new(189.40, 23.10, -214.47)},
    {name = "BARN", pos = CFrame.new(43.68, 10.37, 395.04)},
    {name = "R&D", pos = CFrame.new(-182.35, -85.90, 158.07)}
}

local tpScroll = Instance.new("ScrollingFrame")
tpScroll.Size = UDim2.new(1,0,1,0)
tpScroll.Position = UDim2.new(0,0,0,0)
tpScroll.BackgroundTransparency = 1
tpScroll.ScrollBarThickness = 6
tpScroll.Parent = tpContent

local tpList = Instance.new("UIListLayout")
tpList.Padding = UDim2.new(0,8)
tpList.Parent = tpScroll

for i, tp in ipairs(teleportButtons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95,0,0,50)
    btn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
    btn.Text = tp.name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 24
    btn.Font = Enum.Font.Gotham
    btn.AutoButtonColor = false
    btn.Parent = tpScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    if tp.action == "gun" then
        btn.MouseButton1Click:Connect(function()
            game.StarterGui:SetCore("SendNotification",{Title="Gun Activated",Text="WIP",Duration=3})
        end)
    elseif tp.action == "keycard" then
        btn.MouseButton1Click:Connect(function()
            game.StarterGui:SetCore("SendNotification",{Title="Keycard Activated",Text="WIP",Duration=3})
        end)
    elseif tp.pos then
        btn.MouseButton1Click:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = tp.pos
                game.StarterGui:SetCore("SendNotification",{Title="Teleported",Text="To " .. tp.name,Duration=3})
            end
        end)
    end
end
tpScroll.CanvasSize = UDim2.new(0,0,0,#teleportButtons*58)

-- ==================== Player Tab ====================
local playerContent = tabContents["Player"]

getgenv().Psalms = getgenv().Psalms or {
    Tech = {
        speedvalue = 3,
        cframespeedtoggle = false
    }
}

local function UpdateSpeedValue(newValue)
    local numValue = tonumber(newValue)
    if numValue and numValue >= 0 and numValue <= 10 then
        getgenv().Psalms.Tech.speedvalue = numValue
        if getgenv().flyEnabled then
            EnableFly(false)
            EnableFly(true)
        end
        if getgenv().Psalms.Tech.cframespeedtoggle then
            EnableCFrameSpeed(false)
            EnableCFrameSpeed(true)
        end
    end
end

local function EnableCFrameSpeed(state)
    getgenv().Psalms.Tech.cframespeedtoggle = state
    local speeds = getgenv().Psalms.Tech.speedvalue
    local tpwalking = false
    local speaker = game:GetService("Players").LocalPlayer

    if state then
        tpwalking = true
        for i = 1, speeds do
            spawn(function()
                local RunService = game:GetService("RunService")
                local hb = RunService.Heartbeat
                local chr = speaker.Character
                local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                    if hum.MoveDirection.Magnitude > 0 then
                        chr:TranslateBy(hum.MoveDirection)
                    end
                end
            end)
        end
    else
        tpwalking = false
    end
end

local HideEnabled, LastCFrame
local function EnableInvisible(state)
    HideEnabled = state
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    if not state then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LastCFrame
        end
        LastCFrame = nil
        return
    end

    local heartbeatConn
    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not HideEnabled then heartbeatConn:Disconnect() return end
        if LocalPlayer.Character then
            local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
            if HumanoidRootPart then
                local Offset = HumanoidRootPart.CFrame * CFrame.new(9e9, 0, 9e9)
                LastCFrame = HumanoidRootPart.CFrame
                HumanoidRootPart.CFrame = Offset
                RunService.RenderStepped:Wait()
                HumanoidRootPart.CFrame = LastCFrame
            end
        end
    end)

    local HookMethod
    HookMethod = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if not checkcaller() and key == "CFrame" and HideEnabled and 
           LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
           LocalPlayer.Character:FindFirstChild("Humanoid") and 
           LocalPlayer.Character.Humanoid.Health > 0 then
            if self == LocalPlayer.Character.HumanoidRootPart and LastCFrame then
                return LastCFrame
            end
        end
        return HookMethod(self, key)
    end))
end

local function EnableFly(state)
    getgenv().flyEnabled = state
    local speeds = getgenv().Psalms.Tech.speedvalue
    local speaker = game:GetService("Players").LocalPlayer
    local chr = speaker.Character
    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
    local nowe = false
    local tpwalking = false
    local rsConn = nil
    local flyLoopConn = nil

    if state then
        nowe = true
        for i = 1, speeds do
            spawn(function()
                local RunService = game:GetService("RunService")
                local hb = RunService.Heartbeat
                local chr = speaker.Character
                local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                tpwalking = true
                while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                    if hum.MoveDirection.Magnitude > 0 then
                        chr:TranslateBy(hum.MoveDirection)
                    end
                end
            end)
        end
        speaker.Character.Animate.Disabled = true
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for i, v in next, Hum:GetPlayingAnimationTracks() do
            v:AdjustSpeed(0)
        end
        local humanoid = speaker.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end

        if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
            local plr = game.Players.LocalPlayer
            local torso = plr.Character.Torso
            local ctrl, lastctrl = {f = 0, b = 0, l = 0, r = 0}, {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 50
            local speed = 0
            local bg = Instance.new("BodyGyro", torso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = torso.CFrame
            local bv = Instance.new("BodyVelocity", torso)
            bv.velocity = Vector3.new(0, 0.1, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            plr.Character.Humanoid.PlatformStand = true
            rsConn = game:GetService("RunService").RenderStepped:Connect(function()
                if not nowe then rsConn:Disconnect() return end
                if plr.Character.Humanoid.Health == 0 then return end
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed + 0.5 + (speed / maxspeed)
                    if speed > maxspeed then speed = maxspeed end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed - 1
                    if speed < 0 then speed = 0 end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speed
                else
                    bv.velocity = Vector3.new(0, 0, 0)
                end
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
            end)
        else
            local plr = game.Players.LocalPlayer
            local UpperTorso = plr.Character.UpperTorso
            local ctrl, lastctrl = {f = 0, b = 0, l = 0, r = 0}, {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 50
            local speed = 0
            local bg = Instance.new("BodyGyro", UpperTorso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = UpperTorso.CFrame
            local bv = Instance.new("BodyVelocity", UpperTorso)
            bv.velocity = Vector3.new(0, 0.1, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            plr.Character.Humanoid.PlatformStand = true
            flyLoopConn = spawn(function()
                while nowe or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
                    wait()
                    if not nowe then break end
                    if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                        speed = speed + 0.5 + (speed / maxspeed)
                        if speed > maxspeed then speed = maxspeed end
                    elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                        speed = speed - 1
                        if speed < 0 then speed = 0 end
                    end
                    if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                        bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speed
                        lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                    elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                        bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speed
                    else
                        bv.velocity = Vector3.new(0, 0, 0)
                    end
                    bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
                end
                ctrl = {f = 0, b = 0, l = 0, r = 0}
                lastctrl = {f = 0, b = 0, l = 0, r = 0}
                speed = 0
                if bg then bg:Destroy() end
                if bv then bv:Destroy() end
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.Humanoid.PlatformStand = false
                end
                game.Players.LocalPlayer.Character.Animate.Disabled = false
                tpwalking = false
            end)
        end
    else
        nowe = false
        tpwalking = false
        if rsConn then rsConn:Disconnect() rsConn = nil end
        if flyLoopConn then coroutine.close(flyLoopConn) flyLoopConn = nil end
        local humanoid = speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            humanoid.PlatformStand = false
        end
        if speaker.Character and speaker.Character:FindFirstChild("UpperTorso") then
            local UpperTorso = speaker.Character.UpperTorso
            local bg = UpperTorso:FindFirstChild("BodyGyro")
            local bv = UpperTorso:FindFirstChild("BodyVelocity")
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
        if speaker.Character and speaker.Character:FindFirstChild("Torso") then
            local torso = speaker.Character.Torso
            local bg = torso:FindFirstChild("BodyGyro")
            local bv = torso:FindFirstChild("BodyVelocity")
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
        speaker.Character.Animate.Disabled = false
    end
end

local speedEnabled, invisibleEnabled, flyEnabled = false, false, false
getgenv().flyEnabled = false

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.8, 0, 0, 60)
speedBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
speedBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
speedBtn.Text = "Speed: OFF"
speedBtn.TextColor3 = Color3.new(1,1,1)
speedBtn.TextSize = 30
speedBtn.Font = Enum.Font.GothamBold
speedBtn.Parent = playerContent
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 14)

speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    EnableCFrameSpeed(speedEnabled)
    speedBtn.Text = "Speed: " .. (speedEnabled and "ON" or "OFF")
    speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(62, 39, 78) or Color3.fromRGB(102, 65, 129)
end)

local invisibleBtn = Instance.new("TextButton")
invisibleBtn.Size = UDim2.new(0.8, 0, 0, 60)
invisibleBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
invisibleBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
invisibleBtn.Text = "Invisible: OFF"
invisibleBtn.TextColor3 = Color3.new(1,1,1)
invisibleBtn.TextSize = 30
invisibleBtn.Font = Enum.Font.GothamBold
invisibleBtn.Parent = playerContent
Instance.new("UICorner", invisibleBtn).CornerRadius = UDim.new(0, 14)

invisibleBtn.MouseButton1Click:Connect(function()
    invisibleEnabled = not invisibleEnabled
    EnableInvisible(invisibleEnabled)
    invisibleBtn.Text = "Invisible: " .. (invisibleEnabled and "ON" or "OFF")
    invisibleBtn.BackgroundColor3 = invisibleEnabled and Color3.fromRGB(62, 39, 78) or Color3.fromRGB(102, 65, 129)
end)

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.8, 0, 0, 60)
flyBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(102, 65, 129)
flyBtn.Text = "Fly: OFF"
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.TextSize = 30
flyBtn.Font = Enum.Font.GothamBold
flyBtn.Parent = playerContent
Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 14)

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    EnableFly(flyEnabled)
    flyBtn.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(62, 39, 78) or Color3.fromRGB(102, 65, 129)
end)

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.8, 0, 0, 50)
speedInput.Position = UDim2.new(0.1, 0, 0.7, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(52, 50, 82)
speedInput.Text = tostring(getgenv().Psalms.Tech.speedvalue)
speedInput.TextColor3 = Color3.new(1,1,1)
speedInput.TextSize = 28
speedInput.Font = Enum.Font.GothamBold
speedInput.PlaceholderText = "Speed (0-10)"
speedInput.Parent = playerContent
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 14)

speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        UpdateSpeedValue(speedInput.Text)
        speedInput.Text = tostring(getgenv().Psalms.Tech.speedvalue)
    end
end)

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.7)
    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
        game.Players.LocalPlayer.Character.Animate.Disabled = false
    end
end)

-- ===================================
-- دالة مشتركة للدروب (Min / Max / Booking)
-- ===================================
local function RunDrop(dropCFrame, camDropPos, armoryPos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local oldCamType = camera.CameraType
    local oldCamSubject = camera.CameraSubject
    local oldFOV = camera.FieldOfView
    local camConnection

    -- تفعيل فتح الأبواب + Invisible عند البداية
    getgenv().AllCellPartsOpen = true
    EnableInvisible(true)

    local function FixCamera()
        if camConnection then camConnection:Disconnect() end
        camera.CameraType = Enum.CameraType.Scriptable
        camera.FieldOfView = 120
        camConnection = RunService.RenderStepped:Connect(function()
            camera.CFrame = camDropPos
        end)
    end

    -- إيقاف كل شيء عند الريسبون الكامل
    local restoreConn = player.CharacterAdded:Once(function()
        if camConnection then camConnection:Disconnect() end
        camera.CameraType = oldCamType
        camera.CameraSubject = oldCamSubject
        camera.FieldOfView = oldFOV
        getgenv().AllCellPartsOpen = false
        EnableInvisible(false)
    end)

    FixCamera()
    hrp.CFrame = armoryPos
    task.wait(0.4)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            task.spawn(function()
                fireproximityprompt(v)
            end)
        end
    end
    task.wait(1.1)
    hrp.CFrame = dropCFrame

    local posFix = RunService.Heartbeat:Connect(function()
        hrp.CFrame = dropCFrame
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
    end)

    task.wait(0.4)
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = char
            task.wait(0.25)
            for _, obj in ipairs(tool:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "drop") or string.find(string.lower(obj.Name), "send") or string.find(string.lower(obj.Name), "key")) then
                    obj:FireServer()
                    break
                end
            end
            task.wait(0.35)
        end
    end

    if posFix then posFix:Disconnect() end

    hrp.CFrame = FinalFarmPos
    task.wait(0.5)
    hum:ChangeState(Enum.HumanoidStateType.Dead)
    game.StarterGui:SetCore("SendNotification", {
        Title = "سرقة + نقل جديد + ريسبون ✅";
        Text = "الأسلحة دروب وانتقلت لـ X:20.06 Y:11.23 Z:-117.39 قبل الريسبون 🔥";
        Duration = 8;
    })
end

local function RunMin() RunDrop(MinDropCFrame, MinCamDropPos, MinArmoryPos) end
local function RunMax() RunDrop(MaxDropCFrame, MaxCamDropPos, MaxArmoryPos) end
local function RunBooking() RunDrop(BookingDropCFrame, BookingCamDropPos, MaxArmoryPos) end

-- تنفيذ الـ Spawn
local function executeSelected(tabType)
    if tabType == "Locations" then
        if selectedLocation == "Min" then
            RunMin()
        elseif selectedLocation == "Max" then
            RunMax()
        elseif selectedLocation == "Booking" then
            RunBooking()
        end
    elseif tabType == "Players" then
        if selectedPlayer then
            local targetPos = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and selectedPlayer.Character.HumanoidRootPart.Position or FinalFarmPos.Position
            RunMin(targetPos)
        end
    end
end

local function startLoadingAnimation(dot)
    dot.Visible = true
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(dot, tweenInfo, {Transparency = 1})
    tween:Play()
    return tween
end

local function startCooldown(tabType)
    local dot, btn
    if tabType == "Locations" then
        isOnCooldownLocations = true
        dot = locLoadingDot
        btn = locSpawnBtn
    elseif tabType == "Players" then
        isOnCooldownPlayers = true
        dot = playersLoadingDot
        btn = playersSpawnBtn
    end
    local tween = startLoadingAnimation(dot)
    task.wait(cooldownTime)
    tween:Cancel()
    dot.Transparency = 0
    dot.Visible = false
    if tabType == "Locations" then
        isOnCooldownLocations = false
    elseif tabType == "Players" then
        isOnCooldownPlayers = false
    end
end

locSpawnBtn.MouseButton1Click:Connect(function()
    if not isOnCooldownLocations and selectedLocation then
        task.spawn(executeSelected, "Locations")
        task.spawn(startCooldown, "Locations")
    end
end)

playersSpawnBtn.MouseButton1Click:Connect(function()
    if not isOnCooldownPlayers and selectedPlayer then
        task.spawn(executeSelected, "Players")
        task.spawn(startCooldown, "Players")
    end
end)
