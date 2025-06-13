-- تحميل Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- متغيرات عامة
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = game.Workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

-- متغيرات لتتبع حالة الأوامر
local states = {
    fly = {enabled = false, connection = nil, bodyVelocity = nil},
    noclip = {enabled = false, connection = nil},
    god = {enabled = false},
    speed = {enabled = false, originalSpeed = 16},
    jump = {enabled = false, originalJump = 50},
    invisible = {enabled = false, clone = nil},
    freeze = {enabled = false},
    spectate = {enabled = false, connection = nil},
    xray = {enabled = false},
    esp = {enabled = false, highlights = {}}
}

-- متغير اللغة
local language = nil
local translations = {
    Arabic = {
        windowTitle = "🛠️ سكربت أوامر Infinite Yield",
        loadingTitle = "جاري التحميل...",
        loadingSubtitle = "By أنت 😎",
        fly = "✈️ طيران",
        noclip = "🚫 نوقليب",
        speed = "🏃‍♂️ سرعة",
        jump = "🦘 قفز عالي",
        god = "💀 جود مود",
        invisible = "👻 اختفاء",
        freeze = "🧊 تجميد",
        refresh = "♻️ تحديث الشخصية",
        selectPlayer = "👤 اختر لاعب",
        killPlayer = "🔫 قتل اللاعب المختار",
        gotoPlayer = "🚀 الانتقال إلى اللاعب",
        spectatePlayer = "👀 مراقبة اللاعب",
        flingPlayer = "🚀 رمي اللاعب",
        tooldrop = "🛠️ إسقاط الأدوات",
        nuke = "💥 نوك",
        rejoin = "🔄 إعادة الانضمام",
        xray = "🔍 إكس راي",
        esp = "🌟 إي إس بي",
        customCommand = "🔤 أمر مخصص",
        customPlaceholder = "مثال: speed 200 أو goto PlayerName",
        resetAll = "🔄 إعادة تعيين جميع الأوامر",
        closeUI = "🗑️ إغلاق الواجهة",
        speedInput = "أدخل السرعة (مثال: 100)",
        playerInput = "أدخل اسم اللاعب",
        notifyOn = "تفعيل",
        notifyOff = "إيقاف",
        error = "❌ خطأ",
        selectPlayerError = "يرجى اختيار لاعب أولاً",
        playerNotFound = "لم يتم العثور على اللاعب أو شخصيته",
        chooseLanguage = "اختر اللغة",
        arabic = "العربية",
        english = "الإنجليزية",
        confirm = "تأكيد",
        movementTab = "🏃 الحركة",
        powersTab = "🧪 القدرات",
        playersTab = "👥 اللاعبين",
        customTab = "🛠️ أمر مخصص",
        settingsTab = "⚙️ إعدادات عامة"
    },
    English = { -- ترجمة حرفية بنمط عربي-إنجليزي
        windowTitle = "🛠️ Script Commands Infinite Yield",
        loadingTitle = "Now Loading...",
        loadingSubtitle = "By You 😎",
        fly = "✈️ Activate Fly",
        noclip = "🚫 Activate Noclip",
        speed = "🏃‍♂️ Activate Speed",
        jump = "🦘 Activate High Jump",
        god = "💀 Activate God Mode",
        invisible = "👻 Activate Disappear",
        freeze = "🧊 Activate Freeze",
        refresh = "♻️ Refresh My Character",
        selectPlayer = "👤 Choose Player",
        killPlayer = "🔫 Kill Chosen Player",
        gotoPlayer = "🚀 Go To Player",
        spectatePlayer = "👀 Watch Player",
        flingPlayer = "🚀 Throw Player",
        tooldrop = "🛠️ Drop My Tools",
        nuke = "💥 Activate Nuke",
        rejoin = "🔄 Rejoin Server",
        xray = "🔍 Activate X-Ray",
        esp = "🌟 Activate ESP",
        customCommand = "🔤 Write Custom Command",
        customPlaceholder = "Example: speed 200 or goto PlayerName",
        resetAll = "🔄 Reset All Commands",
        closeUI = "🗑️ Close The Interface",
        speedInput = "Write Speed (Example: 100)",
        playerInput = "Write Player Name",
        notifyOn = "Activated",
        notifyOff = "Deactivated",
        error = "❌ Error Happened",
        selectPlayerError = "Please Choose Player First",
        playerNotFound = "Player Or His Character Not Found",
        chooseLanguage = "Choose The Language",
        arabic = "Arabic",
        english = "English",
        confirm = "Confirm",
        movementTab = "🏃 Movement Section",
        powersTab = "🧪 Powers Section",
        playersTab = "👥 Players Section",
        customTab = "🛠️ Custom Command Section",
        settingsTab = "⚙️ General Settings"
    }
}

