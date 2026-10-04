--[[
    Wave V4 Loader
    Repo: https://github.com/H3llH3IM11/wave-v4
    Loads Vape V4 + our extras on top of it.
]]

repeat task.wait() until game:IsLoaded()

-- === УБИРАЕМ ПРЕДЫДУЩУЮ СЕССИЮ ===
if shared.vape then
    pcall(function() shared.vape:Uninject() end)
    shared.vape = nil
end

local RAW = "https://raw.githubusercontent.com/H3llH3IM11/wave-v4/main/"
local VAPE_RAW = "https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/"

-- === ЗАГЛУШКИ ФУНКЦИЙ (если executor старый) ===
local loadstring_orig = loadstring
local cloneref = cloneref or function(o) return o end
local isfile = isfile or function(f)
    local ok, res = pcall(function() return readfile(f) end)
    return ok and res ~= nil and res ~= ""
end
local isfolder = isfolder or function(f)
    local ok = pcall(function()
        return game:GetService("HttpService")
    end)
    return false
end
local makefolder = makefolder or function() end
local queue_on_teleport = queue_on_teleport or function() end

local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

-- === ЗАГРУЗЧИК VAPE ===
local function downloadVapeFile(path)
    -- сначала проверяем локально — Vape может уже быть в кэше
    if isfile(path) then
        return readfile(path)
    end

    -- иначе качаем с официальной репы Vape
    local commit = "main"
    if isfile("newvape/profiles/commit.txt") then
        commit = readfile("newvape/profiles/commit.txt")
    end

    local clean = select(1, path:gsub("newvape/", ""))
    local url = VAPE_RAW .. commit .. "/" .. clean
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not ok or not res or res == "404: Not Found" or #res == 0 then
        error("[Wave] failed to download vape file: " .. path)
    end

    if path:find(".lua") then
        res = "-- cache-tag\n" .. res
    end

    pcall(writefile, path, res)
    return res
end

-- === ЗАГРУЗЧИК НАШИХ ФАЙЛОВ ===
local function downloadWaveFile(path)
    local url = RAW .. path
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not ok or not res or res == "404: Not Found" or #res == 0 then
        error("[Wave] failed to download: " .. url)
    end

    return res
end

-- === ГРУЗИМ VAPE ===
print("[Wave] loading Vape V4...")

local vape
local function loadWrapper(...)
    local res, err = loadstring_orig(...)
    if err and vape then
        pcall(function() vape:CreateNotification("Wave", "Load error: " .. err, 30, "alert") end)
    end
    return res
end

-- кладём вспомогательные функции в окружение для Vape
shared.WaveDownloadFile = downloadVapeFile
shared.WaveRootPath = "newvape"
shared.WaveRaw = RAW

-- убедимся, что структура папок есть
pcall(function()
    if not isfolder("newvape") then makefolder("newvape") end
    if not isfolder("newvape/profiles") then makefolder("newvape/profiles") end
    if not isfolder("newvape/guis") then makefolder("newvape/guis") end
    if not isfolder("newvape/games") then makefolder("newvape/games") end
    if not isfolder("newvape/assets") then makefolder("newvape/assets") end
end)

-- подхватываем commit, если он уже есть
if not isfile("newvape/profiles/gui.txt") then
    pcall(writefile, "newvape/profiles/gui.txt", "new")
end

local guiName = isfile("newvape/profiles/gui.txt") and readfile("newvape/profiles/gui.txt") or "new"

-- главный gui Vape
if not isfolder("newvape/assets/" .. guiName) then
    pcall(makefolder, "newvape/assets/" .. guiName)
end

vape = loadWrapper(downloadVapeFile("newvape/guis/" .. guiName .. ".lua"), "gui")()
shared.vape = vape

-- universal модуль Vape
if not shared.VapeIndependent then
    loadWrapper(downloadVapeFile("newvape/games/universal.lua"), "universal")()
end

-- грузим наш main.lua ПОСЛЕ того как Vape встал
print("[Wave] loading Wave extras...")
task.spawn(function()
    local ok, mainSrc = pcall(downloadWaveFile, "main.lua")
    if not ok then
        warn("[Wave] main.lua not loaded: " .. tostring(mainSrc))
        return
    end

    local chunk, err = loadstring_orig(mainSrc, "wave-main")
    if not chunk then
        warn("[Wave] main.lua syntax error: " .. tostring(err))
        return
    end

    local ok2, err2 = pcall(chunk)
    if not ok2 then
        warn("[Wave] main.lua runtime error: " .. tostring(err2))
    else
        print("[Wave] extras loaded.")
    end
end)

-- === АВТОПЕРЕЗАГРУЗКА ПРИ ТЕЛЕПОРТЕ ===
if not shared.WaveNoReload then
    pcall(function()
        LocalPlayer.OnTeleport:Connect(function()
            pcall(function()
                queue_on_teleport([[
                    shared.WaveNoReload = false
                    loadstring(game:HttpGet("]] .. RAW .. [[loader.lua", true), "loader")()
                ]])
            end)
        end)
    end)
end