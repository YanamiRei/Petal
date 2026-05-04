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

local function getAbsPos(widget)
	local x, y = 0, 0
	local p = widget.parent
	while p do
		x = x + (p.x or 0)
		y = y + (p.y or 0)
		p = p.parent
	end
	return x, y
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
	scaffold.x = 0
	scaffold.y = 0

	local function applySize(self)
		self.width = love.graphics.getWidth()
		self.height = love.graphics.getHeight()
		if self.child then
			self.child.maxWidth = self.width
			self.child.maxHeight = self.height
		end
	end

	function scaffold:load()
		applySize(self)
		if self.child then
			self.child:load()
		end
	end

	function scaffold:resize(w, h)
		applySize(self)
		if self.child then
			self.child:resize(w, h)
		end
	end

	function scaffold:update(dt)
		if self.child then
			self.child:update(dt)
		end
	end

	function scaffold:draw()
		love.graphics.setBackgroundColor(unpack(self.bgColor))
		if self.child then
			self.child:draw()
		end
	end

	return scaffold
end

function builder:newContainer(args)
	args = args or {}
	local container = {}
	container.color = args.color or { 0.0, 0.0, 0.0, 0.0 }
	container.child = args.child or nil
	container.x = 0
	container.y = 0

	local function applySize(self)
		self.width = args.width or self.maxWidth or self.parent.width
		self.height = args.height or self.maxHeight or self.parent.height

		if self.maxWidth then
			self.width = math.min(self.width, self.maxWidth)
		end
		if self.maxHeight then
			self.height = math.min(self.height, self.maxHeight)
		end

		if self.child then
			self.child.maxWidth = self.width
			self.child.maxHeight = self.height
		end
	end

	function container:load()
		applySize(self)
		if self.child then
			self.child:load()
		end
	end

	function container:resize(w, h)
		applySize(self)
		if self.child then
			self.child:resize(w, h)
		end
	end

	function container:update(dt)
		if self.child then
			self.child:update(dt)
		end
	end

	function container:draw()
		love.graphics.push()
		love.graphics.translate(self.x, self.y)
		love.graphics.setColor(unpack(self.color))
		love.graphics.rectangle("fill", 0, 0, self.width, self.height)
		if self.child then
			self.child:draw()
		end
		love.graphics.pop()
	end

	return container
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
	button.x = 0
	button.y = 0

	local font = nil
	local currentMouseState
	local lastMouseState
	local hot = false

	local function applySize(self)
		if self.maxWidth then
			self.width = math.min(self.width, self.maxWidth)
		end
		if self.maxHeight then
			self.height = math.min(self.height, self.maxHeight)
		end
	end

	function button:load()
		font = love.graphics.newFont(self.fontSize)
		currentMouseState = love.mouse.isDown(1)
		applySize(self)
	end

	function button:resize(w, h)
		applySize(self)
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
		local ax, ay = getAbsPos(self)
		hot = mx > ax and mx < ax + self.width and my > ay and my < ay + self.height

		local color
		if self.active then
			color = hot and self.hotColor or self.color
		else
			color = self.inactiveColor
		end

		love.graphics.push()
		love.graphics.translate(self.x, self.y)

		love.graphics.setColor(unpack(color))
		love.graphics.rectangle("fill", 0, 0, self.width, self.height)

		local textH = font:getHeight(self.text)
		local textW = font:getWidth(self.text)

		love.graphics.setColor(unpack(self.textColor))
		love.graphics.print(self.text, font, (self.width * 0.5) - (textW * 0.5), (self.height * 0.5) - (textH * 0.5))

		love.graphics.pop()
	end

	return button
end

function builder:newColumn(args)
	args = args or {}
	local Column = {}
	Column.x = 0
	Column.y = 0
	Column.spacing = args.spacing or 0
	Column.crossAxisAlignment = args.crossAxisAlignment or "start"
	Column.children = args.children or {}

	function Column:load()
		for _, child in ipairs(self.children) do
			child.maxWidth = self.maxWidth
			child.maxHeight = self.maxHeight
			child:load()
		end
	end

	function Column:resize(w, h)
		for _, child in ipairs(self.children) do
			child.maxWidth = self.maxWidth
			child.maxHeight = self.maxHeight
			child:resize(w, h)
		end
	end

	function Column:update(dt)
		for _, child in ipairs(self.children) do
			child:update(dt)
		end
	end

	function Column:draw()
		love.graphics.push()
		love.graphics.translate(self.x, self.y)

		local offsetY = 0
		for _, child in ipairs(self.children) do
			if self.crossAxisAlignment == "center" then
				child.x = (self.parent.width * 0.5) - (child.width * 0.5)
			elseif self.crossAxisAlignment == "end" then
				child.x = self.parent.width - child.width
			else
				child.x = 0
			end

			child.y = offsetY
			child:draw()
			offsetY = offsetY + child.height + self.spacing
		end

		love.graphics.pop()
	end

	return Column
end

function builder:newRow(args)
	args = args or {}
	local Row = {}
	Row.x = 0
	Row.y = 0
	Row.spacing = args.spacing or 0
	Row.crossAxisAlignment = args.crossAxisAlignment or "start"
	Row.children = args.children or {}

	function Row:load()
		for _, child in ipairs(self.children) do
			child.maxWidth = self.maxWidth
			child.maxHeight = self.maxHeight
			child:load()
		end
	end

	function Row:resize(w, h)
		for _, child in ipairs(self.children) do
			child.maxWidth = self.maxWidth
			child.maxHeight = self.maxHeight
			child:resize(w, h)
		end
	end

	function Row:update(dt)
		for _, child in ipairs(self.children) do
			child:update(dt)
		end
	end

	function Row:draw()
		love.graphics.push()
		love.graphics.translate(self.x, self.y)

		local offsetX = 0
		for _, child in ipairs(self.children) do
			if self.crossAxisAlignment == "center" then
				child.y = (self.parent.height * 0.5) - (child.height * 0.5)
			elseif self.crossAxisAlignment == "end" then
				child.y = self.parent.height - child.height
			else
				child.y = 0
			end

			child.x = offsetX
			child:draw()
			offsetX = offsetX + child.width + self.spacing
		end

		love.graphics.pop()
	end

	return Row
end

return builder
