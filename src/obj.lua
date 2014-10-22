obj={}
objects={}
local function applyDefault(a,b)
	 for k,v in pairs(a) do
	 	if b[k]==nil then
		 	b[k]=v
		end
	 end
	 return b
end
local default={
	frame={
		x=25,y=25,width=50,height=50,
		r=255,g=255,b=255,a=255
	},
	text={
		x=0,y=0,size=15,value="Hello, World!",
		r=0,g=0,b=0,a=255
	},
}

local function new(parent,tpe,prefs)
	return obj.new(tpe,prefs,parent)
end

local function destroy(object)
	for k,v in pairs(object.child) do
		v:destroy()
	end
	for k,v in pairs(objects) do
		if v==object then
			table.remove(objects,k)
		end
	end
end

local function updaterealpos(object)
	object.realx=(object.parent and object.parent.realx or 0)+object.x
	object.realy=(object.parent and object.parent.realy or 0)+object.y
	for k,v in pairs(object.child) do
		v:updaterealpos()
	end
end

function obj.new(tpe,prefs,parent)
	prefs=applyDefault(default[tpe],prefs or {})
	local out
	local x,y=prefs.x or 0,prefs.y or 0
	local realx,realy=x,y
	if parent then
		realx=parent.realx+x
		realy=parent.realy+y
	end
	prefs.x,prefs.y=nil
	if tpe=="text" and not prefs.maxwidth then
		prefs.maxwidth=(parent and parent.type=="frame") and (parent.width-x) or 100
	end
	out=setmetatable(applyDefault(prefs,{
		realx=realx,
		realy=realy,
		layer=prefs.layer or (parent and (parent.layer+1) or 0),
		type=tpe,
		
		new=new,
		destroy=destroy,
		updaterealpos=updaterealpos,
		
		parent=parent,
		child={},
	}),{
		__index=function(s,n)
			if n=="x" then
				return x
			elseif n=="y" then
				return y
			end
		end,
		__newindex=function(s,n,d)
			if n=="x" then
				x=d
				s:updaterealpos()
			elseif n=="y" then
				y=d
				s:updaterealpos()
			else
				rawset(s,n,d)
			end
		end
	})
	if parent then
		table.insert(parent.child,out)
	end
	table.insert(objects,out)
	table.sort(objects,function(a,b)
		return a.layer<b.layer
	end)
	return out
end

local font=setmetatable({},{__index=function(s,n)
	s[n]=love.graphics.newFont(n)
	return s[n]
end})

local graphics=love.graphics
hook.new("draw",function()
	local w,h=graphics.getDimensions()
	local u=h/100
	graphics.setBackgroundColor(0,0,0)
	for k,v in pairs(objects) do	
		if v.a~=0 then
			graphics.setColor(v.r,v.g,v.b,v.a)
			local tpe=v.type
			if v.draw then
				v.draw(v,u)
			elseif tpe=="frame" then
				if v.image then
					local w,h=v.image:getDimensions()
					graphics.draw(v.image,u*v.realx,u*v.realy,r,(v.width*u)/w,(v.height*u)/h)
				else
					graphics.rectangle("fill",u*v.realx,u*v.realy,u*v.width,u*v.height)
				end
			elseif tpe=="text" then
				graphics.setFont(font[u*v.size])
				graphics.printf(v.value,u*v.realx,u*v.realy,u*v.maxwidth,v.style)
			end
		end
	end
	--[[for k,v in pairs(objects) do	
		if v.type=="frame" and (v.onClick or v.onDrag or v.onDown) then
			local rx=v.realx
			local ry=v.realy
			local rw=v.width
			local rh=v.height	
			if v.xclick then
				local th=v.xclick
				rx=rx-th
				rw=rw+(th*2)
			end
			if v.yclick then
				local th=v.yclick
				rh=rh+(th*2)
				ry=ry-th
			end
			graphics.setColor(50,255,50,100)
			graphics.rectangle("fill",u*rx,u*ry,u*rw,u*rh)
		end
	end]]
end)

local function findObject(x,y,cb)
	local robjects={}
	for k,v in pairs(objects) do
		table.insert(robjects,1,v)
	end
	for k,v in pairs(robjects) do
		local tpe=v.type
		local rx=v.realx
		local ry=v.realy
		local rw=v.width
		local rh=v.height	
		if tpe=="frame" and v.xclick then
			local th=v.xclick
			rx=rx-th
			rw=rw+(th*2)
		end
		if tpe=="frame" and v.yclick then
			local th=v.yclick
			rh=rh+(th*2)
			ry=ry-th
		end
		if tpe=="frame" and x>=rx and y>=ry and x<=rx+rw and y<=ry+rh then
			if cb(v) then
				return
			end
		end
	end
end

hook.new("update",function(dt)
	for k,v in pairs(objects) do
		if v.update then
			v:update(dt)
		end
	end
end)

hook.new("mouse_down",function(x,y)
	local w,h=graphics.getDimensions()
	x,y=(x/h)*100,(y/h)*100
	local obj=findObject(x,y,function(obj)
		return obj.onDown and obj.onDown(obj,x,y)
	end)
end)

hook.new("mouse_click",function(x,y)
	local w,h=graphics.getDimensions()
	x,y=(x/h)*100,(y/h)*100
	local obj=findObject(x,y,function(obj)
		return obj.onClick and obj.onClick(obj,x,y)
	end)
end)

hook.new("mouse_drag",function(x,y)
	local w,h=graphics.getDimensions()
	x,y=(x/h)*100,(y/h)*100
	local obj=findObject(x,y,function(obj)
		return obj.onDrag and obj.onDrag(obj,x,y)
	end)
end)
