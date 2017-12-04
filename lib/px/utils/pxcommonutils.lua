local socket = require("socket")
local _M = {}

function _M.get_time_in_milliseconds()
    return socket.gettime() * 1000
end

function _M.array_index_of(array, item)
    if array == nil then
        return -1
    end

    for i, value in ipairs(array) do
        if value == item then
            return i
        end
    end
    return -1
end

function clone (t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

function  _M.filter_config(px_config)
    local config_copy = clone(px_config)
    -- remove
    config_copy.cookie_secret = nil
    config_copy.auth_token = nil
    return config_copy
end

function  _M.filter_headers(sensitive_headers)
    local headers = ngx.req.get_headers()
    local request_headers = {}
    for k, v in pairs(headers) do
        -- filter sensitive headers
        if _M.array_index_of(sensitive_headers, k) == -1 then
            request_headers[#request_headers + 1] = { ['name'] = k, ['value'] = v }
        end
    end

    return request_headers
end

return _M
