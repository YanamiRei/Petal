local button = {}

button.height = 50
button.width = 150
button.text = "Button"
button.fontSize = 32
button.textColor = { 0.1, 0.1, 0.1, 1.0 }
button.onPress = function() end
button.color = { 0.4, 0.4, 0.5, 1.0 }
button.hotColor = { 0.6, 0.6, 0.7, 1.0 }
button.inactiveColor = { 0.2, 0.2, 0.3, 1.0 }
button.active = true
button.x = 0
button.y = 0

local font = nil
local currentMouseState
local lastMouseState
local hot = false

function button:load()
	font = love.graphics.newFont(button.fontSize)
	currentMouseState = love.mouse.isDown(1)
end

function button:update(dt)
	lastMouseState = currentMouseState
	currentMouseState = love.mouse.isDown(1)
	if lastMouseState and not currentMouseState and hot then
		button.onPress()
	end
end

function button:draw()
	local mx, my = love.mouse.getPosition()
	hot = mx > button.x and mx < button.x + button.width and my > button.y and my < button.y + button.height
	local color
	if button.active then
		color = hot and button.hotColor or button.color
	else
		color = button.inactiveColor
	end

	love.graphics.setColor(unpack(color))
	love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

	local textH = font:getHeight(button.text)
	local textW = font:getWidth(button.text)

	love.graphics.setColor(unpack(button.textColor))
	love.graphics.print(
		button.text,
		font,
		button.x + (button.width * 0.5) - (textW * 0.5),
		button.y + (button.height * 0.5) - (textH * 0.5)
	)
end

return button
