-- Condition is host,url,status,method
-- http_nginx_count  is qps (count of request)
-- http_nginx_rt is sum of responsetime(request_time in Nginx)
-- http_nginx_size is sum of sent_body_size(body_bytes_sent in Nginx)

--  Prometheus Metrics
local PrometheusEasy = {
    qps_surfix = "_count",
    rt_surfix = "_rt",
    size_surfix = "_size"
}

-- init method
function PrometheusEasy:init(dict_name, prefix)
    o = PrometheusEasy
    self.__index = self
    self.dict = ngx.shared[dict_name]
    self.prefix = prefix
    setmetatable(o, self)
    return o
end

-- log count
function PrometheusEasy:qps()
    local ngx = require "ngx"
    local key = full_metric_name(self.prefix .. self.qps_surfix, { "host", "url", "code", "method" }, { ngx.var.host, ngx.var.request_uri, ngx.var.status, ngx.var.request_method })
    local count, flags = self.dict:get(key)
    if count == nil then
        local new_val, err, forcible = self.dict:set(key, 1)
    else
        local new_val, err, forcible = self.dict:incr(key, 1)
    end
end

-- log rt by sum
function PrometheusEasy:rt()
    local ngx = require "ngx"
    local rt = ngx.var.request_time or 0
    local key = full_metric_name(self.prefix .. self.rt_surfix, { "host", "url", "code", "method" }, { ngx.var.host, ngx.var.request_uri, ngx.var.status, ngx.var.request_method })
    local rt_total, flags = self.dict:get(key)
    if rt_total == nil then
        local new_val, err, forcible = self.dict:set(key, rt)
    else
        local new_val, err, forcible = self.dict:set(key, rt_total + rt)
    end
end

-- log bodySize by sum
function PrometheusEasy:body_size()
    local ngx = require "ngx"
    local body_size = ngx.var.body_bytes_sent
    local key = full_metric_name(self.prefix .. self.size_surfix, { "host", "url", "code", "method" }, { ngx.var.host, ngx.var.request_uri, ngx.var.status, ngx.var.request_method })
    local size_total, flags = self.dict:get(key)
    if size_total == nil then
        local new_val, err, forcible = self.dict:set(key, body_size)
    else
        local new_val, err, forcible = self.dict:set(key, body_size + size_total)
    end
end

-- Get metrics result
function PrometheusEasy:metrics()
    local str = ""
    for _, val in pairs(self.dict:get_keys()) do
        local obj_val, flags = self.dict:get(val)
        str = str .. val .. " " .. obj_val
        str = str .. "\n"
    end
    return str
end


-- Compose a metrics key
function full_metric_name(name, label_names, label_values)
    if not label_names then
        return name
    end
    local label_parts = {}
    for idx, key in ipairs(label_names) do
        local label_value = (string.format("%s", label_values[idx]):gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub('"', '\\"'))
        table.insert(label_parts, key .. '="' .. label_value .. '"')
    end
    return name .. "{" .. table.concat(label_parts, ",") .. "}"
end

return PrometheusEasy