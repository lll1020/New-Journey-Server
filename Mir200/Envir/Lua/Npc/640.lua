npc = {}


--棋痴老王

local _config = Guard.getConfig("npc_640")

local STATE_KEY = "S$棋局"

local PUZZLE = {
    size = 12,
    init = {
        {x = 3 + 3, y = 5 + 3, role = 1},
        {x = 4 + 3, y = 5 + 3, role = 1},
        {x = 4 + 3, y = 4 + 3, role = 2},
        {x = 5 + 3, y = 5 + 3, role = 2},
    },
}
local function copyInitBoard()
    local board = {}
    for _, s in ipairs(PUZZLE.init) do
        table.insert(board, {x = s.x, y = s.y, role = s.role})
    end
    return board
end

local function isOccupied(board, x, y)
    for _, s in ipairs(board) do
        if s.x == x and s.y == y then
            return true
        end
    end
    return false
end

local function addStone(board, x, y, role)
    table.insert(board, {x = x, y = y, role = role})
end

local function buildMap(board)
    local map = {}
    for _, s in ipairs(board) do
        map[s.x..","..s.y] = s.role
    end
    return map
end

local function checkWin(board, role)
    local map = buildMap(board)
    local dirs = {{1,0},{0,1},{1,1},{1,-1}}
    for _, s in ipairs(board) do
        if s.role == role then
            for _, d in ipairs(dirs) do
                local cnt = 1
                for i = 1, 4 do
                    local key = (s.x + d[1]*i)..","..(s.y + d[2]*i)
                    if map[key] == role then
                        cnt = cnt + 1
                    else
                        break
                    end
                end
                if cnt >= 5 then
                    return true
                end
            end
        end
    end
    return false
end

local function findWinningMove(board, role)
    for x = 1, PUZZLE.size do
        for y = 1, PUZZLE.size do
            if not isOccupied(board, x, y) then
                addStone(board, x, y, role)
                local win = checkWin(board, role)
                table.remove(board)
                if win then
                    return {x = x, y = y}
                end
            end
        end
    end
    return nil
end

local function firstEmpty(board)
    for x = 1, PUZZLE.size do
        for y = 1, PUZZLE.size do
            if not isOccupied(board, x, y) then
                return {x = x, y = y}
            end
        end
    end
    return nil
end

local function countDir(map, role, x, y, dx, dy)
    local cnt = 0
    local nx = x + dx
    local ny = y + dy
    while map[nx..","..ny] == role do
        cnt = cnt + 1
        nx = nx + dx
        ny = ny + dy
    end
    return cnt
end

local function maxLineAt(map, role, x, y)
    local dirs = {{1,0},{0,1},{1,1},{1,-1}}
    local best = 1
    for _, d in ipairs(dirs) do
        local cnt = 1 + countDir(map, role, x, y, d[1], d[2]) + countDir(map, role, x, y, -d[1], -d[2])
        if cnt > best then
            best = cnt
        end
    end
    return best
end

local function inBoard(x, y)
    return x >= 1 and x <= PUZZLE.size and y >= 1 and y <= PUZZLE.size
end

local function openThreeAt(map, role, x, y)
    if map[x..","..y] then
        return false
    end
    local dirs = {{1,0},{0,1},{1,1},{1,-1}}
    for _, d in ipairs(dirs) do
        local c1 = countDir(map, role, x, y, d[1], d[2])
        local c2 = countDir(map, role, x, y, -d[1], -d[2])
        local total = 1 + c1 + c2
        if total == 3 then
            local ex1 = x + d[1] * (c1 + 1)
            local ey1 = y + d[2] * (c1 + 1)
            local ex2 = x - d[1] * (c2 + 1)
            local ey2 = y - d[2] * (c2 + 1)
            if inBoard(ex1, ey1) and inBoard(ex2, ey2) then
                if not map[ex1..","..ey1] and not map[ex2..","..ey2] then
                    return true
                end
            end
        end
    end
    return false
end

local function collectCandidates(board, lastMove)
    local map = buildMap(board)
    local set = {}
    local list = {}
    local function tryAdd(x, y)
        if x < 1 or x > PUZZLE.size or y < 1 or y > PUZZLE.size then
            return
        end
        local key = x..","..y
        if map[key] or set[key] then
            return
        end
        set[key] = true
        table.insert(list, {x = x, y = y})
    end
    local function addAround(x, y)
        for dx = -9, 9 do
            for dy = -9, 9 do
                if not (dx == 0 and dy == 0) then
                    tryAdd(x + dx, y + dy)
                end
            end
        end
    end
    if lastMove then
        addAround(lastMove.x, lastMove.y)
    end
    if #list == 0 then
        for _, s in ipairs(board) do
            addAround(s.x, s.y)
        end
    end
    return list
end

local function chooseAIMove(board, lastMove)
    local winMove = findWinningMove(board, 2)
    if winMove then
        return winMove
    end
    local blockMove = findWinningMove(board, 1)
    if blockMove then
        return blockMove
    end
    local candidates = collectCandidates(board, lastMove)
    if #candidates == 0 then
        return firstEmpty(board)
    end
    local map = buildMap(board)

    local bestOpen = nil
    local bestOpenScore = -1
    local bestOpenDist = 999
    for _, c in ipairs(candidates) do
        if openThreeAt(map, 1, c.x, c.y) then
            local score = maxLineAt(map, 1, c.x, c.y)
            local dist = 999
            if lastMove then
                dist = math.abs(c.x - lastMove.x) + math.abs(c.y - lastMove.y)
            end
            if score > bestOpenScore or (score == bestOpenScore and dist < bestOpenDist) then
                bestOpen = c
                bestOpenScore = score
                bestOpenDist = dist
            end
        end
    end
    if bestOpen then
        return bestOpen
    end

    local best = nil
    local bestScore = -1
    local bestBlock = -1
    local bestDist = 999
    for _, c in ipairs(candidates) do
        local score = maxLineAt(map, 2, c.x, c.y)
        local block = maxLineAt(map, 1, c.x, c.y)
        local dist = 999
        if lastMove then
            dist = math.abs(c.x - lastMove.x) + math.abs(c.y - lastMove.y)
        end
        if score > bestScore or (score == bestScore and block > bestBlock) or (score == bestScore and block == bestBlock and dist < bestDist) then
            best = c
            bestScore = score
            bestBlock = block
            bestDist = dist
        end
    end
    return best or firstEmpty(board)
