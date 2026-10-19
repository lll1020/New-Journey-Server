local npc = {}

local NPC_ID = 1033
local MIN_TRANSFER = 500
local OLD_SERVER_DAYS = 3
local LOCK_VAR = "N$ZQ1033Locked"
local REAL_RECHARGE_VAR = VarCfg["U_真实充值"] or "U225"
local ORIGIN_ACCOUNT_VAR = VarCfg.T_transfer_origin_account or "T75"
local TRANSFER_FILE = "..\\QuestDiary\\转区记录.txt"
local TRANSFER_FILE_NAME = "转区记录.txt"

local function _debug(stage, detail)
    if type(release_print) == "function" then
        release_print("[NPC1033_DEBUG]", stage, tostring(detail or ""))
    end
end

local function _sync_transfer_file()
    _debug("step.sync.before", "name=" .. TRANSFER_FILE_NAME)
    local ok, err = pcall(updatetongfile, TRANSFER_FILE_NAME)
    _debug("step.sync.after", "ok=" .. tostring(ok) .. ",return=" .. tostring(err))
    return ok
end

local function _int(value)
    return math.max(0, math.floor(tonumber(value) or 0))
end

local function _account(play)
    local account = tostring(getconst(play, "<$USERACCOUNT>") or "")
    if account == "" or account:find("|", 1, true) or account:find("@", 1, true)
        or account:find("/", 1, true) or account:find("\\", 1, true)
        or account:find("\n", 1, true) or account:find("\r", 1, true) then
        return nil
    end
    return account
end

local function _recharge(play)
    return _int(getplaydef(play, REAL_RECHARGE_VAR))
end

local function _open_days()
    local var_name = VarCfg["G_开区天数"] or "G0"
    local raw_value = getsysvar(var_name)
    _debug("server_days", "var=" .. tostring(var_name) .. ",raw=" .. tostring(raw_value)
        .. ",type=" .. type(raw_value))
    return _int(raw_value)
end

local function _is_old_server()
    return _open_days() >= OLD_SERVER_DAYS
end

local function _origin_account(play)
    return tostring(getplaydef(play, ORIGIN_ACCOUNT_VAR) or "")
end