-- واجهة اختيار اللغة
local function createLanguageUI()
    local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    ScreenGui.Name = "LanguageSelectionUI"
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 350, 0, 200)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Frame.BorderSizePixel = 0
    Frame.BackgroundTransparency = 0.1

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 10)

    local UIGradient = Instance.new("UIGradient", Frame)
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 80))
    })

    local Shadow = Instance.new("ImageLabel", Frame)
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ZIndex = -1

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Text = translations.Arabic.chooseLanguage
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.TextStrokeTransparency = 0.8

    local ArabicButton = Instance.new("TextButton", Frame)
    ArabicButton.Size = UDim2.new(0.4, 0, 0, 50)
    ArabicButton.Position = UDim2.new(0.05, 0, 0.35, 0)
    ArabicButton.Text = translations.Arabic.arabic
    ArabicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ArabicButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    ArabicButton.TextScaled = true
    ArabicButton.Font = Enum.Font.Gotham
    local ArabicCorner = Instance.new("UICorner", ArabicButton)
    ArabicCorner.CornerRadius = UDim.new(0, 8)

    local EnglishButton = Instance.new("TextButton", Frame)
    EnglishButton.Size = UDim2.new(0.4, 0, 0, 50)
    EnglishButton.Position = UDim2.new(0.55, 0, 0.35, 0)
    EnglishButton.Text = translations.Arabic.english
    EnglishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    EnglishButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    EnglishButton.TextScaled = true
    EnglishButton.Font = Enum.Font.Gotham
    local EnglishCorner = Instance.new("UICorner", EnglishButton)
    EnglishCorner.CornerRadius = UDim.new(0, 8)

    local ConfirmButton = Instance.new("TextButton", Frame)
    ConfirmButton.Size = UDim2.new(0.9, 0, 0, 50)
    ConfirmButton.Position = UDim2.new(0.05, 0, 0.65, 0)
    ConfirmButton.Text = translations.Arabic.confirm
    ConfirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    ConfirmButton.TextScaled = true
    ConfirmButton.Font = Enum.Font.GothamBold
    local ConfirmCorner = Instance.new("UICorner", ConfirmButton)
    ConfirmCorner.CornerRadius = UDim.new(0, 8)

    local selectedLanguage = nil
    ArabicButton.MouseButton1Click:Connect(function()
        selectedLanguage = "Arabic"
        ArabicButton.BackgroundColor3 = Color3.fromRGB(0, 150, 250)
        EnglishButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)

    EnglishButton.MouseButton1Click:Connect(function()
        selectedLanguage = "English"
        EnglishButton.BackgroundColor3 = Color3.fromRGB(0, 150, 250)
        ArabicButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)

    ConfirmButton.MouseButton1Click:Connect(function()
        if selectedLanguage then
            language = selectedLanguage
            ScreenGui:Destroy()
        end
    end)
end

-- إنشاء واجهة اختيار اللغة
createLanguageUI()

-- الانتظار حتى يتم اختيار اللغة
while not language do
    task.wait(0.1)
end

-- إنشاء واجهة Rayfield
local Window = Rayfield:CreateWindow({
    Name = translations[language].windowTitle,
    LoadingTitle = translations[language].loadingTitle,
    LoadingSubtitle = translations[language].loadingSubtitle,
    ConfigurationSaving = {
        Enabled = false
    }
})

-- دالة للحصول على الشخصية
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

-- دالة للعثور على لاعب بناءً على جزء من الاسم
local function findPlayer(partialName)
    partialName = partialName:lower()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Name:lower():match(partialName) then
            return p
        end
    end
    return nil
end

