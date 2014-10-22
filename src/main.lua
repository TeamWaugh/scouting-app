require("hook")
require("obj")
require("app")
function love.load()
	love.window.setMode(900,500,{resizable=true})
	hook.queue("load")
end
local mdown=false
local mdrag=false
local mx,my=0,0
local ox,oy=0,0
local function dist(x1,x2,y1,y2)
	return math.sqrt(math.abs(x1-x2)^2+math.abs(y1-y2)^2)
end
function love.draw()
	hook.queue("draw")
end
if love.system.getOS()=="Android" then
	function love.update(dt)
		hook.queue("update",dt)
	end
	
	function love.touchpressed(id,x,y)
		local w,h=love.graphics.getDimensions()
		x=x*w
		y=y*h
		if id==0 then
			mdown=true
			mdrag=false
			mx=x
			my=y
			ox=x
			oy=y
			hook.queue("mouse_down",x,y,"l")
		end
	end
	function love.touchmoved(id,x,y)
		local w,h=love.graphics.getDimensions()
		x=x*w
		y=y*h
		if id==0 then
			if dist(x,mx,y,my)>h/(mdrag and 100 or 30) then	
				mdrag=true
				mx=x
				my=y
				hook.queue("mouse_drag",x,y,"l")
			end
		end
	end
	function love.touchreleased(id,x,y)
		local w,h=love.graphics.getDimensions()
		x=x*w
		y=y*h
		if id==0 then
			if dist(x,ox,y,oy)<h/30 and not mdrag then
				hook.queue("mouse_click",x,y,bt)
			end
			mdown=false
			mx=x
			my=y
			hook.queue("mouse_up",x,y,"l")
		end
	end
else
	function love.update(dt)
		local w,h=love.graphics.getDimensions()
		if mdown then
			local x,y=love.mouse.getPosition()
			if dist(x,mx,y,my)>h/(mdrag and 100 or 30) then	
				mdrag=true
				mx=x
				my=y
				hook.queue("mouse_drag",x,y)
			end
		end
		hook.queue("update",dt)
	end
	function love.mousepressed(x,y,bt)
		mdown=true
		mdrag=false
		mx=x
		my=y
		ox=x
		oy=y
		hook.queue("mouse_down",x,y,bt)
	end
	function love.mousereleased(x,y,bt)
		local w,h=love.graphics.getDimensions()
		if dist(x,ox,y,oy)<h/30 and not mdrag then
			hook.queue("mouse_click",x,y,bt)
		end
		mdown=false
		mx=x
		my=y
		hook.queue("mouse_up",x,y,bt)
	end
end
