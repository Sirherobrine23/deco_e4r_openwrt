#!/usr/bin/env lua

local bit = require "bit"
local nw  = require "luci.model.app_network"
local luci_cfg = require "luci.config"
local nixio = require "nixio"
local uci = require "luci.model.uci"
local uci_r = uci.cursor()
local ctypes = require "luci.model.checktypes"
local dbg    = require "luci.tools.debug"

local function lua_split_string(string, split)
    local tab = {}
    
    while true do
        local pos = string.find(string, split)
        if not pos then
            tab[#tab + 1] = string
            break
        end
        local sub_str = string.sub(string, 1, pos - 1)
        tab[#tab + 1] = sub_str
        string = string.sub(string, pos + 1, #string)
    end
    
    return tab
end

local function lua_inet_aton(ipaddr)
    if type(ipaddr) ~= "table" then
        return 0
    end

    local ip = bit.lshift(ipaddr[1], 24) + bit.lshift(ipaddr[2], 16) + bit.lshift(ipaddr[3], 8) + ipaddr[4]
    return ip
end

local function lua_mask_ntoa(mask)
    if tonumber(mask) >= 32 then
        return "255.255.255.255"
    end
    local zeros = 32 - tonumber(mask)
    local m = tonumber(0xffffffff, 16)
    while zeros > 8 do
        m = bit.band(bit.lshift(m,8), tonumber(0xffffffff, 16))
        zeros = zeros - 8
    end
    m = bit.band(bit.lshift(m,zeros), tonumber(0xffffffff, 16))

    local m1 = bit.rshift(m, 24)
    local m2 = bit.rshift(bit.band(0x00ffffff, m), 16)
    local m3 = bit.rshift(bit.band(0x0000ffff, m), 8)
    local m4 = bit.band(0x000000ff, m)
    
    local mk = m1 .. "." .. m2 .. "." .. m3 .. "." .. m4
    return mk

end

local function dlogin_get_mask_len(arg)
    local mask_tab = lua_split_string(arg[2], "%.")
    local mask = lua_inet_aton(mask_tab)
	--print (mask)
	local len = 32
	local tmp_mask = bit.bxor(mask, tonumber(0xffffffff, 16))
	--print(tmp_mask)
	while true do
		tmp_mask = bit.rshift(tmp_mask, tonumber(1, 16))
		len = len - 1
		--print(tmp_mask)
		if tmp_mask == 0 then
		    break
		end
    end
    --print(len)
	return len
end

local function dlogin_is_samesubnet(lanaddr, checkaddr, lanmask)
    local lan_addr = lua_split_string(lanaddr, "%.")
    local wan_addr = lua_split_string(checkaddr, "%.")
    local mask = bit.lshift(tonumber(0xffffffff, 16), 32 - tonumber(lanmask))

    if bit.band(lua_inet_aton(lan_addr), mask) ==
            bit.band(lua_inet_aton(wan_addr), mask)
    then
        return true
    else
        return false
    end
end

--ip addr in checkaddrlist is split by ','
local function dlogin_ip_list_is_samesubnet(lanaddr, checkaddrlist, lanmask, wanmask)
	--dbg.printf("lanaddr:"..lanaddr.."lanmsk:"..lanmask.."checkaddrlist:"..checkaddrlist.."wan_mask:"..wanmask)
    checkaddrlist = checkaddrlist:gsub(",", " ")
	local lan_mask_str = lua_mask_ntoa(lanmask)
	local wan_mask_str = lua_mask_ntoa(wanmask)
    for ip in string.gmatch(checkaddrlist, "%S+") do
        --if true == dlogin_is_samesubnet(lanaddr, ip, lanmask)
		--dbg.printf("lanaddr:"..lanaddr.." lanmsk:"..lan_mask_str.." ip:"..ip.." wan_mask:"..wan_mask_str)
        if false == ctypes.check_network_no_collision(lanaddr, lan_mask_str, ip, wan_mask_str)
        --if true == dlogin_is_samesubnet(lanaddr, ip, lanmask)
        then 
			dbg.printf("return true")
            return true
        end
    end
		dbg.printf("return false")
        return false
    end


local function dlogin_list_is_samesubnet(arg)
    if not arg[2] or not arg[3] or not arg[4] or not arg[5]
    then
        return false
    end

    return dlogin_ip_list_is_samesubnet(arg[2], arg[3], arg[4], arg[5])
    end
    
    
-- Param must be wan ip address
local function dlogin_network_do(arg)
    
    if not arg[2] or not arg[3] then
        return false
    end

    local http_form = {}
    http_form.form = "lan_ipv4"
    http_form.operation = "write"                     
    http_form.ipaddr = arg[2]  
    http_form.mask_type = arg[3]                     
    if arg[3] ~= "255.255.255.0" and arg[3] ~= "255.255.0.0" and arg[3] ~= "255.0.0.0" then
        http_form.custom_value = http_form.mask_type 
        http_form.mask_type = "custom"    
    end

    local res = nw.dispatch(http_form)
    if res.success then
        local new_net = arg[2] .. "/" .. arg[3]
        return new_net
    else
        return false
    end
end

local function dlogin_kill_session(arg)
    local sauth = require "luci.sauth"
    local path = luci_cfg.sauth.sessionpath
    local sess_dir = nixio.fs.dir(path)
    local sess

    if sess_dir ~= nil then
        for sess in nixio.fs.dir(path) do
            sauth.kill(sess)
        end
    end

    return true
end


local function dlogin_get_new_net(arg)
    local conflict_ip = { 
        [1] = "192.168.0.1", 
        [2] = "192.168.1.1",
        [3] = "192.168.3.1",
        [4] = "192.168.4.1",
        [5] = "172.16.0.1",
        [6] = "172.17.0.1",
        [7] = "172.18.0.1",
        [8] = "172.19.0.1"
--        [4] = "10.167.0.1",
 --       [5] = "10.168.0.1"
 --       [4] = "192.168.4.1"
    }
--[[
    if not arg[2] or not arg[3] or not arg[4] or not arg[5]
    then
        return false
    end
]]
 
    local lan_mask = arg[3]
    local wan_mask = arg[4]
    local internet_mask = arg[5]
    local guest_mask= arg[6]
    local is_same = false    
    local sync = require "luci.model.sync"
    local guest_ver = sync.get_guest_ver()

    if not arg[2] 
    then
        return false
    end

    if not lan_mask and not wan_mask and not internet_mask and not guest_mask
    then
		dbg.printf("arg error 2:")
        return false
    end
    --[[
    for key,new_addr in ipairs(conflict_ip) do
        if false == dlogin_ip_list_is_samesubnet(new_addr, arg[2], arg[3], arg[4]) and
           false == dlogin_ip_list_is_samesubnet(new_addr, arg[2], arg[3], arg[5])
        then
            local new_net = new_addr .. "/" .. lua_mask_ntoa(arg[3])
            return new_net
        end
    end
    ]]
    for key,new_addr in ipairs(conflict_ip) do
        if "1" ~= guest_ver then
            if guest_mask and false == is_same 
            then
                is_same = dlogin_ip_list_is_samesubnet(new_addr, arg[2], lan_mask, guest_mask)
                --dbg.printf("guest_mask:"..guest_mask.."lan_mask:"..lan_mask.."new_addr:"..new_addr);
            end
        end

        if wan_mask and false == is_same 
        then
            is_same = dlogin_ip_list_is_samesubnet(new_addr, arg[2], lan_mask, wan_mask)
            --dbg.printf("wan_mask:"..wan_mask.."lan_mask:"..lan_mask.."new_addr:"..new_addr);
        end

        if internet_mask and false == is_same 
        then
            is_same = dlogin_ip_list_is_samesubnet(new_addr, arg[2], lan_mask, internet_mask)
            --dbg.printf("internet_mask:"..internet_mask.."lan_mask:"..lan_mask.."new_addr:"..new_addr);
        end

        if false == is_same 
        then
            local new_net = new_addr .. "/" .. lua_mask_ntoa(arg[3])
            --dbg.printf("new_net:"..new_net);
            return new_net
        end
        is_same = false
    end    
    return false
end

--add by wanghao
local function dlogin_get_new_guest_net(arg)
    local conflict_ip = { 
        [1] = "192.168.2.1", 
        [2] = "192.168.5.1",
        [3] = "192.168.6.1",
		[4] = "192.168.7.1",
        [5] = "172.25.2.1", 
        [6] = "172.26.2.1",
        [7] = "172.27.2.1", 
        [8] = "172.28.2.1"
        --[4] = "10.169.2.1",
       -- [5] = "10.170.2.1"
--		[4] = "192.168.7.1",
    }

    local guest_mask = 24
    local lan_mask = arg[3]
    local wan_mask = arg[4]
    local internet_mask = arg[5]
    local is_same = false

    if not arg[2] or not arg[3] or not arg[4]
    then
        return false
    end

    if not lan_mask and not wan_mask and not internet_mask 
    then
        return false
    end

    for key,new_addr in ipairs(conflict_ip) do
        if lan_mask and false == is_same 
        then
            is_same = dlogin_ip_list_is_samesubnet(new_addr, arg[2], guest_mask, lan_mask)
           -- dbg.printf("lanmask:"..lan_mask.."guestmask:"..guest_mask.."new_addr:"..new_addr);
        end

        if wan_mask and false == is_same 
        then
            is_same = dlogin_ip_list_is_samesubnet(new_addr, arg[2], guest_mask, wan_mask)
          --  dbg.printf("wan_mask:"..wan_mask.."guestmask:"..guest_mask.."new_addr:"..new_addr);
        end

        if internet_mask and false == is_same 
        then
            is_same = dlogin_ip_list_is_samesubnet(new_addr, arg[2], guest_mask, internet_mask)
           -- dbg.printf("internet_mask:"..internet_mask.."guestmask:"..guest_mask.."new_addr:"..new_addr);
        end

        if false == is_same 
        then
            local new_net = new_addr .. "/" .. lua_mask_ntoa(guest_mask)
           -- dbg.printf("new_net:"..new_net);
            --local new_net = new_addr .. "/" .. lua_mask_ntoa(arg[3])
            return new_net
        end
        is_same = false
    end
    
    return false
end
--add end

local function dlogin_need_check_guest()
    local sync = require "luci.model.sync"
    local guest_ver = sync.get_guest_ver()

    if "1" == guest_ver then
        return false
    else
        return true
    end
end

local dlogin_inst = {
    api = {
        checklist = dlogin_list_is_samesubnet,
        ipchg = dlogin_network_do,
        ksess = dlogin_kill_session,
        getnew = dlogin_get_new_net,
        getnewguest = dlogin_get_new_guest_net, --add by wanghao
        masklen = dlogin_get_mask_len,
        needcheckguest = dlogin_need_check_guest
    }
}
--[[
arg[1]="getnew"
arg[2]="192.168.2.1,5.5.5.6,4.4.4.5,192.168.0.105"
arg[3]="26"
arg[4]="24"
arg[5]="24"
arg[6]="24"
]]
local func = dlogin_inst.api[arg[1]]

if not func then
    print(false)
end

local res = func(arg)

print(tostring(res))

