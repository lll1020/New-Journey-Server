lualib = lualib or {}
local config = include("QuestDiary/cfg_gm_box.lua")
function lualib:checkPwd(actor)
    local zhid = tonumber(getconst(actor,"<$USERACCOUNT>"))
    if constant.pz_htqx[zhid] or getconst(actor, '<$SERVERNAME>') == "" or getconst(actor, '<$SERVERNAME>') == "测试区" then
        if getconst(actor, '<$SERVERNAME>') == "" then
            return true
        else
            return true
        end
    end
    return false
end

function lualib:playerIsGm(actor)
    --local result = false
    --local accountID = getconst(actor, "<$USERACCOUNT>")
    --local isAdmin = checktextlist('..\\QuestDiary\\accountid\\adminuserid.txt', accountID)
    --if isAdmin == true then
    --end
    --return result
    return true
end

function lualib:sendmsg(actor, str)
    sendmsg(actor, 1, string.format('{"Msg":"<font color=\'#D2B48C\'>[GM]%s</font>","Type":9}', str))
    sendmsg(actor, 1, string.format('{"Msg":"<font color=\'#D2B48C\'>[GM]%s</font>","Type":1}', str))
end

--获取玩家对象
function lualib:getplayerbyname(actor, name)
    local player = getplayerbyname(name)
    -- release_print("GM获取玩家的对象:"..player)
    if not player or player == "" or player == "0" or not isnotnull(player) then
        player = false
        lualib:sendmsg(actor, "玩家不存在")
    end
    return player
end

-- ==================================================================================
-- ==================================================================================
-- =====================================//系统//=====================================
-- ==================================================================================
-- ==================================================================================
local function split_long_string_gbk(str)
    local max_length = 6000
    local result = {}
    local str_length = #str
    local index = 1
    local chunk_start = 1
    local chunk_size = 0

    while index <= str_length do
        local byte = string.byte(str, index)
        local char_len = 1

        if byte >= 0x81 and byte <= 0xFE then
            -- 可能是双字节字符的第一个字节
            if index + 1 <= str_length then
                local next_byte = string.byte(str, index + 1)
                if (next_byte >= 0x40 and next_byte <= 0xFE and next_byte ~= 0x7F) then
                    -- 有效的双字节字符，长度为2
                    char_len = 2
                end
            end
        end

        -- 如果添加当前字符后超过了最大长度，先保存之前的内容
        if chunk_size + char_len > max_length then
            local chunk = string.sub(str, chunk_start, index - 1)
            table.insert(result, chunk)
            chunk_start = index
            chunk_size = 0
        end

        chunk_size = chunk_size + char_len
        index = index + char_len
    end
    -- 添加最后一段
    if chunk_start <= str_length then
        local chunk = string.sub(str, chunk_start, str_length)
        table.insert(result, chunk)
    end

    return result
end
--获取系统变量 gm_getsysvar
---@param param1 string 变量名
function usercmd1(actor, param1)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    lualib:sendmsg(actor, string.format("获取 %s变量 : %s", param1, getsysvar(param1)))
end

--设置系统变量 gm_setsysvar
---@param param1 string 变量名
---@param param2 string|number 变量值
---@param param3 string 变量值类型
function usercmd2(actor, param1, param2, param3)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    param2 = tonumber(param2) or param2
    if param3 == "integer" then
        param2 = tonumber(param2) or 0
    end
    local var = getsysvar(param1)
    setsysvar(param1, param2)
    lualib:sendmsg(actor, string.format("修改 %s变量 : %s → %s", param1, param2, var, getsysvar(param1)))
end

