local hooks={}
hook={
	sel={},
	rsel={},
	meta={},
	created={},
	hooks=hooks,
}
local hook=hook
local function nxt(tbl)
	local n=1
	while tbl[n] do
		n=n+1
	end
	return n
end

function tpairs(tbl)
	local s={}
	local c=1
	for k,v in pairs(tbl) do
		s[c]=k
		c=c+1
	end
	c=0
	return function()
		c=c+1
		return s[c],tbl[s[c]]
	end
end

local ed
function hook.stop()
	ed=true
end
function hook.queue(name,...)
	local callback=hook.callback
	hook.callback=nil
	if type(name)~="table" then
		name={name}
	end
	local p={}
	for _,nme in pairs(name) do
		for k,v in tpairs(hooks[nme] or {}) do
			if v then
				ed=false
				hook.name=nme
				p={v(...)}
				if callback then
					callback(unpack(p))
				end
				if ed then
					hook.del(v)
				end
			end
		end
	end
	return unpack(p)
end
function hook.new(name,func,meta)
	if type(name)~="table" then
		name={name}
	end
	for _,nme in pairs(name) do
		hook.meta[nme]=meta
		hooks[nme]=hooks[nme] or {}
		table.insert(hooks[nme],func)
	end
	return func
end
function hook.del(name)
	if type(name)~="table" then
		name={name}
	end
	for _,nme in pairs(name) do
		if type(nme)=="function" then
			for k,v in pairs(hooks) do
				for n,l in pairs(v) do
					if l==nme then
						hooks[k][n]=nil
					end
				end
			end
		else
			hooks[nme]=nil
		end
	end
end
function serialize(value, pretty)
	local kw = {
		["and"]=true,["break"]=true, ["do"]=true, ["else"]=true,
		["elseif"]=true, ["end"]=true, ["false"]=true, ["for"]=true,
		["function"]=true, ["goto"]=true, ["if"]=true, ["in"]=true,
		["local"]=true, ["nil"]=true, ["not"]=true, ["or"]=true,
		["repeat"]=true, ["return"]=true, ["then"]=true, ["true"]=true,
		["until"]=true, ["while"]=true
	}
	local id = "^[%a_][%w_]*$"
	local ts = {}
	local function s(v, l)
		local t = type(v)
		if t == "nil" then
			return "nil"
		elseif t == "boolean" then
			return v and "true" or "false"
		elseif t == "number" then
			if v ~= v then
				return "0/0"
			elseif v == math.huge then
				return "math.huge"
			elseif v == -math.huge then
				return "-math.huge"
			else
				return tostring(v)
			end
		elseif t == "string" then
			return string.format("%q", v):gsub("\\\n","\\n")
		elseif t == "table" and pretty and getmetatable(v) and getmetatable(v).__tostring then
			return tostring(v)
		elseif t == "table" then
			if ts[v] then
				return "recursive"
			end
			ts[v] = true
			local i, r = 1, nil
			local f
			for k, v in pairs(v) do
				if r then
					r = r .. "," .. (pretty and ("\n" .. string.rep(" ", l)) or "")
				else
					r = "{"
				end
				local tk = type(k)
				if tk == "number" and k == i then
					i = i + 1
					r = r .. s(v, l + 1)
				else
					if tk == "string" and not kw[k] and string.match(k, id) then
						r = r .. k
					else
						r = r .. "[" .. s(k, l + 1) .. "]"
					end
					r = r .. "=" .. s(v, l + 1)
				end
			end
			ts[v] = nil -- allow writing same table more than once
			return (r or "{") .. "}"
		elseif t == "function" then
			return "func"
		elseif t == "userdata" then
			return "userdata"
		else
			if pretty then
				return tostring(t)
			else
				error("unsupported type: " .. t)
			end
		end
	end
	local result = s(value, 1)
	local limit = type(pretty) == "number" and pretty or 10
	if pretty then
		local truncate = 0
		while limit > 0 and truncate do
			truncate = string.find(result, "\n", truncate + 1, true)
			limit = limit - 1
		end
		if truncate then
			return result:sub(1, truncate) .. "..."
		end
	end
	return result
end

