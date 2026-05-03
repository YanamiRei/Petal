local scaffold = require("widgets.scaffold")
local button = require("widgets.button")
button.x = 100
button.y = 100
button.onPress = function()
	button.x = button.x + 10
end

scaffold.child = button

function love.load()
	scaffold:load()
end

function love.update(dt)
	scaffold:update(dt)
end

function love.draw()
	scaffold:draw()
end
