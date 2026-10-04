--[[
    Wave V4 Main
    Регистрирует модуль Huds внутри Vape.
]]

local RAW = "https://raw.githubusercontent.com/H3llH3IM11/wave-v4/main/"

repeat task.wait() until shared.vape and shared.vape.Loaded

local vape = shared.vape

-- проверка что модуль уже есть (чтобы не грузить дважды)
if shared.WaveMainLoaded then return end
shared.WaveMainLoaded = true

-- === ФУНКЦИЯ ЗАГРУЗКИ HUD ===
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

    local file = nil
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

-- === СОЗДАНИЕ КАТЕГОРИИ ===
-- если категории Huds нет — создаём через Main
local hudsCategory
if vape.Categories and vape.Categories.Huds then
    hudsCategory = vape.Categories.Huds
elseif vape.Categories and vape.Categories.Main then
    local ok, cat = pcall(function()
        return vape.Categories.Main:CreateCategory({
            Name = "Huds",
            Tooltip = "Custom HUD presets"
        })
    end)
    if ok and cat then
        hudsCategory = cat
    end
end

if not hudsCategory then
    warn("[Wave] не удалось создать категорию Huds")
    return
end

-- === СОЗДАНИЕ МОДУЛЯ ===
local hudsModule = hudsCategory:CreateModule({
    Name = "Huds",
    Function = function(callback)
        if callback then
            -- при включении — если пресет уже выбран, загружаем
            if activePreset ~= "none" then
                loadHud(activePreset)
            end
        else
            -- при выключении — грузим ВСЁ
            unloadCurrent()
        end
    end,
    Tooltip = "Choose a custom HUD preset"
})

-- === ДРОПДАУН ПРЕСЕТОВ ===
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