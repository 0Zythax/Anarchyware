local Players = game:GetService("Players");
local Teams = game:GetService("Teams");

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character;

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/0Zythax/CattowareFork/refs/heads/main/Library.lua"))()
local MainWindow = Library:CreateWindow("Anarchyware | Furry Infection Plus+", Vector2.new(492, 598), Enum.KeyCode.RightControl)

local CombatTab = MainWindow:CreateTab('Combat')
local CombatSection = CombatTab:CreateSector('Combat', 'left')

local UtilityTab = MainWindow:CreateTab('Utility')
local UtilityMapSection = UtilityTab:CreateSector('Map', 'left')
local UtilityCharSection = UtilityTab:CreateSector('Character', 'left')

local function FindNearestTargetWithTeam(Team)
    local Distance, Selection = 999999999, nil;
    for _, TargetCharacter in next, workspace:GetChildren() do
        if Players:FindFirstChild(TargetCharacter.Name) == nil or TargetCharacter.Name == LocalPlayer.Name then continue end;
        local TargetPlayer = Players:FindFirstChild(TargetCharacter.Name);
        if TargetPlayer.Team ~= Team then continue end;
        
        local TDistance = (Character.HumanoidRootPart.Position - TargetCharacter.HumanoidRootPart.Position).Magnitude
        if Distance > TDistance then
            Distance = TDistance
            Selection = TargetCharacter
        end
    end
    return Selection, Distance
end

local KillAuraEnabled = false
CombatSection:AddToggle('Kill Aura', false, function(ToggleEnabled)
    if not ToggleEnabled then KillAuraEnabled = false return end
    KillAuraEnabled = true
    
    task.spawn(function()
        while KillAuraEnabled do
            task.wait(.1)
            local TargetTeam = LocalPlayer.Team == Teams.Human and Teams.Transfured or Teams.Human
            local Target = FindNearestTargetWithTeam(TargetTeam);
            if Target == nil or Character:FindFirstChildWhichIsA('Tool') == nil then continue end
            pcall(function()
                local Tool = Character:FindFirstChildWhichIsA('Tool');
                Tool.Remote.Hit:FireServer(Target.HumanoidRootPart, Target.Humanoid, Target.HumanoidRootPart.Position)
            end)
        end
    end)
end)

local AutoEscapeEnabled = false
CombatSection:AddToggle('Auto Escape', false, function(ToggleEnabled)
    if not ToggleEnabled then AutoEscapeEnabled = false return end
    AutoEscapeEnabled = true

    task.spawn(function()
        while AutoEscapeEnabled == true do
            task.wait(.001) -- EscapeGui.Remote.Hit
            if Players.LocalPlayer.PlayerGui:FindFirstChild('EscapeGui') ~= nil then
                Players.LocalPlayer.PlayerGui.EscapeGui.Remote.Hit:InvokeServer()
            end
        end
    end)
end)

CombatSection:AddButton("Kill All Infected", function()
    for _, TPlayer in next, Players:GetPlayers() do
        if LocalPlayer.Team == Teams.Transfured then
            Character.HumanoidRootPart.CFrame = CFrame.new(946, 140, 1045)
            break
        end
        if TPlayer.Team == Teams.Transfured then
            local TargetCharacter = TPlayer.Character;
            if TargetCharacter.Humanoid.Health < 0 then continue end

            while TargetCharacter.Humanoid.Health > 0 do
                if LocalPlayer.Team == Teams.Transfured then
                    Character.HumanoidRootPart.CFrame = CFrame.new(946, 140, 1045)
                    break
                end
                task.wait(.05)
                pcall(function()
                    Character.HumanoidRootPart.CFrame = CFrame.new(TargetCharacter.Torso.Position + Vector3.new(1,1,0))
                    local Tool = Character:FindFirstChildWhichIsA('Tool');
                    Tool.Remote.Hit:FireServer(TargetCharacter.HumanoidRootPart, TargetCharacter.Humanoid, TargetCharacter.HumanoidRootPart.Position)
                end)
            end
        end
    end
end)

CombatSection:AddButton("(Dodgy) Infect All", function()
    if LocalPlayer.Team ~= Teams.Transfured then return end
    for _, TPlayer in next, Players:GetPlayers() do
        if Character.Humanoid.Health < 0 then break end
        if TPlayer.Team == Teams.Human then
            local TCharacter = TPlayer.Character
            if Character:FindFirstChild("Grab") == nil then
                LocalPlayer.Backpack.Grab.Parent = Character
            end
            repeat
                task.wait()
                pcall(function()
                    Character.HumanoidRootPart.CFrame = TCharacter.HumanoidRootPart.CFrame + -TCharacter.HumanoidRootPart.CFrame.LookVector
                    Character.Grab.Remote.Hit:FireServer(TCharacter.HumanoidRootPart, TCharacter.Humanoid, TCharacter.HumanoidRootPart.Position)
                end)
            until TCharacter.Humanoid.Health < 0 or TPlayer.Team == Teams.Transfured or Character.Humanoid.Health < 0 or LocalPlayer.Team ~= Teams.Transfured or TCharacter == nil or TPlayer == nil
        end
    end
end)

UtilityCharSection:AddButton("Remove Jump Cooldown", function()
    if LocalPlayer.PlayerGui:FindFirstChild("JumpCooldown") ~= nil then
        LocalPlayer.PlayerGui:FindFirstChild("JumpCooldown"):Destroy()
    end
end)

UtilityMapSection:AddButton("Remove Infection Puddles", function()
    for _, Thing in next, workspace:GetChildren() do
        if Thing.Name:lower():find("transfurpart") then
            Thing:Destroy()
        end
    end
end)

UtilityMapSection:AddButton("Remove KillGate", function()
    if workspace:FindFirstChild('KillField') ~= nil then
        workspace:FindFirstChild('KillField'):Destroy()
    end
end)

local SpamOpenEnabled = false;
UtilityMapSection:AddToggle("Spam Open Doors", false, function(ToggleEnabled)
    if not ToggleEnabled then SpamOpenEnabled = false return end
    SpamOpenEnabled = true

    task.spawn(function()
        while SpamOpenEnabled do
            task.wait(1)
            for _, Object in next, workspace:GetChildren() do
                if Object.Name == "Automatic Door2" then
                    local OldSensorSize = Object.Sensor.Size
                    Object.Sensor.Size = Vector3.new(2048, 2048, 2048)
                    task.delay(.1, function()
                        Object.Sensor.Size = OldSensorSize
                    end)
                end
            end
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter;
end)
