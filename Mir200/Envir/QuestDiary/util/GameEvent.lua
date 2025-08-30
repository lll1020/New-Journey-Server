GameEvent = {}

local _listeners = {}

-- 添加事件派发
---*eventName: 事件名字
---*fun：要执行的函数
---*tag：备注
---*priority:优先级
function GameEvent.add(eventName, func, tag, priority)
	assert(tag, "Tag must not be nil")

	if not _listeners[eventName] then
		_listeners[eventName] = {}
	end

	local eventListeners = _listeners[eventName]
	local eventListenerSize = #eventListeners
	for i = 1, eventListenerSize do
		if tag == eventListeners[i][2] then
			return
		end
	end

	if priority and eventListenerSize >= priority then
		table.insert(eventListeners, priority, {func, tag})
	else
		table.insert(eventListeners, {func, tag})
	end
end

function GameEvent.remove(func)
	for eventName, eventListeners in pairs(_listeners) do
		for i = 1, #eventListeners do
			if eventListeners[i][1] == func then
				table.remove(eventListeners, i)
				if 0 == #listeners[eventName] then
					listeners[eventName] = nil
				end
				return
			end
		end
	end
end

function GameEvent.removeByNameAndTag(eventName, tag)
	assert(tag, "Tag must not be nil")
	local eventListeners = _listeners[eventName]
	if not eventListeners then return end

	for i = #eventListeners, 1, -1 do
		if eventListeners[i][2] == tag then
			table.remove(eventListeners, i)
			break
		end
	end

	if 0 == #eventListeners then
		listeners[eventName] = nil
	end
end

function GameEvent.removeByTag(tag)
	assert(tag, "Tag must not be nil")
	for eventName, eventListeners in pairs(_listeners) do
		self.removeListenerByNameAndTag(eventName, tag)
	end
end

function GameEvent.removeAll()
	_listeners = {}
end

--GameEvent.push：发布事件
---* eventName：事件总类标识
---* ...可变参数传递
function GameEvent.push(eventName, ...)

	local eventListeners = _listeners[eventName]
	if not eventListeners then
		return
	end

	for index, listeners in ipairs(eventListeners) do
		local result, stop = pcall(listeners[1], ...)
		if result then
			if stop then break end
		else
			local tag = listeners[2]
			local tarid = tag.ID or 0
			local err = "派发事件发生错误：事件名="..eventName.."  模块ID="..tarid.."   "
			release_print(err, stop)
		end
	end
end

return GameEvent