--[[
    Wave V4 Main
    Регистрирует модуль Huds внутри Vape (после его полной загрузки).
]]

local RAW = "https://raw.githubusercontent.com/H3llH3IM11/wave-v4/main/"

-- ждём Vape
repeat task.wait() until shared.vape

local vape = shared.vape

-- ждём, пока категории создадутся
local category
repeat
    task.wait(0.1)
    for _, name in ipairs({"Combat", "Render", "Utility", "Legit", "Blatant", "Settings", "Inventory", "Target Info"}) do
        if vape.Categories and typeof(vape.Categories[name]) == "table" then
            category = vape.Categories[name]
            break
        end
    end
until category ~= nil

-- проверка "не грузили дважды"
if shared.WaveMainLoaded then return end
shared.WaveMainLoaded = true

-- === СОСТОЯНИЕ ===
local activeHud = nil
local activePreset = "none"

local function unloadCurrent()
    if activeHud and activeHud.unload then
        pcall(activeHud.unload)
        activeHud = nil
    end
    activePreset = "none"
end

local function loadHud(preset)
    unloadCurrent()
    if preset == "none" then return end

    local file
    if preset == "wexside hud" then
        file = "huds/wexside.lua"
    elseif preset == "wave v4 hud" then
        file = "huds/wavev4.lua"
    end
    if not file then return end

    local url = RAW .. file
    local ok, src = pcall(function() return game:HttpGet(url, true) end)
    if not ok or not src or src == "404: Not Found" or #src == 0 then
        pcall(function() vape:CreateNotification("Huds", "failed to load " .. file, 5, "alert") end)
        return
    end

    local chunk, err = loadstring(src, preset)
    if not chunk then
        pcall(function() vape:CreateNotification("Huds", "syntax: " .. tostring(err), 5, "alert") end)
        return
    end

    local ok2, result = pcall(chunk)
    if not ok2 then
        pcall(function() vape:CreateNotification("Huds", "runtime: " .. tostring(result), 5, "alert") end)
        return
    end

    activeHud = result
    activePreset = preset
end

-- === СОЗДАНИЕ МОДУЛЯ ===
local hudsModule = category:CreateModule({
    Name = "Huds",
    Function = function(callback)
        if callback then
            if activePreset ~= "none" then
                loadHud(activePreset)
            end
        else
            unloadCurrent()
        end
    end,
    Tooltip = "Choose a custom HUD preset"
})

hudsModule:CreateDropdown({
    Name = "Preset",
    List = {"none", "wexside hud", "wave v4 hud"},
    Default = "none",
    Function = function(value)
        if hudsModule.Enabled then
            loadHud(value)
        else
            activePreset = value
        end
    end
})

pcall(function()
    vape:CreateNotification("Wave", "Huds module loaded", 4)
end)