-- الدوال
local function fly(toggle)
    local char = getChar()
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    if toggle then
        states.fly.enabled = true
        states.fly.bodyVelocity = Instance.new("BodyVelocity", hrp)
        states.fly.bodyVelocity.Velocity = Vector3.zero
        states.fly.bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        states.fly.connection = RunService.Heartbeat:Connect(function()
            states.fly.bodyVelocity.Velocity = mouse.Hit.LookVector * 50
        end)
        Rayfield:Notify({
            Title = translations[language].fly .. " " .. translations[language].notifyOn,
            Content = translations[language].fly .. " " .. translations[language].notifyOn:lower(),
            Duration = 3
        })
    else
        states.fly.enabled = false
        if states.fly.connection then
            states.fly.connection:Disconnect()
            states.fly.connection = nil
        end
        if states.fly.bodyVelocity then
            states.fly.bodyVelocity:Destroy()
            states.fly.bodyVelocity = nil
        end
        Rayfield:Notify({
            Title = translations[language].fly .. " " .. translations[language].notifyOff,
            Content = translations[language].fly .. " " .. translations[language].notifyOff:lower(),
            Duration = 3
        })
    end
end

local function noclip(toggle)
    local char = getChar()
    if toggle then
        states.noclip.enabled = true
        states.noclip.connection = RunService.Stepped:Connect(function()
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
        Rayfield:Notify({
            Title = translations[language].noclip .. " " .. translations[language].notifyOn,
            Content = translations[language].noclip .. " " .. translations[language].notifyOn:lower(),
            Duration = 3
        })
    else
        states.noclip.enabled = false
        if states.noclip.connection then
            states.noclip.connection:Disconnect()
            states.noclip.connection = nil
        end
        Rayfield:Notify({
            Title = translations[language].noclip .. " " .. translations[language].notifyOff,
            Content = translations[language].noclip .. " " .. translations[language].notifyOff:lower(),
            Duration = 3
        })
    end
end

local function god(toggle)
    local char = getChar()
    local h = char:FindFirstChildOfClass("Humanoid")
    if h then
        if toggle then
            states.god.enabled = true
            h.MaxHealth = math.huge
            h.Health = math.huge
            h:GetPropertyChangedSignal("Health"):Connect(function()
                if states.god.enabled then
                    h.Health = math.huge
                end
            end)
            Rayfield:Notify({
                Title = translations[language].god .. " " .. translations[language].notifyOn,
                Content = translations[language].god .. " " .. translations[language].notifyOn:lower(),
                Duration = 3
            })
        else
            states.god.enabled = false
            h.MaxHealth = 100
            h.Health = 100
            Rayfield:Notify({
                Title = translations[language].god .. " " .. translations[language].notifyOff,
                Content = translations[language].god .. " " .. translations[language].notifyOff:lower(),
                Duration = 3
            })
        end
    else
        Rayfield:Notify({
            Title = translations[language].error,
            Content = translations[language].playerNotFound,
            Duration = 3
        })
    end
end

local function speed(toggle, value)
    local h = getChar():FindFirstChildOfClass("Humanoid")
    if h then
        if toggle then
            states.speed.enabled = true
            states.speed.originalSpeed = h.WalkSpeed
            h.WalkSpeed = value or 100
            Rayfield:Notify({
                Title = translations[language].speed .. " " .. translations[language].notifyOn,
                Content = translations[language].speed .. " " .. translations[language].notifyOn:lower() .. " (" .. (value or 100) .. ")",
                Duration = 3
            })
        else
            states.speed.enabled = false
            h.WalkSpeed = states.speed.originalSpeed
            Rayfield:Notify({
                Title = translations[language].speed .. " " .. translations[language].notifyOff,
                Content = translations[language].speed .. " " .. translations[language].notifyOff:lower(),
                Duration = 3
            })
        end
    end
end

local function jump(toggle)
    local h = getChar():FindFirstChildOfClass("Humanoid")
    if h then
        if toggle then
            states.jump.enabled = true
            states.jump.originalJump = h.JumpPower
            h.JumpPower = 150
            Rayfield:Notify({
                Title = translations[language].jump .. " " .. translations[language].notifyOn,
                Content = translations[language].jump .. " " .. translations[language].notifyOn:lower(),
                Duration = 3
            })
        else
            states.jump.enabled = false
            h.JumpPower = states.jump.originalJump
            Rayfield:Notify({
                Title = translations[language].jump .. " " .. translations[language].notifyOff,
                Content = translations[language].jump .. " " .. translations[language].notifyOff:lower(),
                Duration = 3
            })
        end
    end
end

local function invisible(toggle)
    local char = getChar()
    if toggle then
        states.invisible.enabled = true
        char.Archivable = true
        states.invisible.clone = char:Clone()
        states.invisible.clone.Parent = Workspace
        char.Parent = nil
        for _, part in pairs(states.invisible.clone:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
                if part:FindFirstChild("face") then
                    part.face.Transparency = 1
                end
            end
        end
        Rayfield:Notify({
            Title = translations[language].invisible .. " " .. translations[language].notifyOn,
            Content = translations[language].invisible .. " " .. translations[language].notifyOn:lower(),
            Duration = 3
        })
    else
        states.invisible.enabled = false
        if states.invisible.clone then
            states.invisible.clone:Destroy()
            states.invisible.clone = nil
        end
        char.Parent = Workspace
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = part:GetAttribute("OriginalTransparency") or 0
                if part:FindFirstChild("face") then
                    part.face.Transparency = part:GetAttribute("OriginalTransparency") or 0
                end
            end
        end
        Rayfield:Notify({
            Title = translations[language].invisible .. " " .. translations[language].notifyOff,
            Content = translations[language].invisible .. " " .. translations[language].notifyOff:lower(),
            Duration = 3
        })
    end
end

local function freeze(toggle)
    local char = getChar()
    local hrp = char:WaitForChild("HumanoidRootPart")
    if toggle then
        states.freeze.enabled = true
        hrp.Anchored = true
        Rayfield:Notify({
            Title = translations[language].freeze .. " " .. translations[language].notifyOn,
            Content = translations[language].freeze .. " " .. translations[language].notifyOn:lower(),
            Duration = 3
        })
    else
        states.freeze.enabled = false
        hrp.Anchored = false
        Rayfield:Notify({
            Title = translations[language].freeze .. " " .. translations[language].notifyOff,
            Content = translations[language].freeze .. " " .. translations[language].notifyOff:lower(),
            Duration = 3
        })
    end
end

local function goto(targetPlayerName)
    local target = findPlayer(targetPlayerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local char = getChar()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame
        Rayfield:Notify({
            Title = translations[language].gotoPlayer,
            Content = translations[language].gotoPlayer .. ": " .. target.Name,
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = translations[language].error,
            Content = translations[language].playerNotFound,
            Duration = 3
        })
    end
end

local function kill(targetPlayerName)
    local target = findPlayer(targetPlayerName)
    if target and target.Character then
        local h = target.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.Health = 0
            Rayfield:Notify({
                Title = translations[language].killPlayer,
                Content = translations[language].killPlayer .. ": " .. target.Name,
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = translations[language].playerNotFound,
                Duration = 3
            })
        end
    else
        Rayfield:Notify({
            Title = translations[language].error,
            Content = translations[language].playerNotFound,
            Duration = 3
        })
    end
end

local function spectate(toggle, targetPlayerName)
    local target = findPlayer(targetPlayerName)
    if toggle then
        if target and target.Character then
            states.spectate.enabled = true
            Camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            states.spectate.connection = RunService.RenderStepped:Connect(function()
                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    Camera.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 10))
                end
            end)
            Rayfield:Notify({
                Title = translations[language].spectatePlayer .. " " .. translations[language].notifyOn,
                Content = translations[language].spectatePlayer .. ": " .. target.Name,
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = translations[language].playerNotFound,
                Duration = 3
            })
        end
    else
        states.spectate.enabled = false
        if states.spectate.connection then
            states.spectate.connection:Disconnect()
            states.spectate.connection = nil
        end
        Camera.CameraSubject = getChar():FindFirstChildOfClass("Humanoid")
        Rayfield:Notify({
            Title = translations[language].spectatePlayer .. " " .. translations[language].notifyOff,
            Content = translations[language].spectatePlayer .. " " .. translations[language].notifyOff:lower(),
            Duration = 3
        })
    end
end

local function fling(targetPlayerName)
    local target = findPlayer(targetPlayerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local bodyVelocity = Instance.new("BodyVelocity", hrp)
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.Velocity = Vector3.new(0, 1000, 0)
        task.wait(0.5)
        bodyVelocity:Destroy()
        Rayfield:Notify({
            Title = translations[language].flingPlayer,
            Content = translations[language].flingPlayer .. ": " .. target.Name,
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = translations[language].error,
            Content = translations[language].playerNotFound,
            Duration = 3
        })
    end
end

local function tooldrop()
    local char = getChar()
    local h = char:FindFirstChildOfClass("Humanoid")
    if h then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Parent = Workspace
            end
        end
        Rayfield:Notify({
            Title = translations[language].tooldrop,
            Content = translations[language].tooldrop .. " " .. translations[language].notifyOn:lower(),
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = translations[language].error,
            Content = translations[language].playerNotFound,
            Duration = 3
        })
    end
end

local function nuke()
    local char = getChar()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local explosion = Instance.new("Explosion")
    explosion.Position = hrp.Position
    explosion.BlastRadius = 50
    explosion.BlastPressure = 50000
    explosion.Parent = Workspace
    Rayfield:Notify({
        Title = translations[language].nuke,
        Content = translations[language].nuke .. " " .. translations[language].notifyOn:lower(),
        Duration = 3
    })
end

local function rejoin()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    Rayfield:Notify({
        Title = translations[language].rejoin,
        Content = translations[language].rejoin .. " " .. translations[language].notifyOn:lower(),
        Duration = 3
    })
end

local function xray(toggle)
    if toggle then
        states.xray.enabled = true
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part ~= getChar():FindFirstChild("HumanoidRootPart") then
                part:SetAttribute("OriginalTransparency", part.Transparency)
                part.Transparency = 0.7
            end
        end
        Rayfield:Notify({
            Title = translations[language].xray .. " " .. translations[language].notifyOn,
            Content = translations[language].xray .. " " .. translations[language].notifyOn:lower(),
            Duration = 3
        })
    else
        states.xray.enabled = false
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = part:GetAttribute("OriginalTransparency") or 0
            end
        end
        Rayfield:Notify({
            Title = translations[language].xray .. " " .. translations[language].notifyOff,
            Content = translations[language].xray .. " " .. translations[language].notifyOff:lower(),
            Duration = 3
        })
    end
end

local function esp(toggle)
    if toggle then
        states.esp.enabled = true
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local highlight = Instance.new("Highlight", p.Character)
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                states.esp.highlights[p] = highlight
            end
        end
        Rayfield:Notify({
            Title = translations[language].esp .. " " .. translations[language].notifyOn,
            Content = translations[language].esp .. " " .. translations[language].notifyOn:lower(),
            Duration = 3
        })
    else
        states.esp.enabled = false
        for _, highlight in pairs(states.esp.highlights) do
            highlight:Destroy()
        end
        states.esp.highlights = {}
        Rayfield:Notify({
            Title = translations[language].esp .. " " .. translations[language].notifyOff,
            Content = translations[language].esp .. " " .. translations[language].notifyOff:lower(),
            Duration = 3
        })
    end
end

local function refresh()
    player:LoadCharacter()
    states.fly.enabled = false
    states.noclip.enabled = false
    states.god.enabled = false
    states.speed.enabled = false
    states.jump.enabled = false
    states.invisible.enabled = false
    states.freeze.enabled = false
    states.spectate.enabled = false
    states.xray.enabled = false
    states.esp.enabled = false
    if states.spectate.connection then
        states.spectate.connection:Disconnect()
        states.spectate.connection = nil
    end
    if states.invisible.clone then
        states.invisible.clone:Destroy()
        states.invisible.clone = nil
    end
    for _, highlight in pairs(states.esp.highlights) do
        highlight:Destroy()
    end
    states.esp.highlights = {}
    Rayfield:Notify({
        Title = translations[language].refresh,
        Content = translations[language].refresh .. " " .. translations[language].notifyOn:lower(),
        Duration = 3
    })
end

-- الأقسام
local movementTab = Window:CreateTab(translations[language].movementTab, 4483362458)
local powersTab = Window:CreateTab(translations[language].powersTab, 4483362458)
local playersTab = Window:CreateTab(translations[language].playersTab, 4483362458)
local customTab = Window:CreateTab(translations[language].customTab, 4483362458)
local settingsTab = Window:CreateTab(translations[language].settingsTab, 4483362458)

-- الحركة
movementTab:CreateButton({
    Name = translations[language].fly,
    Callback = function()
        fly(not states.fly.enabled)
    end
})
movementTab:CreateButton({
    Name = translations[language].noclip,
    Callback = function()
        noclip(not states.noclip.enabled)
    end
})
movementTab:CreateButton({
    Name = translations[language].speed,
    Callback = function()
        speed(not states.speed.enabled)
    end
})
movementTab:CreateInput({
    Name = translations[language].speedInput,
    PlaceholderText = translations[language].speedInput,
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local value = tonumber(text)
        if value then
            speed(true, value)
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = translations[language].error .. ": Invalid Number",
                Duration = 3
            })
        end
    end
})
movementTab:CreateButton({
    Name = translations[language].jump,
    Callback = function()
        jump(not states.jump.enabled)
    end
})

