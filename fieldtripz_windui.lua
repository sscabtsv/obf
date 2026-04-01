-- Field Trip Z Hub | WindUI Port
-- Original: github.com/lunar0x4 | V1.0

-- ── Executor check ────────────────────────────────────────────
local ok = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/lunar0x4/game-scripts/refs/heads/main/scripts/exec_check.lua"
))()
if not ok then return end

-- ── Load WindUI ───────────────────────────────────────────────
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

-- ── Shared services ───────────────────────────────────────────
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local LocalPlayer       = Players.LocalPlayer

local NetworkEvents  = ReplicatedStorage:WaitForChild("NetworkEvents")
local RemoteFunction = NetworkEvents:WaitForChild("RemoteFunction")
local RemoteEvent    = NetworkEvents:WaitForChild("RemoteEvent")

-- ── Window ────────────────────────────────────────────────────
local Window = WindUI:CreateWindow({
    Title    = "Field Trip Z Hub",
    Folder   = "FieldTripZHub",
    Icon     = "backpack",
    NewElements = true,
    OpenButton = {
        Title    = "Field Trip Z Hub",
        Enabled  = true,
        Draggable = true,
    },
})

-- ═══════════════════════════════════════════════════════════════
-- ITEMS TAB
-- ═══════════════════════════════════════════════════════════════
local ItemsTab = Window:Tab({
    Title = "Items",
    Icon  = "gift",
})

local ItemsSection = ItemsTab:Section({
    Title     = "Item Spawning",
    Box       = true,
    BoxBorder = true,
    Opened    = true,
})

local selectedItem = "Donut"

ItemsSection:Dropdown({
    Title  = "Select Item",
    Values = {
        "Donut",
        "Bandage",
        "Rocket",
        "BlueKey",
        "YellowKey",
        "GoldenDonut",
        "Homework",
        "MedKit",
    },
    Value    = "Donut",
    Callback = function(selected)
        selectedItem = selected
        WindUI:Notify({
            Title   = "Item Selected",
            Content = "Selected: " .. tostring(selected),
            Duration = 2,
        })
    end,
})

