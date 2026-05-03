local builder = require("builder")

local widget

function love.load()
	widget = builder:build(builder:newScaffold({
		bgColor = { 1.0, 1.0, 1.0, 1.0 },
		child = builder:newButton({
			text = "Hi",
			onPress = function(self)
				self.x = self.x + 10
			end,
		}),
	}))
	widget:load()
end

function love.update(dt)
	widget:update(dt)
end

function love.draw()
	widget:draw()
end