-- القدرات
powersTab:CreateButton({
    Name = translations[language].god,
    Callback = function()
        god(not states.god.enabled)
    end
})
powersTab:CreateButton({
    Name = translations[language].invisible,
    Callback = function()
        invisible(not states.invisible.enabled)
    end
})
powersTab:CreateButton({
    Name = translations[language].freeze,
    Callback = function()
        freeze(not states.freeze.enabled)
    end
})
powersTab:CreateButton({
    Name = translations[language].xray,
    Callback = function()
        xray(not states.xray.enabled)
    end
})
powersTab:CreateButton({
    Name = translations[language].esp,
    Callback = function()
        esp(not states.esp.enabled)
    end
})
powersTab:CreateButton({
    Name = translations[language].tooldrop,
    Callback = tooldrop
})
powersTab:CreateButton({
    Name = translations[language].nuke,
    Callback = nuke
})
powersTab:CreateButton({
    Name = translations[language].rejoin,
    Callback = rejoin
})

-- اللاعبين
local selectedPlayer = nil
local playerDropdown = playersTab:CreateDropdown({
    Name = translations[language].selectPlayer,
    Options = {},
    CurrentOption = nil,
    Callback = function(opt)
        selectedPlayer = opt
    end
})

playersTab:CreateInput({
    Name = translations[language].playerInput,
    PlaceholderText = translations[language].playerInput,
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        selectedPlayer = findPlayer(text) and findPlayer(text).Name or nil
        if selectedPlayer then
            Rayfield:Notify({
                Title = translations[language].selectPlayer,
                Content = translations[language].selectPlayer .. ": " .. selectedPlayer,
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = translations[language].playerNotFound,
                Duration = 3
            })
        end
    end
})

