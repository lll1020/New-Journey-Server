-- safe_require.lua

-- 保存原始的 require 函数
--local originalRequire = require
local originalRequire = include
-- 封装的安全 require 函数
local function safeRequire(moduleName)
    local status, result = pcall(originalRequire, moduleName)
    if status then
        return result
    else
        -- 错误处理逻辑，例如记录错误或打印错误信息
        release_print("Error loading module '" .. moduleName .. "':", result)
        -- 返回 nil，表示加载失败
        return nil
    end
end

-- 可选：覆盖全局的 require 函数
-- 将以下代码取消注释即可全局替换 require
require = safeRequire

return safeRequire