end

local function getState(play)
    local raw = getplaydef(play, STATE_KEY)
    if raw and raw ~= "" then
        local ok, data = pcall(json2tbl, raw)
        if ok and type(data) == "table" then
            return data
        end
    end
    return nil
end

local function setState(play, state)
    setplaydef(play, STATE_KEY, tbl2json(state))
end

local function clearState(play)
    setplaydef(play, STATE_KEY, "")
end

local function parseMove(aid, data)
    if data and type(data) == "string" then
        local ok, tbl = pcall(json2tbl, data)
        if ok and type(tbl) == "table" and tbl.x and tbl.y then
            return tonumber(tbl.x), tonumber(tbl.y)
        end
    end
    if type(aid) == "string" then
        local parts = split(aid, ",")
        if parts[1] and parts[2] then
            return tonumber(parts[1]), tonumber(parts[2])
        end
    end
    return nil, nil
end

function npc.main(play, npcid)
    local data = {}
    data["T_dljq"] = Player.getJsonTableByVar(play, VarCfg.T_dljq)
    sendluamsg(play, 100, npcid, 0, 0, tbl2json(data))
end

function npc.link(play, npcid, ew, aid, data)
    -- npc_guard: 入参校验
    if not Guard.ensurePlayer(play, npcid) then
        return
    end
    local __guardAction = Guard.normalizeAction(play, npcid, ew)
    if __guardAction == nil then
        return
    end
    ew = __guardAction
    -- npc_guard: 操作白名单
    local __guardAllowedActions = Guard.newActionSet({1, 2})
    if not Guard.ensureActionAllowed(play, npcid, ew, __guardAllowedActions) then
        return
    end

    local jq_data = Player.getJsonTableByVar(play, VarCfg.T_dljq)

    if ew == 1 then
        local completed = (jq_data["npc_640"] and jq_data["npc_640"] >= 2)
        if not completed then
            if not Guard.ensureCost(play, _config.cost) then
                return
            end
            Guard.consumeCost(play, _config.cost, ","..(_config.name or "剧情任务"))
        end
        local state = {
            step = 1,
            board = copyInitBoard(),
        }
        setState(play, state)
        sendluamsg(play, 100, npcid, 1, 0, tbl2json({
            size = PUZZLE.size,
            board = state.board,
            step = state.step,
            tip = "请落子，和棋痴一较高下",
        }))
        return
    end

    if ew == 2 then
        local state = getState(play)
        if not state or not state.board then
            Player.sendmsgEx(play, "请先开始棋局#57")
            return
        end

        local x, y = parseMove(aid, data)
        if not x or not y then
            Player.sendmsgEx(play, "落子参数异常#57")
            return
        end
        if x < 1 or x > PUZZLE.size or y < 1 or y > PUZZLE.size then
            Player.sendmsgEx(play, "落子越界#57")
            return
        end
        if isOccupied(state.board, x, y) then
            Player.sendmsgEx(play, "该位置已有棋子#57")
            return
        end

        local step = state.step or 1
        addStone(state.board, x, y, 1)

        if checkWin(state.board, 1) then
            local completed = (jq_data["npc_640"] and jq_data["npc_640"] >= 2)
            if not completed then
                jq_data["npc_640"] = 2
                Player.setJsonVarByTable(play, VarCfg.T_dljq, jq_data)
            end
            clearState(play)
            Player.sendmsgEx(play, "你赢了#57")
            if not completed then
                sendluamsg(play, 101, 1005, 0, 0, "rwwc")
                if _config.ch then
                    Player.title_give(play, _config.ch)
                end
                local reward = _config.jl or _config.rwjl
                if reward then
                    Player.rwjl(play, reward, (_config.name or "剧情任务").."奖励", 1)
                end
            end
            sendluamsg(play, 100, npcid, 2, 0, tbl2json({
                result = "win",
                ai = nil,
                board = state.board,
            }))
            return
        end

        local ai = chooseAIMove(state.board, {x = x, y = y})

        if ai then
            if not isOccupied(state.board, ai.x, ai.y) then
                addStone(state.board, ai.x, ai.y, 2)
            end
            if checkWin(state.board, 2) then
                Player.sendmsgEx(play, "你输了#57")
                clearState(play)
                sendluamsg(play, 100, npcid, 2, 0, tbl2json({result = "fail", ai = ai, board = state.board}))
                return
            end
        else
            Player.sendmsgEx(play, "你输了#57")
            clearState(play)
            sendluamsg(play, 100, npcid, 2, 0, tbl2json({result = "fail", ai = ai, board = state.board}))
            return
        end

        if #state.board >= PUZZLE.size * PUZZLE.size then
            Player.sendmsgEx(play, "你输了#57")
            clearState(play)
            sendluamsg(play, 100, npcid, 2, 0, tbl2json({result = "fail", ai = ai, board = state.board}))
            return
        end

        state.step = step + 1
        setState(play, state)
        sendluamsg(play, 100, npcid, 2, 0, tbl2json({
            result = "continue",
            ai = ai,
            board = state.board,
            step = state.step,
        }))
    end
end

return npc