playersTab:CreateButton({
    Name = translations[language].killPlayer,
    Callback = function()
        if selectedPlayer then
            kill(selectedPlayer)
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = translations[language].selectPlayerError,
                Duration = 3
            })
        end
    end
})

playersTab:CreateButton({
    Name = translations[language].gotoPlayer,
    Callback = function()
        if selectedPlayer then
            goto(selectedPlayer)
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = translations[language].selectPlayerError,
                Duration = 3
            })
        end
    end
})

playersTab:CreateButton({
    Name = translations[language].spectatePlayer,
    Callback = function()
        if selectedPlayer then
            spectate(not states.spectate.enabled, selectedPlayer)
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = translations[language].selectPlayerError,
                Duration = 3
            })
        end
    end
})

playersTab:CreateButton({
    Name = translations[language].flingPlayer,
    Callback = function()
        if selectedPlayer then
            fling(selectedPlayer)
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = translations[language].selectPlayerError,
                Duration = 3
            })
        end
    end
})

-- تحديث قائمة اللاعبين
local function updatePlayerList()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    playerDropdown:Set(names)
end

task.spawn(function()
    while true do
        updatePlayerList()
        task.wait(5)
    end
end)

-- أمر مخصص
customTab:CreateInput({
    Name = translations[language].customCommand,
    PlaceholderText = translations[language].customPlaceholder,
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local h = getChar():FindFirstChildOfClass("Humanoid")
        local hrp = getChar():WaitForChild("HumanoidRootPart")
        text = text:lower()
        if text:match("speed") then
            local num = tonumber(text:match("%d+"))
            if h and num then
                speed(true, num)
            end
        elseif text:match("jump") then
            local num = tonumber(text:match("%d+"))
            if h and num then
                h.JumpPower = num
                Rayfield:Notify({
                    Title = translations[language].jump,
                    Content = translations[language].jump .. ": " .. num,
                    Duration = 3
                })
            end
        elseif text:match("goto") then
            local targetName = text:match("%s+(%w+)$")
            if targetName then
                goto(targetName)
            end
        elseif text:match("kill") then
            local targetName = text:match("%s+(%w+)$")
            if targetName then
                kill(targetName)
            end
        elseif text:match("spectate") then
            local targetName = text:match("%s+(%w+)$")
            if targetName then
                spectate(true, targetName)
            end
        elseif text:match("fling") then
            local targetName = text:match("%s+(%w+)$")
            if targetName then
                fling(targetName)
            end
        elseif text:match("tooldrop") then
            tooldrop()
        elseif text:match("nuke") then
            nuke()
        elseif text:match("rejoin") then
            rejoin()
        elseif text:match("xray") then
            xray(true)
        elseif text:match("esp") then
            esp(true)
        elseif text:match("refresh") then
            refresh()
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = translations[language].customCommand .. " Not Supported",
                Duration = 3
            })
        end
    end
})

