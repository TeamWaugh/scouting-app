local graphics=love.graphics
local image=love.image
hook.new("load",function()
	local function vibrate()
		if love.system.vibrate then
			love.system.vibrate(0.01)
		end
	end
	for k,v in tpairs(objects) do
		objects[k]=nil
	end
	
end)

