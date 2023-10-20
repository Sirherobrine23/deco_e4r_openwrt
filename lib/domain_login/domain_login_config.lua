#!/usr/bin/env lua

local uci = require "luci.model.uci"

local function config_set(cfg, sec, opt, val)
    local uci_c = uci.cursor()
    
    uci_c:set(cfg, sec, opt, val)
end

local function config_commit(cfg)
    local uci_c = uci.cursor()
    uci_c:commit(cfg)
end

local function dlogin_config_set(arg)
    if arg[2] and arg[3] and arg[4] then
        config_set(arg[2], arg[3], arg[4], arg[5])
    end
end

local function dlogin_config_commit(arg)
    if arg[2] then
        config_commit(arg[2])
    end
end

local dispatch = {
    api = {
        set = dlogin_config_set,
        commit = dlogin_config_commit
    }
}

local func = dispatch.api[arg[1]]

if not func then
    print(false)
end

local res = func(arg)

print(tostring(res))