-- إعدادات عامة
settingsTab:CreateButton({
    Name = translations[language].resetAll,
    Callback = function()
        fly(false)
        noclip(false)
        god(false)
        speed(false)
        jump(false)
        invisible(false)
        freeze(false)
        spectate(false, selectedPlayer or player.Name)
        xray(false)
        esp(false)
        Rayfield:Notify({
            Title = translations[language].resetAll,
            Content = translations[language].resetAll .. " " .. translations[language].notifyOff,
            Duration = 3
        })
    end
})

settingsTab:CreateButton({
    Name = translations[language].closeUI,
    Callback = function()
        Rayfield:Destroy()
        Rayfield:Notify({
            Title = translations[language].closeUI,
            Content = translations[language].closeUI .. " " .. translations[language].notifyOn:lower(),
            Duration = 3
        })
    end
})

-- قسم مضاف: 📦 ريسبون آيتم --


-- السكربت الأصلي محفوظ كما هو، إضافة قسم ريسبون آيتم فقط --

-- قسم الترجمة الجديد
translations.Arabic.respawnItem = "📦 ريسبون آيتم"
translations.Arabic.itemPlaceholder = "اكتب اسم الأداة مثل: Gun أو ToolName"
translations.English.respawnItem = "📦 Respawn Item"
translations.English.itemPlaceholder = "Enter item name like: Gun or ToolName"