--声明系统自定义变量 gm_inisysvarex
---@param param1 string 变量名
---@param param2 string 变量值类型
function usercmd3(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    inisysvar(param2, param1, 0)
    lualib:sendmsg(actor, string.format("声明系统自定义变量,%s - %s", param1, param2))
end

--获取系统自定义变量 gm_getsysvarex
---@param param1 string 变量名
function usercmd4(actor, param1)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    lualib:sendmsg(actor, param1 .. ":" .. getsysvarex(param1))
end

--设置系统自定义变量 gm_setsysvarex
---@param param1 string 变量名
---@param param2 string|number 变量值
---@param param3 string 变量值类型
---@param param4 number 是否保存数据库
function usercmd5(actor, param1, param2, param3, param4)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    if param3 == "integer" then
        param2 = tonumber(param2) or 0
    end
    param4 = tonumber(param4) or 0
    local var = getsysvarex(param1)
    setsysvarex(param1, param2, param4)
    lualib:sendmsg(actor, string.format("修改 %s变量 : %s → %s", param1, param2, var, getsysvarex(param1)))
end

--设置系统自定义变量 gm_setsysvarex
---@param param1 string 变量名
---@param param2 string|number 变量值
---@param param3 string 变量值类型
---@param param4 number 是否保存数据库
function usercmd5(actor, param1, param2, param3, param4)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    if param3 == "integer" then
        param2 = tonumber(param2) or 0
    end
    param4 = tonumber(param4) or 0
    local var = getsysvarex(param1)
    setsysvarex(param1, param2, param4)
    lualib:sendmsg(actor, string.format("修改 %s变量 : %s → %s", param1, param2, var, getsysvarex(param1)))
end

--请求一条来自服务端的消息 gm_sendluamsg
---@param param1 number 消息号
---@param param2 number 参数1
---@param param3 number 参数2
---@param param4 number 参数3
---@param param5 string 参数3
function usercmd6(actor, param1, param2, param3, param4, param5)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    param1 = tonumber(param1) or 0
    setgmlevel(actor,param1)
    Player.sendmsgEx(actor,"设置成功,当前权限|".. param1.."#249")
end

function open_gm_admin(actor)
    local password = getconst(actor, "<$NPCINPUT(2)>")
    if password == ConstCfg.adminPassword then
        setplaydef(actor, VarCfg["S$记录后台密码"], password)
        local chunks = split_long_string_gbk(tbl2json(config))
        for i, chunk in ipairs(chunks) do
            Message.sendmsg(actor, ssrNetMsgCfg.GMBox_OpenUI, #chunks, 0, 0, { chunk })
        end
        close(actor)
    end
end

-- 打开一个文本框 gm_openbox
function usercmd8(actor)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local chunks = split_long_string_gbk(tbl2json(config))
    for i, chunk in ipairs(chunks) do
        sendluamsg(actor, 6000, #chunks, 0, 0, tbl2json(chunk))
    end
    return
end

function inputstring31(actor)
    local GmLevel =  getgmlevel(actor)
    if GmLevel ~= 10 then return end
    local  player_name =  getplaydef(actor, "S31")
    setplaydef(actor, VarCfg["S$字符串玩家名字"],player_name)
    usercmd9(actor)
end

function inputstring32(actor)
    local GmLevel =  getgmlevel(actor)
    if GmLevel ~= 10 then return end
    local  var_name =  getplaydef(actor, "S32")
    setplaydef(actor, VarCfg["S$字符串变量名字"],var_name)
    usercmd9(actor)
end

function inputstring33(actor)
    local GmLevel =  getgmlevel(actor)
    if GmLevel ~= 10 then return end
    local  var_name =  getplaydef(actor, "S33")
    setplaydef(actor, VarCfg["S$字符串变量内容"],var_name)
    usercmd9(actor)
end

function zhixingxiugaibianliang(actor,player_name,var_name,var_str)
    local GmLevel =  getgmlevel(actor)
    if GmLevel ~= 10 then return end
    local player = getplayerbyname(player_name)
    if not player or player == "" or player == "0" or not isnotnull(player) then
        player = false
        lualib:sendmsg(actor, "玩家不存在")
    end
    local Tbl= Player.getJsonTableByVar(actor, var_name)

    if not Tbl[var_str] then
        lualib:sendmsg(actor, var_str.."不存在---设置为可领取")
    elseif  Tbl[var_str] then
        lualib:sendmsg(actor, var_str.."不存在---设置为可领取")
    end
    Tbl[var_str]  = "可领取"
    Player.setJsonVarByTable(actor, var_name, Tbl)
end

-- mircopy(actor, getplaydef(player, param2))
-- Player.sendmsgEx(actor,"T变量自动复制到剪切板")
-- ==================================================================================
-- ==================================================================================
-- =====================================//玩家//=====================================
-- ==================================================================================
-- ==================================================================================
---@param str string
---@return any
local function extract_number_from_brackets(str)
    -- 检查字符串是否匹配模式 [数字]
    local number_str = str:match("^%[(%d+)%]$")
    if number_str then
        -- 将数字字符串转换为数值类型（可选）
        local number = tonumber(number_str)
        return number -- 如果您需要返回字符串类型，可以返回 number_str
    else
        return false
    end
end
--获取玩家变量 gm_getplayvar
---@param param1 string 玩家名
---@param param2 string 变量名
function usercmd1001(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        local flag = extract_number_from_brackets(param2)
        if flag then
            lualib:sendmsg(actor, string.format("%s 获取 %s个人标识 : %s", param1, param2, getflagstatus(player, flag)))
        else
            
            lualib:sendmsg(actor, string.format("%s 获取 %s变量 : %s", param1, param2, getplaydef(player, param2)))
            if string.find(param2,"T") or string.find(param2,"t") then
                mircopy(actor, getplaydef(player, param2))
                Player.sendmsgEx(actor,"T变量自动复制到剪切板")
            end
        end
    end
end

--设置玩家变量 gm_setplayvar
---@param param1 string 玩家名
---@param param2 string 变量名
---@param param3 string|number 变量值
---@param param4 string 变量值类型
function usercmd1002(actor, param1, param2, param3, param4)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        local flag = extract_number_from_brackets(param2)
        if flag then
            if param3 ~= "0" and param3 ~= "1" then
                lualib:sendmsg(actor, "修改个人表示变量值只能输入0或1")
                return
            end
            param3 = tonumber(param3) or 0
            local var = getflagstatus(player, flag)
            setflagstatus(player, flag, param3)
            lualib:sendmsg(actor, string.format("%s 修改 %s个人标识 : %s → %s", param1, param2, var, getflagstatus(player, flag)))
        else
            if param4 == "integer" then
                param3 = tonumber(param3) or 0
            end
            local var = getplaydef(player, param2)
            setplaydef(player, param2, param3)
            lualib:sendmsg(actor, string.format("%s 修改 %s变量 : %s → %s", param1, param2, var, getplaydef(player, param2)))
        end
    end
end

--获取玩家自定义变量 gm_getplayvarex
---@param param1 string 玩家名
---@param param2 string 变量名
function usercmd1003(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        lualib:sendmsg(actor,
            string.format("%s 获取 %s变量 : %s", param1, param2, getplayvar(player, "HUMAN", param2) or "获取失败(未声明)"))
    end
end

--设置玩家自定义变量 gm_setplayvarex
---@param param1 string 玩家名
---@param param2 string 变量名
---@param param3 string|number 变量值
---@param param4 string 变量值类型
---@param param5 number 是否保存数据库
function usercmd1004(actor, param1, param2, param3, param4, param5)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        if param4 == "integer" then
            param3 = tonumber(param3) or 0
        end
        param5 = tonumber(param5) or 0
        local var = getplayvar(player, "HUMAN", param2)
        iniplayvar(player, param4, "HUMAN", param2)
        setplayvar(player, "HUMAN", param2, param3, param5)
        lualib:sendmsg(actor, string.format("%s 修改 %s变量 : %s → %s", param1, param2, var,
            getplayvar(player, "HUMAN", param2)))
    end
end

-- 跳转到玩家附近 gm_jumptoplay
---@param param1 string 玩家名
function usercmd1005(actor, param1)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        local map, x, y = getbaseinfo(player, 3), getbaseinfo(player, 4), getbaseinfo(player, 5)
        mapmove(actor, map, x, y, 5)
        lualib:sendmsg(actor, string.format("跳转到 %s [%s,%s]", map, x, y))
    end
end

-- 拉玩家到身边 gm_bringplay
---@param param1 string 玩家名
function usercmd1006(actor, param1)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        local map, x, y = getbaseinfo(actor, 3), getbaseinfo(actor, 4), getbaseinfo(actor, 5)
        mapmove(player, map, x, y, 5)
        lualib:sendmsg(actor, string.format("拉人到 %s [%s,%s]", map, x, y))
    end
end

-- 发送背包道具 gm_giveitem
---@param param1 string 玩家名
---@param param2 string 物品名称
---@param param3 number 数量
---@param param4 number 规则
function usercmd1007(actor, param1, param2, param3, param4)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        param3 = tonumber(param3) or 1
        param4 = tonumber(param4) or 0
        -- if giveitem(player,param2,param3,param4) then
        sendmail("#" .. param1, 10, "物品补发", "请领取您的物品", string.format("%s#%d#%d", param2, param3, param4))
        lualib:sendmsg(actor, string.format("发送物品到邮件 %s → %s", param2, param1))
    end
end

-- 查找背包道具 gm_finditem
---@param param1 string 玩家名
---@param param2 string 物品名称
function usercmd1008(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        lualib:sendmsg(actor, string.format("%s 拥有 %s * %s", param1, param2, getbagitemcount(player, param2) or 0))
    end
end

-- 检测玩家称号 gm_checktitle
---@param param1 string 玩家名
---@param param2 string 称号名称
function usercmd1009(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        lualib:sendmsg(actor, string.format("%s-%s-%s称号", param1, checktitle(player, param2) and "拥有" or "没有", param2))
    end
end

-- 添加玩家称号 gm_addtitle
---@param param1 string 玩家名
---@param param2 string 称号名称
---@param param3 number 是否激活
function usercmd1010(actor, param1, param2, param3)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        param3 = tonumber(param3) or 0
        if confertitle(player, param2, param3) then
            Player.setAttList(actor, "属性附加")
            lualib:sendmsg(actor, "称号添加成功")
        else
            lualib:sendmsg(actor, "称号添加失败")
        end
    end
end

-- 删除玩家称号 gm_deltitle
---@param param1 string 玩家名
---@param param2 string 称号名称
function usercmd1011(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        if deprivetitle(player, param2) then
            lualib:sendmsg(actor, "称号删除成功")
        else
            lualib:sendmsg(actor, "称号删除失败")
        end
    end
end

-- 检测玩家BUFF gm_checkbuff
---@param param1 string 玩家名
---@param param2 number buffID
function usercmd1012(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        param2 = tonumber(param2) or 0
        if param2 < 10000 then
            lualib:sendmsg(actor, "buffid需大于10000")
            return
        end
        lualib:sendmsg(actor, string.format("%s-%s-%sBUFF", param1, hasbuff(player, param2) and "拥有" or "没有", param2))
    end
end

-- 添加玩家BUFF gm_addbuff
---@param param1 string 玩家名
---@param param2 number buffID
---@param param3 number 时间
function usercmd1013(actor, param1, param2, param3)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        param2 = tonumber(param2) or 0
        param3 = tonumber(param3) or 0
        if param2 < 10000 then
            lualib:sendmsg(actor, "buffid需大于10000")
            return
        end
        if addbuff(player, param2, param3) then
            lualib:sendmsg(actor, "buff添加成功")
        else
            lualib:sendmsg(actor, "buff添加失败")
        end
    end
end

-- 添加玩家BUFF2 gm_addbuffex
---@param param1 string 玩家名
---@param param2 number buffID
---@param param3 number 时间
---@param param4 number 层数
---@param param5 string 释放者
---@param param6 string 额外属性[1#10|4#20]
function usercmd1014(actor, param1, param2, param3, param4, param5, param6)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        param2 = tonumber(param2) or 0
        param3 = tonumber(param3) or 0
        param4 = tonumber(param4) or 0
        local hiter = lualib:getplayerbyname(actor, param5) or player
        if param2 < 10000 then
            lualib:sendmsg(actor, "buffid需大于10000")
            return
        end
        local attr = {}
        for k, v in string.gmatch(param6, "([^#]+)#([^|]+)") do
            attr[tonumber(k)] = tonumber(v)
        end
        -- LOGPrint("attr",tbl2json(attr))
        if addbuff(player, param2, param3, param4, hiter, attr) then
            lualib:sendmsg(actor, "buff添加成功")
        else
            lualib:sendmsg(actor, "buff添加失败")
        end
    end
end

-- 删除玩家BUFF gm_delbuff
---@param param1 string 玩家名
---@param param2 number buffID
function usercmd1015(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        if delbuff(player, param2) then
            lualib:sendmsg(actor, "buff删除成功")
        else
            lualib:sendmsg(actor, "buff删除失败")
        end
    end
end
-- 给货币
---@param param1 string 玩家名
---@param param2 string 货币名字
---@param param3 number 数量
function usercmd1016(actor, param1, param2, param3)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        local moneyIdx = getstditeminfo(param2, 0)
        if moneyIdx == 0 then
            lualib:sendmsg(actor, param2.." 货币不存在")
        else
            param3 = tonumber(param3) or 1
            if changemoney(player, moneyIdx, "+", param3, "客服后台补发", true) then
                lualib:sendmsg(actor, string.format("发送玩家%s的%s数量为:%s", param1, param2, param3))
            else
                lualib:sendmsg(actor, "补发货币失败")
            end
        end
    end
end

-- 查询货币
---@param param1 string 玩家名
---@param param2 string 货币名字
function usercmd1017(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        local moneyIdx = getstditeminfo(param2, 0)
        if moneyIdx == 0 then
            lualib:sendmsg(actor, param2.." 货币不存在")
        else
            local num = querymoney(player, moneyIdx)
            lualib:sendmsg(actor, string.format("%s的%s数量为:%s", param1, param2, num))
        end
    end
end

-- 拿走货币
---@param param1 string 玩家名
---@param param2 string 货币名字
---@param param3 number 数量
function usercmd1018(actor, param1, param2, param3)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        local moneyIdx = getstditeminfo(param2, 0)
        if moneyIdx == 0 then
            lualib:sendmsg(actor, param2.." 货币不存在")
        else
            param3 = tonumber(param3) or 1
            if changemoney(player, moneyIdx, "-", param3, "客服后台扣除", true) then
                lualib:sendmsg(actor, string.format("扣除玩家%s的%s数量为:%s", param1, param2, param3))
            else
                lualib:sendmsg(actor, "扣除货币失败")
            end
        end
    end
end
-- 拿走物品
---@param param1 string 玩家名
---@param param2 string 物品名
---@param param3 number 数量
---@param param4 number 绑定物品
function usercmd1019(actor, param1, param2, param3, param4)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        param3 = tonumber(param3) or 1
        param4 = tonumber(param4) or 0
        if takeitemex(player, param2, param3, param4, "客服后台扣除") then
            lualib:sendmsg(actor, string.format("拿走玩家%s的%s 数量为:%s", param1, param2, param3))
        else
            lualib:sendmsg(actor, "拿走物品失败!")
        end
    end
end

--补发充值
---@param param1 string 玩家名
---@param param2 number 充值金额
---@param param3 string 货币名
---@param param4 number 货币数量
function usercmd1020(actor, param1, param2, param3, param4, param5)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        param2 = tonumber(param2) or 0
        param4 = tonumber(param4) or 0
        param5 = tonumber(param5) or 0
        local moneyIdx = getstditeminfo(param3, 0)
        if moneyIdx == 0 then
            lualib:sendmsg(actor, param3.." 货币不存在")
        else
            if param2 == 0 then
                lualib:sendmsg(actor, "金额不能是0!")
            else
                changemoney(player, moneyIdx, "+", param4, "客服充值补发", true)
                if param5 == 0 then
                    setplaydef(player, "N$不计入双节累充", 1)
                end
                recharge(player, param2, 1, moneyIdx)
                lualib:sendmsg(actor, "给玩家:".. param1.."补发充值金额:"..param2)
            end
        end
        
    end
end

-- ==================================================================================
-- ==================================================================================
-- =====================================//地图//=====================================
-- ==================================================================================
-- ==================================================================================

-- 跳转地图 @gm_mapmove
---@param param1 string 地图号
---@param param2 number X
---@param param3 number Y
function usercmd2001(actor, param1, param2, param3)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    param2 = tonumber(param2) or 0
    param3 = tonumber(param3) or 0
    mapmove(actor, param1, param2, param3)
    lualib:sendmsg(actor, "地图跳转")
    sendluamsg(actor, 996, 1, 2, 3, "asss")
end

-- 全屏清怪(10*10) gm_killmon1
---@param param1 string 怪物名(`*`全清)
---@param param2 string 是否掉落
function usercmd2002(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local bool = param2 == "1" and true or false
    local map, x, y = getbaseinfo(actor, 3), getbaseinfo(actor, 4), getbaseinfo(actor, 5)
    local mons = getmapmon(map, param1, x, y, 10)
    for i, mon in ipairs(mons or {}) do
        killmonbyobj(actor, mon, bool, bool, bool)
        lualib:sendmsg(actor, "全屏清怪")
    end
end

-- 地图清怪 gm_killmon2
---@param param1 string 怪物名(`*`全清)
---@param param2 string 是否掉落
function usercmd2003(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local bool = param2 == "1" and true or false
    local map = getbaseinfo(actor, 3)
    killmonsters(map, param1, 0, bool)
    lualib:sendmsg(actor, "地图清怪")
end

-- 查询当前地图怪物 "@gm_selectmon 怪物名称"
---@param param1 string 怪物名(`*`全部查询)
function usercmd2004(actor, param1)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local map = getbaseinfo(actor, 3)
    local mons = getmapmon(map, param1, 0, 0, 999)
    for i, mon in ipairs(mons or {}) do
        lualib:sendmsg(actor, string.format("mon,%s - [%s,%s]", getbaseinfo(mon, 1), getbaseinfo(mon, 4),
            getbaseinfo(mon, 5)))
    end
end

-- 查询当前地图玩家 "@gm_selectplay"
function usercmd2005(actor)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local map = getbaseinfo(actor, 3)
    local player_list = getplaycount(map, true, true)
    for i, player in ipairs(player_list or {}) do
        lualib:sendmsg(actor,
            string.format("player,%s - [%s,%s]", getbaseinfo(player, 1), getbaseinfo(player, 4), getbaseinfo(player, 5)))
    end
end

-- 转移当前地图玩家 "@gm_moveplayers 目标地图号 X Y"
---@param param1 string 地图号
---@param param2 number X
---@param param3 number Y
function usercmd2006(actor, param1, param2, param3)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    param2 = tonumber(param2) or 0
    param3 = tonumber(param3) or 0
    local players = getplaycount(param1, true, true)
    for _, player in ipairs(type(players) == "table" and players or {}) do
        -- if player ~= actor then
        mapmove(player, param1, param2, param3)
        -- end
    end
    lualib:sendmsg(actor, "地图转移玩家")
end

-- ==================================================================================
-- ==================================================================================
-- =====================================//道具//=====================================
-- ==================================================================================
-- ==================================================================================


-- function usercmd3001(actor,param1)
-- end

-- ==================================================================================
-- ==================================================================================
-- =====================================//NPC//======================================
-- ==================================================================================
-- ==================================================================================

-- 刷npc gm_createnpc
---@param param1 string 地图号
---@param param2 number X
---@param param3 number Y
---@param param4 number npcID
---@param param5 string npc名称
---@param param6 number 外形[appr]
---@param param7 string 脚本路径[script]
function usercmd4001(actor, param1, param2, param3, param4, param5, param6, param7)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    param2 = tonumber(param2) or 0
    param3 = tonumber(param3) or 0
    param4 = tonumber(param4) or 0
    param6 = tonumber(param6) or 0

    local npcInfo = {}
    npcInfo.Idx = param4
    npcInfo.npcname = param5
    npcInfo.appr = param6
    npcInfo.script = param7
    createnpc(param1, param2, param3, tbl2json(npcInfo))
    lualib:sendmsg(actor, "创建临时npc")
end

-- ==================================================================================
-- ==================================================================================
-- =====================================//怪物//=====================================
-- ==================================================================================
-- ==================================================================================

-- 刷怪 gm_genmon
---@param param1 string 地图号
---@param param2 number X
---@param param3 number Y
---@param param4 string 怪物名称
---@param param5 number 范围
---@param param6 number 数量
---@param param7 number 颜色
function usercmd5001(actor, param1, param2, param3, param4, param5, param6, param7)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    param2 = tonumber(param2) or 0
    param3 = tonumber(param3) or 0
    param5 = tonumber(param5) or 5
    param6 = tonumber(param6) or 1
    param7 = tonumber(param7) or 0
    genmon(param1, param2, param3, param4, param5, param6, param7)
    lualib:sendmsg(actor, string.format("成功刷怪 %s * %s", param4, param6))
end

-- ==================================================================================
-- ==================================================================================
-- =====================================//行会//=====================================
-- ==================================================================================
-- ==================================================================================

-- 加入行会 "@gm_addguild 玩家名称 行会名称"
---@param param1 string 玩家名
---@param param2 string 行会名称
function usercmd6001(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        local guild = getmyguild(actor)
        if guild == "0" then
            addguildmember(player, param2)
            lualib:sendmsg(actor, string.format("%s加入%s", param1, param2))
        else
            lualib:sendmsg(actor, string.format("玩家%s已经加入行会:", param1, getguildinfo(guild, 1)))
        end
    end
end

-- 退出行会 "@gm_delguild 玩家名称"
function usercmd6002(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        local guild = getmyguild(actor)
        if guild ~= "0" then
            delguildmember(player, param2)
            lualib:sendmsg(actor, string.format("%s加入%s", param1, param2))
        else
            lualib:sendmsg(actor, string.format("玩家%s没有加入行会", param1))
        end
    end
end

-- 设置行会职务 "@gm_setguildlv 玩家名称 行会职务"
function usercmd6003(actor, param1, param2)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    local player = lualib:getplayerbyname(actor, param1)
    if player then
        param2 = tonumber(param2) or 5
        local lv = getplayguildlevel(player)
        if lv ~= param2 and setplayguildlevel(player, param2) then
            lualib:sendmsg(actor, string.format("设置%s行会职务 %s → %s", lv, param2))
        else
            lualib:sendmsg(actor, string.format("%职务设置失败%s", param1, param2))
        end
    end
end

-- ==================================================================================
-- ==================================================================================
-- =====================================//沙巴克//===================================
-- ==================================================================================
-- ==================================================================================

-- 获取沙巴克基本信息 "@gm_castleinfo 信息索引"
function usercmd7001(actor, param1)
    --if not lualib:playerIsGm(actor) then return end
    if not lualib:checkPwd(actor) then return end
    param1 = tonumber(param1) or 1
    local config = {
        [1] = "沙城名称",
        [2] = "沙城行会名称",
        [3] = "沙城行会会长名字",
        [4] = "占领天数",
        [5] = "当前是否在攻沙状态",
        [6] = "沙城行会副会长"
    }
    if not config[param1] then return lualib:sendmsg(actor, "未知索引") end
    local value = castleinfo(param1)
    if type(value) == "table" then
        for i, name in ipairs(t) do
            lualib:sendmsg(actor, string.format("%s[%s] - %s", config[param1], i, name))
        end
    else
        lualib:sendmsg(actor, string.format("%s - %s", config[param1], value))
    end
end
