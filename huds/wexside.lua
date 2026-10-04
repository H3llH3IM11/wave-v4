--[[
    Wave V4 ЎЄ Wexside HUD preset
    §±§а§Ь§С §д§а§Э§о§Ь§а §У§а§д§Ц§в§Ю§С§в§Ь§С.
]]

return (function()
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local Stats = game:GetService("Stats")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")

    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- §й§Ъ§г§д§Ъ§Ю §г§д§С§в§а§Ц
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v.Name == "WaveWexsideHUD" then v:Destroy() end
    end

    -- === §ґ§¦§®§Ў (§Ь§С§Ь §У Wexside) ===
    local THEME = {
        bgPanel = Color3.fromRGB(20, 20, 20),
        stroke = Color3.fromRGB(55, 55, 55),
        text = Color3.fromRGB(240, 238, 235),
        gradientA = Color3.fromRGB(255, 120, 200),
        gradientB = Color3.fromRGB(120, 180, 255),
    }
    local RADIUS = 3

    -- === GRADIENT ANIMATOR ===
    local gradientRefs = {}
    task.spawn(function()
        while task.wait(0.05) do
            local t = tick() * 25
            for _, g in ipairs(gradientRefs) do
                if g[1] then g[1].Rotation = t % 360 end
                if g[2] then g[2].Rotation = (t + 180) % 360 end
            end
        end
    end)

    -- === §¤§­§Ў§Ј§Ї§Ѕ§« SCREENGUI ===
    local gui = Instance.new("ScreenGui")
    gui.Name = "WaveWexsideHUD"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    -- === §·§¦§­§±§¦§І §¤§І§Ў§Ґ§Є§¦§Ї§ґ§Ў ===
    local function applyGradientStyle(frame, radiusPx, withFill)
        frame.BackgroundColor3 = THEME.bgPanel
        if withFill then frame.BackgroundTransparency = 0.15
        else frame.BackgroundTransparency = 1 end
        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, radiusPx or RADIUS)
        local innerStroke = Instance.new("UIStroke", frame)
        innerStroke.Thickness = 1
        innerStroke.Color = THEME.stroke
        innerStroke.Transparency = 0.3
        local glow1 = Instance.new("UIStroke", frame)
        glow1.Thickness = 2
        glow1.Transparency = 0.35
        glow1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local grad1 = Instance.new("UIGradient", glow1)
        grad1.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, THEME.gradientA),
            ColorSequenceKeypoint.new(0.5, THEME.gradientB),
            ColorSequenceKeypoint.new(1, THEME.gradientA),
        })
        local glow2 = Instance.new("UIStroke", frame)
        glow2.Thickness = 5
        glow2.Transparency = 0.75
        glow2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local grad2 = Instance.new("UIGradient", glow2)
        grad2.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, THEME.gradientB),
            ColorSequenceKeypoint.new(0.5, THEME.gradientA),
            ColorSequenceKeypoint.new(1, THEME.gradientB),
        })
        table.insert(gradientRefs, {grad1, grad2})
        return corner
    end

    -- === §Ј§°§ґ§¦§І§®§Ў§І§¬§Ў ===
    local Watermark = Instance.new("Frame", gui)
    Watermark.Name = "Watermark"
    Watermark.Size = UDim2.new(0, 440, 0, 40)
    Watermark.Position = UDim2.new(0, 15, 0, 25)
    Watermark.Active = true
    Watermark.ZIndex = 60
    applyGradientStyle(Watermark, RADIUS, true)

    -- §С§У§С§д§С§в§Ь§С
    local avatarFrame = Instance.new("Frame", Watermark)
    avatarFrame.Size = UDim2.new(0, 30, 0, 30)
    avatarFrame.Position = UDim2.new(0, 5, 0, 5)
    avatarFrame.BackgroundColor3 = THEME.bgPanel
    avatarFrame.ZIndex = 61
    Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)

    local avatarStroke = Instance.new("UIStroke", avatarFrame)
    avatarStroke.Thickness = 1.5
    avatarStroke.Transparency = 0.2
    local avatarGrad = Instance.new("UIGradient", avatarStroke)
    avatarGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.gradientA),
        ColorSequenceKeypoint.new(1, THEME.gradientB),
    })
    table.insert(gradientRefs, {avatarGrad})

    local avatarImg = Instance.new("ImageLabel", avatarFrame)
    avatarImg.Size = UDim2.new(1, -4, 1, -4)
    avatarImg.Position = UDim2.new(0, 2, 0, 2)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    avatarImg.ZIndex = 62
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

    -- §д§Ц§Ь§г§д
    local watermarkText = Instance.new("TextLabel", Watermark)
    watermarkText.Size = UDim2.new(1, -50, 1, 0)
    watermarkText.Position = UDim2.new(0, 45, 0, 0)
    watermarkText.BackgroundTransparency = 1
    watermarkText.TextColor3 = THEME.text
    watermarkText.Font = Enum.Font.GothamMedium
    watermarkText.TextSize = 14
    watermarkText.TextXAlignment = Enum.TextXAlignment.Left
    watermarkText.ZIndex = 61
    watermarkText.Text = "wexside.xyz"

    -- === §°§ў§Ї§°§Ј§­§¦§Ї§Є§¦ §ґ§¦§¬§і§ґ§Ў ===
    local renderFrames = 0
    local connFps = RunService.RenderStepped:Connect(function()
        renderFrames = renderFrames + 1
    end)

    task.spawn(function()
        local lastTick = tick()
        while Watermark.Parent do
            task.wait(1)
            local now = tick()
            local elapsed = now - lastTick
            lastTick = now
            local fps = math.floor(renderFrames / math.max(elapsed, 0.001))
            renderFrames = 0

            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)

            local timeStr = "00:00:00"
            pcall(function() timeStr = os.date("%H:%M:%S") end)

            watermarkText.Text = string.format(
                "wexside.xyz  |  %s  |  %s  |  %d fps  |  %d ms",
                LocalPlayer.DisplayName, timeStr, fps, ping
            )
        end
    end)

    -- === DRAG ===
    local dragging, dragInput, dragStart, startPos
    local connDragBegan = Watermark.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Watermark.Position
        end
    end)
    local connDragChanged = Watermark.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    local connDragMove = UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            Watermark.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    local connDragEnd = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- === UNLOAD ===
    return {
        unload = function()
            pcall(function() connFps:Disconnect() end)
            pcall(function() connDragBegan:Disconnect() end)
            pcall(function() connDragChanged:Disconnect() end)
            pcall(function() connDragMove:Disconnect() end)
            pcall(function() connDragEnd:Disconnect() end)
            pcall(function() gui:Destroy() end)
        end,
    }
end)()