-- تبويب جديد لواجهة جلب العناصر
local itemsTab = Window:CreateTab(translations[language].respawnItem, 4483362458)

itemsTab:CreateInput({
    Name = translations[language].respawnItem,
    PlaceholderText = translations[language].itemPlaceholder,
    RemoveTextAfterFocusLost = false,
    Callback = function(itemName)
        if itemName and itemName ~= "" then
            local char = getChar()
            local function findItem(storage)
                for _, item in pairs(storage:GetChildren()) do
                    if item:IsA("Tool") and item.Name:lower() == itemName:lower() then
                        return item
                    end
                end
                return nil
            end

            local storages = {
                game:GetService("ReplicatedStorage"),
                game:GetService("ServerStorage"),
                game:GetService("Workspace")
            }

            for _, storage in ipairs(storages) do
                local found = findItem(storage)
                if found then
                    local clone = found:Clone()
                    clone.Parent = char
                    Rayfield:Notify({
                        Title = translations[language].respawnItem,
                        Content = "Item '" .. itemName .. "' added to character.",
                        Duration = 3
                    })
                    return
                end
            end

            Rayfield:Notify({
                Title = translations[language].error,
                Content = "Item '" .. itemName .. "' not found.",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = translations[language].error,
                Content = "يرجى كتابة اسم الأداة / Please enter item name",
                Duration = 3
            })
        end
    end
})