ItemsSection:Button({
    Title    = "Give Selected Item",
    Icon     = "package-plus",
    Callback = function()
        local success, err = pcall(function()
            RemoteFunction:InvokeServer("PICKUP_ITEM", selectedItem)
        end)
        WindUI:Notify({
            Title   = success and "Item Spawned" or "Error",
            Content = success and ("Gave: " .. selectedItem) or tostring(err),
            Duration = 3,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════════
-- COMBAT TAB
-- ═══════════════════════════════════════════════════════════════
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon  = "swords",
})

local CombatSection = CombatTab:Section({
    Title     = "Zombie Options",
    Box       = true,
    BoxBorder = true,
    Opened    = true,
})

CombatSection:Button({
    Title    = "Break Free From Dave",
    Icon     = "shield-off",
    Callback = function()
        pcall(function()
            RemoteEvent:FireServer("DAVE_BROKE_FREE")
        end)
        WindUI:Notify({
            Title    = "Combat",
            Content  = "Attempted to break free from Dave.",
            Duration = 2,
        })
    end,
})

CombatSection:Button({
    Title    = "Kill All Zombies",
    Icon     = "skull",
    Callback = function()
        local killed = 0
        task.spawn(function()
            for _, instance in ipairs(workspace:GetDescendants()) do
                if instance.Name:match("^Zombie") then
                    local humanoid = instance:FindFirstChild("Humanoid")
                    if humanoid then
                        for i = 1, 50 do
                            pcall(function()
                                RemoteFunction:InvokeServer("DO_DAMAGE", humanoid, 10)
                            end)
                            task.wait()
                        end
                        killed = killed + 1
                    end
                end
            end
            WindUI:Notify({
                Title    = "Kill All Zombies",
                Content  = "Finished. Zombies targeted: " .. killed,
                Duration = 4,
            })
        end)
        WindUI:Notify({
            Title    = "Kill All Zombies",
            Content  = "Started killing all zombies...",
            Duration = 2,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════════
-- HEALTH TAB
-- ═══════════════════════════════════════════════════════════════
local HealthTab = Window:Tab({
    Title = "Health",
    Icon  = "heart-pulse",
})

local HealthSection = HealthTab:Section({
    Title     = "Healing Options",
    Box       = true,
    BoxBorder = true,
    Opened    = true,
})

local autoHealLoop     = nil
local loopHealAllLoop  = nil

HealthSection:Toggle({
    Title    = "Infinite Health",
    Value    = false,
    Callback = function(state)
        if state then
            autoHealLoop = RunService.Heartbeat:Connect(function()
                pcall(function()
                    RemoteFunction:InvokeServer("HEAL_PLAYER", LocalPlayer, 50)
                end)
            end)
        else
            if autoHealLoop then
                autoHealLoop:Disconnect()
                autoHealLoop = nil
            end
        end
    end,
})

HealthSection:Space()

HealthSection:Button({
    Title    = "Heal All Players",
    Icon     = "heart-handshake",
    Callback = function()
        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            pcall(function()
                RemoteFunction:InvokeServer("HEAL_PLAYER", player, 50)
            end)
            count = count + 1
        end
        WindUI:Notify({
            Title    = "Heal All",
            Content  = "Healed " .. count .. " player(s).",
            Duration = 3,
        })
    end,
})

HealthSection:Space()

HealthSection:Toggle({
    Title    = "Loop Heal All Players",
    Value    = false,
    Callback = function(state)
        if state then
            loopHealAllLoop = RunService.Heartbeat:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    pcall(function()
                        RemoteFunction:InvokeServer("HEAL_PLAYER", player, 50)
                    end)
                end
            end)
        else
            if loopHealAllLoop then
                loopHealAllLoop:Disconnect()
                loopHealAllLoop = nil
            end
        end
    end,
})

-- ═══════════════════════════════════════════════════════════════
-- BUILDING TAB
-- ═══════════════════════════════════════════════════════════════
local BuildingTab = Window:Tab({
    Title = "Building",
    Icon  = "hammer",
})

local BuildingSection = BuildingTab:Section({
    Title     = "Window Options",
    Box       = true,
    BoxBorder = true,
    Opened    = true,
})

BuildingSection:Button({
    Title    = "Board Up All Windows",
    Icon     = "layout-grid",
    Callback = function()
        task.spawn(function()
            local windows = workspace:WaitForChild("Interactions", 10)
                and workspace.Interactions:WaitForChild("Windows", 10)
            if not windows then
                WindUI:Notify({
                    Title    = "Error",
                    Content  = "Could not find Windows folder.",
                    Duration = 4,
                })
                return
            end
            WindUI:Notify({
                Title    = "Building",
                Content  = "Boarding up all windows...",
                Duration = 3,
            })
            for i = 1, 250 do
                for _, window in ipairs(windows:GetChildren()) do
                    pcall(function()
                        RemoteFunction:InvokeServer("PLACE_PLANK", window)
                    end)
                end
                task.wait()
            end
            WindUI:Notify({
                Title    = "Building",
                Content  = "All windows boarded up!",
                Duration = 3,
            })
        end)
    end,
})

-- ═══════════════════════════════════════════════════════════════
-- MISC TAB
-- ═══════════════════════════════════════════════════════════════
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon  = "settings-2",
})

local MiscSection = MiscTab:Section({
    Title     = "Console Options",
    Box       = true,
    BoxBorder = true,
    Opened    = true,
})

local autoConsoleLoop = nil

MiscSection:Toggle({
    Title    = "Auto Hit Console (Boss Fight)",
    Value    = false,
    Callback = function(state)
        if state then
            autoConsoleLoop = RunService.Heartbeat:Connect(function()
                pcall(function()
                    RemoteEvent:FireServer("HitConsole")
                end)
            end)
        else
            if autoConsoleLoop then
                autoConsoleLoop:Disconnect()
                autoConsoleLoop = nil
            end
        end
    end,
})

MiscSection:Space()

MiscSection:Button({
    Title    = "Hit Console 20x (Boss Fight)",
    Icon     = "mouse-pointer-click",
    Callback = function()
        task.spawn(function()
            for i = 1, 20 do
                pcall(function()
                    RemoteEvent:FireServer("HitConsole")
                end)
            end
        end)
        WindUI:Notify({
            Title    = "Console",
            Content  = "Hit console 20 times.",
            Duration = 2,
        })
    end,
})
