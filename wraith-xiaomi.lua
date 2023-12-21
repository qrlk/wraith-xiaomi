require "lib.moonloader"

script_name("wraith-xiaomi")
script_author("qrlk")
script_description("aimline render cut from https://github.com/qrlk/wraith.lua")
-- made for https://www.blast.hk/threads/193650/
script_url("https://github.com/qrlk/wraith-xiaomi")
script_version("21.12.2023-dev1")

-- https://github.com/qrlk/qrlk.lua.moonloader
local enable_sentry = true -- false to disable error reports to sentry.io
if enable_sentry then
    local sentry_loaded, Sentry =
        pcall(
            loadstring,
            [=[return {init=function(a)local b,c,d=string.match(a.dsn,"https://(.+)@(.+)/(%d+)")local e=string.format("https://%s/api/%d/store/?sentry_key=%s&sentry_version=7&sentry_data=",c,d,b)local f=string.format("local target_id = %d local target_name = \"%s\" local target_path = \"%s\" local sentry_url = \"%s\"\n",thisScript().id,thisScript().name,thisScript().path:gsub("\\","\\\\"),e)..[[require"lib.moonloader"script_name("sentry-error-reporter-for: "..target_name.." (ID: "..target_id..")")script_description("Этот скрипт перехватывает вылеты скрипта '"..target_name.." (ID: "..target_id..")".."' и отправляет их в систему мониторинга ошибок Sentry.")local a=require"encoding"a.default="CP1251"local b=a.UTF8;local c="moonloader"function getVolumeSerial()local d=require"ffi"d.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local e=d.new("unsigned long[1]",0)d.C.GetVolumeInformationA(nil,nil,0,e,nil,nil,nil,0)e=e[0]return e end;function getNick()local f,g=pcall(function()local f,h=sampGetPlayerIdByCharHandle(PLAYER_PED)return sampGetPlayerNickname(h)end)if f then return g else return"unknown"end end;function getRealPath(i)if doesFileExist(i)then return i end;local j=-1;local k=getWorkingDirectory()while j*-1~=string.len(i)+1 do local l=string.sub(i,0,j)local m,n=string.find(string.sub(k,-string.len(l),-1),l)if m and n then return k:sub(0,-1*(m+string.len(l)))..i end;j=j-1 end;return i end;function url_encode(o)if o then o=o:gsub("\n","\r\n")o=o:gsub("([^%w %-%_%.%~])",function(p)return("%%%02X"):format(string.byte(p))end)o=o:gsub(" ","+")end;return o end;function parseType(q)local r=q:match("([^\n]*)\n?")local s=r:match("^.+:%d+: (.+)")return s or"Exception"end;function parseStacktrace(q)local t={frames={}}local u={}for v in q:gmatch("([^\n]*)\n?")do local w,x=v:match("^	*(.:.-):(%d+):")if not w then w,x=v:match("^	*%.%.%.(.-):(%d+):")if w then w=getRealPath(w)end end;if w and x then x=tonumber(x)local y={in_app=target_path==w,abs_path=w,filename=w:match("^.+\\(.+)$"),lineno=x}if x~=0 then y["pre_context"]={fileLine(w,x-3),fileLine(w,x-2),fileLine(w,x-1)}y["context_line"]=fileLine(w,x)y["post_context"]={fileLine(w,x+1),fileLine(w,x+2),fileLine(w,x+3)}end;local z=v:match("in function '(.-)'")if z then y["function"]=z else local A,B=v:match("in function <%.* *(.-):(%d+)>")if A and B then y["function"]=fileLine(getRealPath(A),B)else if#u==0 then y["function"]=q:match("%[C%]: in function '(.-)'\n")end end end;table.insert(u,y)end end;for j=#u,1,-1 do table.insert(t.frames,u[j])end;if#t.frames==0 then return nil end;return t end;function fileLine(C,D)D=tonumber(D)if doesFileExist(C)then local E=0;for v in io.lines(C)do E=E+1;if E==D then return v end end;return nil else return C..D end end;function onSystemMessage(q,type,i)if i and type==3 and i.id==target_id and i.name==target_name and i.path==target_path and not q:find("Script died due to an error.")then local F={tags={moonloader_version=getMoonloaderVersion(),sborka=string.match(getGameDirectory(),".+\\(.-)$")},level="error",exception={values={{type=parseType(q),value=q,mechanism={type="generic",handled=false},stacktrace=parseStacktrace(q)}}},environment="production",logger=c.." (no sampfuncs)",release=i.name.."@"..i.version,extra={uptime=os.clock()},user={id=getVolumeSerial()},sdk={name="qrlk.lua.moonloader",version="0.0.0"}}if isSampAvailable()and isSampfuncsLoaded()then F.logger=c;F.user.username=getNick().."@"..sampGetCurrentServerAddress()F.tags.game_state=sampGetGamestate()F.tags.server=sampGetCurrentServerAddress()F.tags.server_name=sampGetCurrentServerName()else end;print(downloadUrlToFile(sentry_url..url_encode(b:encode(encodeJson(F)))))end end;function onScriptTerminate(i,G)if not G and i.id==target_id then lua_thread.create(function()print("скрипт "..target_name.." (ID: "..target_id..")".."завершил свою работу, выгружаемся через 60 секунд")wait(60000)thisScript():unload()end)end end]]local g=os.tmpname()local h=io.open(g,"w+")h:write(f)h:close()script.load(g)os.remove(g)end}]=]
        )
    if sentry_loaded and Sentry then
        pcall(
            Sentry().init,
            {
                dsn = "https://0276edffe3b2d52b0bc1ed72eb057e4b@o1272228.ingest.sentry.io/4506434589687808"
            }
        )
    end
end

-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater =
        pcall(
            loadstring,
            [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]]
        )
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url =
                "https://raw.githubusercontent.com/qrlk/wraith-xiaomi/master/version.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/qrlk/wraith-xiaomi/"
        end
    end
end

--- start
local inicfg = require "inicfg"
local sampev = require "lib.samp.events"

local tempThreads = {}
local mod_submenus_sa = {}

local cfg =
    inicfg.load(
        {
            options = {
                welcomeMessage = true,
                debug = true,
                debugNeed3dtext = true,
                debugNeedTracer = true,
                debugNeedPhoneSmall = false,
                debugNeedPhoneBig = true,
            }
        },
        "wraith-xiaomi"
    )

function saveCfg()
    inicfg.save(cfg, "wraith-xiaomi")
end

saveCfg()

--

local debug3dText = {}
local phonesObject = {}
local PHONE_SLOT = 2
local playersAimData = {}
local DEBUG_3D_TEXT_DISTANCE = 10.0

------- snippet start

-- trying to ulitize aspectRatio property from aimSync

-- 2. 720x480 - Aspect Ratio: 3:2  127

-- 1. 640x480 - Aspect Ratio: 4:3 85
-- 4. 800x600 - Aspect Ratio: 4:3 85
-- 5. 1024x768 - Aspect Ratio: 4:3 85
-- 6. 1152x864 - Aspect Ratio: 4:3 85
-- 11. 1280x960 - Aspect Ratio: 4:3 85
-- 15. 1440x1080 - Aspect Ratio: 4:3 85
-- 18. 1600x1200 - Aspect Ratio: 4:3 85
-- 24. 1920x1440 - Aspect Ratio: 4:3 85

-- 9. 1280x768 - Aspect Ratio: 5:3 169

-- 3. 720x576 - Aspect Ratio: 5:4 63
-- 12. 1280x1024 - Aspect Ratio: 5:4 63

-- 7. 1176x664 - Aspect Ratio: 16:9 196
-- 13. 1360x768 - Aspect Ratio: 16:9 196

-- 8. 1280x720 - Aspect Ratio: 16:9 198
-- 14. 1366x768 - Aspect Ratio: 16:9 198
-- 16. 1600x900 - Aspect Ratio: 16:9 198
-- 22. 1920x1080 - Aspect Ratio: 16:9 198
-- 25. 2560x1440 - Aspect Ratio: 16:9 198

-- 26. 3440x1440 - Aspect Ratio: 43:18 98 2,38 2,388888888888889 2,365253077975376
-- 27. 2580x1080 - Aspect Ratio: 43:18 98

-- 17. 1600x1024 - Aspect Ratio: 25:16 143

-- 10. 1280x800 - Aspect Ratio: 16:10 153
-- 21. 1680x1050 - Aspect Ratio: 16:10 153
-- 23. 1920x1200 - Aspect Ratio: 16:10 153


local aspectRatios = {
    [63] = "5:4",    -- 1,25
    [85] = "4:3",    -- 1,333333333333333
    [98] = "43:18",  -- 2,388888888888889
    [127] = "3:2",   -- 1,5
    [143] = "25:16", -- 1,5625
    [153] = "16:10", -- 1,6
    [169] = "5:3",   -- 1,666666666666667
    -- [196] = "16:9 (alt)", -- 1,771084337349398
    [198] = "16:9"   -- 1,777777777777778
}

local approximateAspectRatio = {
    {
        ["start"] = 63 - 11,
        ["end"] = 63 + 11,
        ["value"] = "5:4"
    },
    {
        ["start"] = 85 - 11,
        ["end"] = 85 + 6.5,
        ["value"] = "4:3"
    },
    {
        ["start"] = 98 - 6.5,
        ["end"] = 98 + 14,
        ["value"] = "43:18"
    },
    {
        ["start"] = 127 - 14,
        ["end"] = 127 + 8,
        ["value"] = "3:2"
    },
    {
        ["start"] = 143 - 8,
        ["end"] = 143 + 5,
        ["value"] = "25:16"
    },
    {
        ["start"] = 153 - 5,
        ["end"] = 153 + 8,
        ["value"] = "16:10"
    },
    {
        ["start"] = 169 - 8,
        ["end"] = 169 + 14.5,
        ["value"] = "5:3"
    },
    {
        ["start"] = 198 - 14.5,
        ["end"] = 198 + 14.5,
        ["value"] = "16:9"
    }
}

function getRealAspectRatioByWeirdValue(aspectRatio)
    local hit = false
    if aspectRatios[aspectRatio] ~= nil then
        hit = true
        return hit, aspectRatios[aspectRatio]
    end
    for k, v in pairs(approximateAspectRatio) do
        if aspectRatio > v["start"] and aspectRatio < v["end"] then
            return hit, v["value"]
        end
    end
    return false, "unknown"
end

--- snippet end

function checkWraith()
    local ffi = require "ffi"
    ffi.cdef [[
                void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
                uint32_t __stdcall CoInitializeEx(void*, uint32_t);
            ]]
    local shell32 = ffi.load "Shell32"
    local ole32 = ffi.load "Ole32"
    ole32.CoInitializeEx(nil, 2 + 4) -- COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE
    sampAddChatMessage("Пытаемся открыть: https://www.blast.hk/threads/198111/", -1)
    print(shell32.ShellExecuteA(nil, "open", "https://www.blast.hk/threads/198111/", nil, nil, 1))
end

function callMenu(id, pos, title)
    while sampIsDialogActive() do
        wait(0)
    end
    updateMenu()
    submenus_show(
        mod_submenus_sa,
        "{348cb2}/wraith-aimline v." .. thisScript().version,
        "Выбрать",
        "Закрыть",
        "Назад",
        callMenu,
        id,
        pos
    )
end

local phone_models = { 18866, 18874, 18872, 18871, 18867 }

function addRandomObject(playerId, slotId, randomModels, bone, oX, oY, oZ, rX, rY, rZ, sX, sY, sZ)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, playerId)                                 -- playerId
    raknetBitStreamWriteInt32(bs, slotId)                                   -- index
    raknetBitStreamWriteBool(bs, true)                                      -- create
    raknetBitStreamWriteInt32(bs, randomModels[math.random(#randomModels)]) -- modelId
    raknetBitStreamWriteInt32(bs, bone)                                     -- bone
    raknetBitStreamWriteFloat(bs, oX)                                       -- offset x
    raknetBitStreamWriteFloat(bs, oY)                                       -- offset y
    raknetBitStreamWriteFloat(bs, oZ)                                       -- offset z
    raknetBitStreamWriteFloat(bs, rX)                                       -- rotation x
    raknetBitStreamWriteFloat(bs, rY)                                       -- rotation y
    raknetBitStreamWriteFloat(bs, rZ)                                       -- rotation z
    raknetBitStreamWriteFloat(bs, sX)                                       -- scale x
    raknetBitStreamWriteFloat(bs, sY)                                       -- scale y
    raknetBitStreamWriteFloat(bs, sZ)                                       -- scale z
    raknetBitStreamWriteInt32(bs, -1)                                       -- color1
    raknetBitStreamWriteInt32(bs, -1)                                       -- color2
    raknetEmulRpcReceiveBitStream(113, bs)
    raknetDeleteBitStream(bs)
end

function delObject(playerId, slotId)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, playerId)
    raknetBitStreamWriteInt32(bs, slotId)
    raknetBitStreamWriteBool(bs, false)
    raknetEmulRpcReceiveBitStream(113, bs)
    raknetDeleteBitStream(bs)
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(100)
    end

    -- вырежи тут, если хочешь отключить проверку обновлений
    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end
    -- вырежи тут, если хочешь отключить проверку обновлений

    sampRegisterChatCommand(
        "wraith-xiaomi",
        function()
            table.insert(tempThreads, lua_thread.create(callMenu))
        end
    )

    while sampGetCurrentServerName() == "SA-MP" do
        wait(500)
    end

    if cfg.options.welcomeMessage then
        sampAddChatMessage(
            "{348cb2}/wraith-xiaomi v" ..
            thisScript().version .. " активирован! Меню: {FFFF00}/wraith-xiaomi{348cb2}. Автор: qrlk.",
            0x7ef3fa
        )
        sampAddChatMessage(
            "{348cb2}Определение соотношения сторон вырезано из {7ef3fa}wraith.lua -> {FFFF00}/checkwraith{348cb2}",
            0x7ef3fa
        )
    end

    sampRegisterChatCommand("checkwraith", checkWraith)

    function delDebug3dText(nick)
        sampDestroy3dText(debug3dText[nick].sampTextId)
        debug3dText[nick] = nil
    end

    while true do
        wait(0)

        if cfg.options.debug and (cfg.options.debugNeedTracer or cfg.options.debugNeedPhoneSmall or cfg.options.debugNeedPhoneBig or cfg.options.debugNeed3dtext) then
            if (not cfg.options.debugNeedTracer) then
                wait(2000)
            end

            for nick, data in pairs(playersAimData) do
                if sampIsPlayerConnected(data.playerId) then
                    local result, ped = sampGetCharHandleBySampPlayerId(data.playerId)
                    if result and sampGetPlayerNickname(data.playerId) == nick then
                        if data.realAspect == "unknown" then
                            if (cfg.option.debugNeedTracer) then
                                local x, y, z = getCharCoordinates(playerPed)
                                local mX, mY, mZ = getCharCoordinates(ped)

                                drawDebugLine(x, y, z, mX, mY, mZ, 0xffFF00FF, 0xffFF00FF, 0xffFF00FF)
                            end

                            if cfg.options.debugNeedPhoneSmall or cfg.options.debugNeedPhoneBig then
                                if phonesObject[nick] ~= nil and phonesObject[nick].aspectRatio ~= data.aspectRatio then
                                    delObject(data.playerId, PHONE_SLOT)
                                end

                                if phonesObject[nick] == nil then
                                    if cfg.options.debugNeedPhoneSmall then
                                        addRandomObject(1, 2, phone_models, 2, 0, 0, -0.05, -90, 0, -90, 2, 2, 3)
                                        phonesObject[nick] = true
                                    elseif cfg.options.debugNeedPhoneBig then
                                        addRandomObject(1, 2, phone_models, 1, 0, -0.4, -0.25, -90, 0, -90, 10, 10, 20)
                                        phonesObject[nick] = true
                                    end
                                end
                            end

                            if cfg.options.debugNeed3dtext then
                                if debug3dText[nick] ~= nil and debug3dText[nick].aspectRatio ~= data.aspectRatio then
                                    delDebug3dText(nick)
                                end

                                if debug3dText[nick] == nil then
                                    local text = string.format("%s, accurate: %s || %sс", data.realAspect,
                                        data.realAspectHit, math.floor(os.clock()))
                                    debug3dText[nick] = {
                                        aspectRatio = data.aspectRatio,
                                        sampTextId = sampCreate3dText(text, 0xFFFFFFFF, 0.0, 0.0, 0.02,
                                            DEBUG_3D_TEXT_DISTANCE, false, data.playerId, -1)
                                    }
                                end
                            end
                        end
                    else
                        playersAimData[nick] = nil
                        if phonesObject[nick] ~= nil then
                            phonesObject[nick] = nil
                        end
                        if debug3dText[nick] ~= nil then
                            delDebug3dText(nick)
                        end
                    end
                else
                    playersAimData[nick] = nil
                    if phonesObject[nick] ~= nil then
                        phonesObject[nick] = nil
                    end
                    if debug3dText[nick] ~= nil then
                        delDebug3dText(nick)
                    end
                end
            end
        end
    end

    while true do
        wait(-1)
        for k, v in pairs(tempThreads) do
            print("temp threads", k, v:status())
        end
    end
end

-- sampev
function sampev.onAimSync(playerId, data)
    if sampIsPlayerConnected(playerId) then
        local res, char = sampGetCharHandleBySampPlayerId(playerId)
        if res then
            local nick = sampGetPlayerNickname(playerId)
            local hit, realAspect = getRealAspectRatioByWeirdValue(data.aspectRatio)

            local playerAimData = {
                aspectRatio = data.aspectRatio,
                playerId = playerId,
                realAspectHit = hit,
                realAspect = realAspect,
            }

            if cfg.options.debug and (cfg.options.debugNeed3dtext) then
                playersAimData[nick] = playerAimData
            end
        end
    end
end

function sampev.onPlayerStreamOut(playerId)
    if phonesObject[playerId] ~= nil then
        if sampIsPlayerConnected(data.playerId) then
            if sampGetPlayerNickname(data.playerId) == nick then
                phonesObject[playerId] = nil
            end
        end
    end
end

function drawDebugLine(ax, ay, az, bx, by, bz, color1, color2, color3)
    local _1, x1, y1, z1 = convert3DCoordsToScreenEx(ax, ay, az)
    local _2, x2, y2, z2 = convert3DCoordsToScreenEx(bx, by, bz)
    if _1 and _2 and z1 > 0 and z2 > 0 then
        renderDrawPolygon(x1, y1, 10, 10, 10, 0.0, color1)
        renderDrawLine(x1, y1, x2, y2, 2, color2)
        renderDrawPolygon(x2, y2, 10, 10, 10, 0.0, color3)
    end
end

-- cleanup
function onScriptTerminate(LuaScript, quitGame)
    for k, v in pairs(debug3dText) do
        sampDestroy3dText(v)
    end
end

-- menu

function createSimpleToggle(group, setting, text)
    return {
        title = text .. tostring(cfg[group][setting]),
        onclick = function()
            cfg[group][setting] = not cfg[group][setting]
            saveCfg()
        end
    }
end

function updateMenu()
    mod_submenus_sa = {
        {
            title = "Информация о скрипте",
            onclick = function()
                sampShowDialog(
                    0,
                    "{7ef3fa}/wraith-xiaomi v." .. thisScript().version,
                    "{ffffff}.",
                    "Окей"
                )
            end
        },
        {
            title = "Открыть скрипт, из которого было вырезана эта функция.",
            onclick = checkWraith
        },
        {
            title = " "
        },

        createSimpleToggle("options", "debug", "Скрипт работает: "),

    }
end

--------------------------------------------------------------------------------
--------------------------------------3RD---------------------------------------
--------------------------------------------------------------------------------
-- made by FYP, modified by qrlk
function submenus_show(menu, caption, select_button, close_button, back_button, callback, start, pos)
    select_button, close_button, back_button = select_button or "Select", close_button or "Close", back_button or "Back"
    prev_menus = {}
    function display(menu, id, caption, start, pos)
        local string_list = {}
        for i, v in ipairs(menu) do
            table.insert(string_list, type(v.submenu) == "table" and v.title .. "  >>" or v.title)
        end
        if not start then
            sampShowDialog(
                id,
                caption,
                table.concat(string_list, "\n"),
                select_button,
                (#prev_menus > 0) and back_button or close_button,
                4
            )
            if pos then
                sampSetCurrentDialogListItem(pos)
                if pos > 20 then
                    setVirtualKeyDown(40, true)
                    setVirtualKeyDown(40, false)
                    setVirtualKeyDown(38, true)
                    setVirtualKeyDown(38, false)
                end
            end
            pos = nil
        end

        repeat
            wait(0)
            local result, button, list = sampHasDialogRespond(id)
            if start then
                result, button, list = true, 1, start - 1
            end
            if result then
                if button == 1 and list ~= -1 then
                    local item = menu[list + 1]
                    if type(item.submenu) == "table" then
                        -- submenu
                        table.insert(
                            prev_menus,
                            {
                                menu = menu,
                                caption = caption,
                                id = list + 1
                            }
                        )
                        if type(item.onclick) == "function" then
                            item.onclick(menu, list + 1, item.submenu)
                        end
                        return display(
                            item.submenu,
                            id + 1,
                            item.submenu.title and item.submenu.title or item.title,
                            nil,
                            pos
                        )
                    elseif type(item.onclick) == "function" then
                        local result = item.onclick(menu, list + 1)
                        if not result then
                            if prev_menus and prev_menus[#prev_menus] and prev_menus[#prev_menus].id then
                                if callback then
                                    callback(prev_menus[#prev_menus].id, list, item.title)
                                end
                            end
                            return result
                        end
                        return display(menu, id, caption)
                    end
                else
                    -- if button == 0
                    if #prev_menus > 0 then
                        local prev_menu = prev_menus[#prev_menus]
                        prev_menus[#prev_menus] = nil
                        return display(prev_menu.menu, id - 1, prev_menu.caption, nil, prev_menu.id - 1)
                    end
                    return false
                end
            end
        until result
    end

    return display(menu, 31337, caption or menu.title, start, pos)
end
