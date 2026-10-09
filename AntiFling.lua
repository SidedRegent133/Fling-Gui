-- AntiFling.lua
-- Stops spin-flingers: detects rapid involuntary movement/spin and counteracts it.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local ENABLED = true
local CHECK_INTERVAL = 0.1        -- seconds between checks
local POSITION_SPIKE = 60        -- studs/sec sudden displacement = suspicious
local SPIN_SPIKE = 100           -- sudden spin magnitude = suspicious
local RECOVER_HEIGHT = 3         -- studs above spike position to recover to

local lastCFrame: CFrame? = nil
local lastCheck = 0

local function getChar()
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid")) then
        return nil, nil, nil
    end
    return char, char.HumanoidRootPart, char.Humanoid
end

local function cleanMovers(hrp)
    -- Remove the exact movers a flinger sticks on you
    for _, child in ipairs(hrp:GetChildren()) do
        if child:IsA("BodyVelocity")
            or child:IsA("BodyAngularVelocity")
            or child:IsA("BodyForce")
            or child:IsA("BodyThrust")
            or child:IsA("RocketPropulsion")
            or (child:IsA("BodyGyro") and child.MaxTorque.Magnitude > 1e6)
            or (child:IsA("BodyPosition") and child.MaxForce.Magnitude > 1e6) then
            child:Destroy()
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    if not ENABLED then
        return
    end

    local char, hrp, humanoid = getChar()
    if not char then
        lastCFrame = nil
        return
    end

    lastCheck += dt
    if lastCheck < CHECK_INTERVAL then
        return
    end

    local current = hrp.CFrame
    lastCheck = 0

    if lastCFrame then
        local delta = current.Position - lastCFrame.Position
        local displacementSpeed = delta.Magnitude / CHECK_INTERVAL

        local rotDelta = math.abs((current - lastCFrame):ToOrientation())
        local spinSpeed = rotDelta / CHECK_INTERVAL

        -- Fling signature: massive displacement or massive spin that we didn't author
        if displacementSpeed > POSITION_SPIKE or spinSpeed > SPIN_SPIKE then
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall
                or humanoid:GetState() == Enum.HumanoidStateType.FallingDown
                or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then

                cleanMovers(hrp)

                -- Kill momentum and recover to just above where the spike started
                local anchor = Instance.new("BodyPosition")
                anchor.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                anchor.P = 3e4
                anchor.D = 1000
                anchor.Position = lastCFrame.Position + Vector3.new(0, RECOVER_HEIGHT, 0)
                anchor.Parent = hrp

                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

                task.delay(0.5, function()
                    if anchor.Parent then
                        anchor:Destroy()
                    end
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end
        end
    end

    lastCFrame = current
end)

player.CharacterAdded:Connect(function()
    lastCFrame = nil
end)

return {
    setEnabled = function(state)
        ENABLED = state and true or false
    end,
    isEnabled = function()
        return ENABLED
    end
}
