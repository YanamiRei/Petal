local scaffold = {}

scaffold.bgColor = { 1.0, 1.0, 1.0, 1.0 }

function scaffold:load()
	scaffold.child:load()
end

function scaffold:update(dt)
	scaffold.child:update(dt)
end

function scaffold:draw()
	love.graphics.setBackgroundColor(unpack(scaffold.bgColor))
	scaffold.child:draw()
end

return scaffold
