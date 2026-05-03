local builder = require("builder")

local widget

function love.load()
	widget = builder:build(builder:newScaffold({
		bgColor = { 1.0, 1.0, 1.0, 1.0 },
		child = builder:newRow({
			spacing = 10,
			crossAxisAlignment = "start",
			children = {
				builder:newButton({ text = "Play", width = 100, height = 50 }),
				builder:newButton({ text = "Options", width = 200, height = 50 }),
				builder:newButton({ text = "Quit", width = 300, height = 100 }),
			},
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
