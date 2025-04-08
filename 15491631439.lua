local Players = game:GetService("Players");
local Teams = game:GetService("Teams");

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character;

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/0Zythax/CattowareFork/refs/heads/main/Library.lua"))()
local MainWindow = Library:CreateWindow("Anarchyware | Fluffy Infection", Vector2.new(492, 200), Enum.KeyCode.RightControl)

local CombatTab = MainWindow:CreateTab('Combat')
local CombatSection = CombatTab:CreateSector('Combat', 'left')
local VisualSection = CombatTab:CreateSector('ESP', 'right')

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
            task.wait(.001)
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

local SeeAll = false;
VisualSection:AddToggle('ESP', false, function(ToggleEnabled)
    if not ToggleEnabled then 
        SeeAll = false
        for _, TPlayer in next, Players:GetPlayers() do
            local TCharacter = TPlayer.Character
            if TCharacter.HumanoidRootPart:FindFirstChildOfClass("Highlight") ~= nil then
                TCharacter.HumanoidRootPart:FindFirstChildOfClass("Highlight"):Destroy()
            end
        end
        return;
    end

    SeeAll = true

    task.spawn(function()
        while SeeAll == true do
            task.wait(1)
            for _, TPlayer in next, Players:GetPlayers() do
                local TCharacter = TPlayer.Character;
                if TCharacter.HumanoidRootPart:FindFirstChildOfClass('Highlight') == nil then
                    if not SeeAll then return end
                    local NewHighlight = Instance.new("Highlight")
                    NewHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    NewHighlight.OutlineColor = TPlayer.Team == Teams.Transfured and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                    NewHighlight.Enabled = true
                    NewHighlight.Adornee = TCharacter
                    NewHighlight.FillTransparency = 1
                    NewHighlight.Parent = TCharacter.HumanoidRootPart
                else
                    TCharacter.HumanoidRootPart:FindFirstChildOfClass("Highlight").FillColor = TPlayer.Team == Teams.Transfured and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                end
            end
        end
    end)
end)

CombatSection:AddButton("Kill All Infected", function()
    for _, TargetPlayer in next, Players:GetPlayers() do
        task.wait(0.01)

        -- infected
        if LocalPlayer.Team == Teams.Transfured then
            Character.Humanoid:TakeDamage(999999)
            Character.HumanoidRootPart.CFrame = CFrame.new(0,-99999,0)
            break
        end

        -- dead
        if Character.Humanoid.Health <= 0 then break end

        -- target checks
        local TargetCharacter = TargetPlayer.Character;
        if TargetCharacter.Humanoid.Health < 0 or TargetPlayer.Team == Teams.Human or TargetPlayer == LocalPlayer then continue end

        -- loop
        repeat
            task.wait(0.01)
            if LocalPlayer.Team == Teams.Transfured then
                Character.Humanoid:TakeDamage(999999)
                Character.HumanoidRootPart.CFrame = CFrame.new(0,-99999,0)
                break
            end
            Character.HumanoidRootPart.CFrame = CFrame.new(TargetCharacter.Head.Position + Vector3.new(0,1,0))
            if Character:FindFirstChildOfClass("Tool") == nil then
                LocalPlayer.Backpack.Punch.Parent = Character
            end
            pcall(function()
                local Tool = Character:FindFirstChildOfClass('Tool');
                Tool.Remote.Hit:FireServer(TargetCharacter.HumanoidRootPart, TargetCharacter.Humanoid, TargetCharacter.HumanoidRootPart.Position)
            end)
        until TargetCharacter.Humanoid.Health <= 0 or Character.Humanoid.Health <= 0 or LocalPlayer.Team == Teams.Transfured
    end
end)

CombatSection:AddButton("Infect All", function()
    local LastPosition = Character.HumanoidRootPart.CFrame
    for _, TargetPlayer in next, Players:GetPlayers() do
        task.wait(0.01)

        -- are we dead
        if Character.Humanoid.Health <= 0 then break end

        -- target checks
        local TargetCharacter = TargetPlayer.Character;
        if TargetCharacter.Humanoid.Health <= 0 or TargetPlayer.Team == Teams.Transfured or TargetPlayer == LocalPlayer then continue end
        if TargetCharacter:FindFirstChildOfClass("ForceField") then continue end

        repeat
            task.wait(0.01)
            Character.HumanoidRootPart.CFrame = CFrame.new(TargetCharacter.Head.Position + Vector3.new(0,1,0))
            if Character:FindFirstChild('Attack') == nil then
                LocalPlayer.Backpack.Attack.Parent = Character;
            end
            pcall(function()
                local Tool = Character:FindFirstChildOfClass('Tool');
                Tool.Remote.Hit:FireServer(TargetCharacter.HumanoidRootPart, TargetCharacter.Humanoid, TargetCharacter.HumanoidRootPart.Position)
            end)
        until TargetCharacter.Humanoid.Health <= 0 or Character.Humanoid.Health <= 0 or TargetPlayer.Team == Teams.Transfured
    end
    if Character.Humanoid.Health > 0 then
        Character.HumanoidRootPart.CFrame = LastPosition 
    end
end)

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter;
end)
