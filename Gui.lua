local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "GitHubImageGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

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

-- Main image (loaded via imageLoader.lua)
local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(1, 0, 1, 0)
imageLabel.BackgroundTransparency = 1
imageLabel.Parent = box

local imageCorner = Instance.new("UICorner")
imageCorner.CornerRadius = UDim.new(0, 8)
imageCorner.Parent = imageLabel

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

-- Load image through imageLoader.lua
task.spawn(function()
    local loaderUrl = "https://raw.githubusercontent.com/SidedRegent133/Fling-Gui/main/imageLoader.lua"
    local ok, result = pcall(function()
        local loader = loadstring(game:HttpGet(loaderUrl))()
        return loader and loader()
    end)

    if ok and result then
        imageLabel.Image = result
    else
        warn("Failed to load image via imageLoader: " .. tostring(result))
    end
end)

-- Toggle second box
box.MouseButton1Click:Connect(function()
    box2.Visible = not box2.Visible
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

-- Fling
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
