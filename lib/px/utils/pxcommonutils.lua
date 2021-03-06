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
        if string.lower(value) == string.lower(item) then
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
        if type(v) == "function" then
            target[k] = string.dump(v)
        elseif type(v) == "table" then
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

function  _M.filter_headers(sensitive_headers, isRiskRequest)
    local headers = ngx.req.get_headers()
    local request_headers = {}
    for k, v in pairs(headers) do
        -- filter sensitive headers
        if _M.array_index_of(sensitive_headers, k) == -1 then
            if isRiskRequest == true then
                request_headers[#request_headers + 1] = { ['name'] = k, ['value'] = v }
            else
                request_headers[k] = v
            end
        end
    end

    return request_headers
end

function _M.clear_first_party_sensitive_headers(sensitive_headers)
    if not sensitive_headers then
        return
    end

    for i, header in ipairs(sensitive_headers) do
        ngx.req.clear_header(header)
    end
end

-- Splits a string into array
-- @s - string to split
-- @delimeter - delimeiter to use
--
-- @return - splitted string as array
function _M.split_string(s, delimeter)
    local a = {}
    local b = 1
    for i in string.gmatch(s, delimeter) do
        a[b] = i
        b = b + 1
    end
    return a
end

-- Formats string bytes into hex string
-- @str - string of hmac
--
-- @return - a hex formated representation of the string bytes
function _M.to_hex(str)
    return (string.gsub(str, "(.)", function(c)
        return string.format("%02X%s", string.byte(c), "")
    end))
end

return _M