local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "GitHubImageGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Fling a target player (touch fling: ram them with your own character)
local flinging = false

local function flingPlayer(targetPlayer)
    if flinging then
        return
    end

    local char = player.Character
    local targetChar = targetPlayer.Character

    if not (char and char:FindFirstChild("HumanoidRootPart")) then
        return
    end
    if not (targetChar and targetChar:FindFirstChild("HumanoidRootPart")) then
        return
    end

    flinging = true

    local hrp = char.HumanoidRootPart
    local targetHrp = targetChar.HumanoidRootPart
    local originalPosition = hrp.CFrame.Position

    -- Freeze ourselves during the fling window
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    local bag = Instance.new("BodyAngularVelocity")
    bag.AngularVelocity = Vector3.new(0, 0, 0)
    bag.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bag.Parent = hrp

    -- Spin up and ram the target
    bag.AngularVelocity = Vector3.new(0, 50000, 0)
    bv.Velocity = Vector3.new(0, 250, 0)
    hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, 2, 0))

    task.wait(0.35)

    -- Clean up and return to where we were
    bv:Destroy()
    bag:Destroy()
    hrp.CFrame = CFrame.new(originalPosition + Vector3.new(0, 3, 0))

    flinging = false
end

-- Main box
local box = Instance.new("TextButton")
box.Size = UDim2.new(0, 60, 0, 60)
box.Position = UDim2.new(0.5, -30, 0.5, -30)
box.BackgroundColor3 = Color3.fromHex("2d2d2d")
box.Text = ""
box.AutoButtonColor = false
box.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = box

-- Main image (set from shared state; falls back to loading imageLoader.lua itself)
local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(1, 0, 1, 0)
imageLabel.BackgroundTransparency = 1
imageLabel.Parent = box

local imageCorner = Instance.new("UICorner")
imageCorner.CornerRadius = UDim.new(0, 8)
imageCorner.Parent = imageLabel

task.spawn(function()
    local shared = getgenv and getgenv() or _G

    if shared.FLING_GUI_IMAGE then
        -- Already loaded by GuiLoader.lua
        imageLabel.Image = shared.FLING_GUI_IMAGE
        return
    end

    -- Standalone run: load the image through imageLoader.lua
    local loaderUrl = "https://raw.githubusercontent.com/SidedRegent133/Fling-Gui/main/imageLoader.lua"
    local ok, result = pcall(function()
        local loader = loadstring(game:HttpGet(loaderUrl))()
        return loader and loader()
    end)

    if ok and result then
        shared.FLING_GUI_IMAGE = result
        imageLabel.Image = result
    else
        warn("Failed to load image via imageLoader: " .. tostring(result))
    end
end)

-- Bigger second box
local box2 = Instance.new("TextButton")
box2.Size = UDim2.new(0, 300, 0, 300)
box2.Position = UDim2.new(0.5, -150, 1, 5)
box2.BackgroundColor3 = Color3.fromHex("2d2d2d")
box2.Text = ""
box2.AutoButtonColor = false
box2.Visible = false
box2.Parent = box

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 8)
corner2.Parent = box2

-- Brown fling box (top-left of second box)
local flingBox = Instance.new("TextButton")
flingBox.Name = "FlingBox"
flingBox.Size = UDim2.new(0, 80, 0, 40)
flingBox.Position = UDim2.new(0, 10, 0, 10)
flingBox.BackgroundColor3 = Color3.fromRGB(121, 85, 58)
flingBox.Text = "Fling"
flingBox.TextColor3 = Color3.fromRGB(255, 255, 255)
flingBox.TextSize = 16
flingBox.Font = Enum.Font.GothamBold
flingBox.AutoButtonColor = true
flingBox.Parent = box2

local flingBoxCorner = Instance.new("UICorner")
flingBoxCorner.CornerRadius = UDim.new(0, 8)
flingBoxCorner.Parent = flingBox

-- Lobby player list (shown when the brown Fling box is pressed)
local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, -20, 1, -65)
playerList.Position = UDim2.new(0, 10, 0, 60)
playerList.BackgroundTransparency = 1
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 6
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.Visible = false
playerList.Parent = box2

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = playerList

local function createPlayerEntry(targetPlayer, order)
    local entry = Instance.new("TextButton")
    entry.Name = targetPlayer.Name
    entry.Size = UDim2.new(1, -8, 0, 30)
    entry.BackgroundColor3 = Color3.fromHex("3d3d3d")
    entry.Text = targetPlayer.Name
    entry.TextColor3 = Color3.fromRGB(255, 255, 255)
    entry.TextSize = 14
    entry.Font = Enum.Font.Gotham
    entry.AutoButtonColor = true
    entry.LayoutOrder = order
    entry.Parent = playerList

    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 6)
    entryCorner.Parent = entry

    entry.MouseButton1Click:Connect(function()
        flingPlayer(targetPlayer)
    end)
end

local function refreshPlayerList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local order = 1
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            createPlayerEntry(plr, order)
            order += 1
        end
    end
end

flingBox.MouseButton1Click:Connect(function()
    playerList.Visible = not playerList.Visible
    if playerList.Visible then
        refreshPlayerList()
    end
end)

Players.PlayerAdded:Connect(function()
    if playerList.Visible then
        refreshPlayerList()
    end
end)

Players.PlayerRemoving:Connect(function()
    if playerList.Visible then
        refreshPlayerList()
    end
end)

-- Toggle second box
box.MouseButton1Click:Connect(function()
    box2.Visible = not box2.Visible
    if not box2.Visible then
        playerList.Visible = false
    end
end)

-- Dragging
local dragging = false
local dragStart = Vector2.zero
local startPos = UDim2.new()

box.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = box.Position
    end
end)

box.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        box.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Fling self
box.MouseButton1Click:Connect(function()
    local char = player.Character

    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart

        local bv = Instance.new("BodyVelocity")
        bv.Parent = hrp
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(90000, 90000, 90000)

        task.wait(0.2)
        bv:Destroy()
    end
end)