local function _find_account_line(account)
    local key = "@" .. account .. "|"
    for line = 0, 1000 do
        local ok, raw = pcall(getrandomtext, TRANSFER_FILE, line)
        if not ok or raw == nil or tostring(raw) == "" then
            if line > 0 then break end
        elseif tostring(raw):sub(1, #key) == key then
            return line, tostring(raw)
        end
    end
    return nil, nil
end

local function _parse_record(raw, account)
    local values = {}
    for value in (tostring(raw or "") .. "|"):gmatch("(.-)|") do
        values[#values + 1] = value
        if #values >= 5 then break end
    end
    if #values < 5 or values[1] ~= "@" .. account then return nil end
    return {
        exported = _int(values[2]),
        remaining = _int(values[3]),
        claimed = _int(values[4]),
        applied = _int(values[5]),
    }, values
end

local function _read_account_state(play)
    local account = _account(play)
    if not account then
        _debug("read.account", "invalid")
        return nil
    end
    _debug("step.read_sync.before", TRANSFER_FILE_NAME)
    local sync_ok, sync_err = pcall(updatetongfile, TRANSFER_FILE_NAME)
    _debug("step.read_sync.after", "ok=" .. tostring(sync_ok) .. ",return=" .. tostring(sync_err))
    if not sync_ok then return nil end
    _debug("step.tong_create.before", "name=" .. TRANSFER_FILE_NAME .. ",model=0")
    local create_ok, create_err = pcall(tongfile, 0, TRANSFER_FILE_NAME)
    _debug("step.tong_create.after", "ok=" .. tostring(create_ok) .. ",return=" .. tostring(create_err))
    _debug("step.read_search.before", "path=" .. TRANSFER_FILE .. ",key=@" .. account .. "|")
    local line, raw = _find_account_line(account)
    _debug("step.read_search.after", "line=" .. tostring(line) .. ",raw=" .. tostring(raw))
    if line ~= nil then
        _debug("step.read_line", "raw=" .. tostring(raw))
        local state, values = _parse_record(raw, account)
        if state then
            _debug("step.read_fields", table.concat(values, "|"))
            return state, line, account
        end
        return nil
    end
    return {
        exported = 0,
        remaining = 0,
        claimed = 0,
        applied = 0,
    }, nil, account
end

local function _save_account_state(line, account, state)
    if not account then return false end
    local record = string.format("@%s|%d|%d|%d|%d", account, _int(state.exported), _int(state.remaining), _int(state.claimed), _int(state.applied))
    local ok, write_result
    if line == nil then
        _debug("step.write.before", "path=" .. TRANSFER_FILE .. ",line=0,api=addtextlist,record=" .. record)
        ok, write_result = pcall(addtextlist, TRANSFER_FILE, record, 0)
    else
        _debug("step.write.before", "path=" .. TRANSFER_FILE .. ",line=" .. tostring(line) .. ",api=addtextlist,record=" .. record)
        ok, write_result = pcall(addtextlist, TRANSFER_FILE, record, line)
    end
    _debug("step.write.after", "ok=" .. tostring(ok) .. ",return=" .. tostring(write_result))
    if not ok then return false end

    _debug("step.verify_search.before", "path=" .. TRANSFER_FILE .. ",key=@" .. account .. "|")
    local saved_line, saved_raw = _find_account_line(account)
    _debug("step.verify_search.after", "line=" .. tostring(saved_line) .. ",raw=" .. tostring(saved_raw))
    if saved_line == nil then return false end

    local _, saved_raw = _find_account_line(account)
    _debug("step.verify_line", "raw=" .. tostring(saved_raw))
    local verified_state, values = _parse_record(saved_raw, account)
    local verified = verified_state ~= nil
        and values[1] == "@" .. account
        and _int(values[2]) == _int(state.exported)
        and _int(values[3]) == _int(state.remaining)
        and _int(values[4]) == _int(state.claimed)
        and _int(values[5]) == _int(state.applied)
    _debug("write.verify_record", "ok=" .. tostring(verified))
    return verified
end

function npc.addTransferAmount(target, amount)
    amount = _int(amount)
    if not target or amount <= 0 then
        return false, "玩家或转区金额无效"
    end
    if not _sync_transfer_file() then
        return false, "转区文件同步失败"
    end

    local state, line, account = _read_account_state(target)
    if not state or not account then
        return false, "无法读取目标玩家账号的转区记录"
    end
    state.exported = _int(state.exported) + amount
    state.remaining = _int(state.remaining) + amount
    state.applied = 1
    if not _save_account_state(line, account, state) then
        return false, "转区金额写入后校验失败"
    end
    return true, state.remaining, account
end

local function _claimable(play, state)
    local claimed = _int(state.claimed)
    return math.min(_int(state.remaining), math.max(0, _recharge(play) - claimed * 2))
end

local function _payload(play, result)
    local state = _read_account_state(play) or {}
    local recharge = _recharge(play)
    local claimed = _int(state.claimed)
    return {
        real_recharge = recharge,
        exported = _int(state.exported),
        remaining = _int(state.remaining),
        claimed = claimed,
        claimable = _claimable(play, state),
        locked = _int(getplaydef(play, LOCK_VAR)),
        minimum = MIN_TRANSFER,
        open_days = _open_days(),
        old_server_days = OLD_SERVER_DAYS,
        is_old_server = _is_old_server() and 1 or 0,
        result = result or "",
    }
end

local function _send(play, result)
    _debug("send.begin", result)
    local ok, payload = pcall(_payload, play, result)
    if not ok then
        _debug("send.payload_error", payload)
        return
    end
    local json_ok, json = pcall(tbl2json, payload)
    if not json_ok then
        _debug("send.json_error", json)
        return
    end
    local send_ok, send_err = pcall(sendluamsg, play, 100, NPC_ID, 1, 0, json)
    _debug("send.done", "ok=" .. tostring(send_ok) .. ",result=" .. tostring(send_err))
end

local function _require_transfer_sync(play)
    if _sync_transfer_file() then return true end
    local message = "转区数据同步失败，请稍后重试。"
    Player.sendmsgEx(play, message .. "#57")
    _send(play, message)
    return false
end

local function _ban_transferred_character(play)
    local role_name = tostring(getbaseinfo(play, ConstCfg.gbase.name) or getbaseinfo(play, 1) or "")
    if role_name == "" then
        _debug("ban.error", "empty role name")
        return false
    end

    setgmlevel(play, 10)
    local ok, err = pcall(gmexecute, play, "DenyCharNameLogon", role_name, 1)
    setgmlevel(play, 0)
    _debug("ban.execute", "ok=" .. tostring(ok) .. ",result=" .. tostring(err))
    if not ok then return false end

    pcall(callscriptex, play, "CHANGELEVEL", "=", 1)
    return true
end

function npc.main(play, npcid)
    _debug("main.enter", "npcid=" .. tostring(npcid))
    if not _require_transfer_sync(play) then return end
    local ok, payload = pcall(_payload, play)
    if not ok then
        _debug("main.payload_error", payload)
        return
    end
    local json_ok, json = pcall(tbl2json, payload)
    if not json_ok then
        _debug("main.json_error", json)
        return
    end
    local send_ok, send_err = pcall(sendluamsg, play, 100, npcid or NPC_ID, 0, 0, json)
    _debug("main.send", "ok=" .. tostring(send_ok) .. ",result=" .. tostring(send_err))
end

function npc.link(play, npcid, action, arg, msgData)
    action = tonumber(action) or 0
    _debug("link.enter", "npcid=" .. tostring(npcid) .. ",action=" .. tostring(action)
        .. ",arg=" .. tostring(arg) .. ",msg=" .. tostring(msgData))
    if not _require_transfer_sync(play) then return end
    if action == 1 then
        if not _is_old_server() then
            local message = "开区满3天后才属于老区，当前新区不能申请转出。"
            Player.sendmsgEx(play, message .. "#57")
            _send(play, message)
            return
        end
        if tostring(msgData or "") ~= "CONFIRM_TRANSFER" then
            local message = "请在界面输入“确认转区”后提交申请。"
            Player.sendmsgEx(play, message .. "#57")
            _send(play, message)
            return
        end
        if _int(getplaydef(play, LOCK_VAR)) == 1 then
            local message = "该角色已申请转区并永久禁止登录。"
            Player.sendmsgEx(play, message .. "#57")
            _send(play, message)
            return
        end
        local account = _account(play)
        local origin_account = _origin_account(play)
        if origin_account == "" then
            local message = "该角色没有创建账号归属记录，不能申请转区。"
            Player.sendmsgEx(play, message .. "#57")
            _send(play, message)
            return
        end
        if not account or origin_account ~= account then
            local message = "当前账号与角色创建时的账号不一致，不能申请转区。"
            Player.sendmsgEx(play, message .. "#57")
            _send(play, message)
            return
        end
        local amount = _recharge(play)
        if amount < MIN_TRANSFER then
            _send(play, "真实充值需达到500元才可申请转区")
            return
        end
        local state, line, account = _read_account_state(play)
        if not state then
            _send(play, "暂时无法读取账号转区记录")
            return
        end
        if state.applied == 1 or state.remaining > 0 then
            _send(play, "此账号已有转区记录")
            return
        end
        state.exported = state.exported + amount
        state.remaining = state.remaining + amount
        state.applied = 1
        if not _save_account_state(line, account, state) then
            _send(play, "转区记录同步失败，请稍后重试")
            return
        end
        setplaydef(play, LOCK_VAR, 1)
        if not _ban_transferred_character(play) then
            _debug("ban.warning", "transfer saved but deny-list update failed")
        end
        _send(play, "转区申请成功，角色已永久锁定，请使用原账号前往目标区")
        kick(play)
        return
    end

    if action == 2 then
        if _is_old_server() then
            local message = "只有开区未满3天的新区才能领取转区充值。"
            Player.sendmsgEx(play, message .. "#57")
            _send(play, message)
            return
        end
        local amount = _int(arg)
        if amount <= 0 then
            _send(play, "请输入有效的领取金额")
            return
        end
        if _int(getplaydef(play, LOCK_VAR)) == 1 then
            _send(play, "该角色已申请转区并永久锁定")
            return
        end
        local state, line, account = _read_account_state(play)
        if not state or state.remaining <= 0 then
            _send(play, "当前账号没有待领取的转区充值")
            return
        end
        local claimable = _claimable(play, state)
        if amount > claimable then
            _send(play, "领取金额超过当前可领取额度")
            return
        end
        if type(recharge) ~= "function" then
            _send(play, "充值服务暂不可用")
            return
        end
        state.remaining = state.remaining - amount
        state.claimed = state.claimed + amount
        if not _save_account_state(line, account, state) then
            _send(play, "转区记录同步失败，请稍后重试")
            return
        end
        local ok, err = pcall(recharge, play, amount, 0, 7, true)
        if not ok then
            state.remaining = state.remaining + amount
            state.claimed = math.max(0, state.claimed - amount)
            _save_account_state(line, account, state)
            release_print("npc_1033 claim failed", tostring(err))
            _send(play, "充值处理失败，转区余额已恢复")
            return
        end
        _send(play, "转区充值领取成功")
        return
    end

    npc.main(play, npcid)
end

local function _block_transferred_character(play)
    if _int(getplaydef(play, LOCK_VAR)) ~= 1 then return end
    _ban_transferred_character(play)
    Player.sendmsgEx(play, "当前角色已经申请转区，系统永久禁止登录。#57")
    kick(play)
end

GameEvent.add(EventCfg.onLogin, _block_transferred_character, "npc_1033_transfer_login_lock")
GameEvent.add(EventCfg.onLoginEnd, _block_transferred_character, "npc_1033_transfer_login_lock_end")
return npc
