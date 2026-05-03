local builder = {}

local function adopt(widget, parent)
	widget.parent = parent
	if widget.child then
		adopt(widget.child, widget)
	end
	if widget.children then
		for _, child in ipairs(widget.children) do
			adopt(child, widget)
		end
	end
end

function builder:build(root)
	adopt(root, nil)
	return root
end

function builder:newScaffold(args)
	args = args or {}
	local scaffold = {}
	scaffold.bgColor = args.bgColor or { 1.0, 1.0, 1.0, 1.0 }
	scaffold.child = args.child or nil

	function scaffold:load()
		if scaffold.child then
			scaffold.child:load()
		end
	end

	function scaffold:update(dt)
		if scaffold.child then
			scaffold.child:update(dt)
		end
	end

	function scaffold:draw()
		love.graphics.setBackgroundColor(unpack(scaffold.bgColor))
		if scaffold.child then
			scaffold.child:draw()
		end
	end

	return scaffold
end

function builder:newButton(args)

	args = args or {}
	local button = {}

	button.height = args.height or 50
	button.width = args.width or 150
	button.text = args.text or "Button"
	button.fontSize = args.fontSize or 32
	button.textColor = args.textColor or { 0.1, 0.1, 0.1, 1.0 }
	button.onPress = args.onPress
	button.color = args.color or { 0.4, 0.4, 0.5, 1.0 }
	button.hotColor = args.hotColor or { 0.6, 0.6, 0.7, 1.0 }
	button.inactiveColor = args.inactiveColor or { 0.2, 0.2, 0.3, 1.0 }
	button.active = args.active or true
	button.x = args.x or 0
	button.y = args.y or 0

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
		if lastMouseState and not currentMouseState and hot and self.onPress then
			self.onPress(self)
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
end

return builder
