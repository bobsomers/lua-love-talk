require "hump/vector"

-- ball information
ball = {
	pos = vector(500, 500),
	size = vector(32, 32),
	speed = vector(1, -1):normalize_inplace() * 150,
	img = {}
}

-- block data
blocks = {
	size = vector(80, 20),
	img = {}
}

-- game load
function love.load()
	-- load graphics resources
	ball.img.cry = love.graphics.newImage("ball/cry.png")
	blocks.img.red = love.graphics.newImage("blocks/red.png")
	blocks.img.green = love.graphics.newImage("blocks/green.png")
	blocks.img.blue = love.graphics.newImage("blocks/blue.png")
	
	-- layout the blocks
	layout_blocks()
	
	-- set background color
	love.graphics.setBackgroundColor(255, 255, 255)
end

-- update
function love.update(dt)
	-- move the ball
	ball.pos = ball.pos + (ball.speed * dt)
	
	-- check for collisions with the walls
	if ball.pos.x < 0 then
		ball.pos.x = 0
		ball.speed.x = ball.speed.x * -1
	elseif ball.pos.x + ball.size.x > 800 then
		ball.pos.x = 800 - ball.size.x
		ball.speed.x = ball.speed.x * -1
	end
	if ball.pos.y < 0 then
		ball.pos.y = 0
		ball.speed.y = ball.speed.y * -1
	elseif ball.pos.y + ball.size.y > 600 then
		ball.pos.y = 600 - ball.size.y
		ball.speed.y = ball.speed.y * -1
	end
	
	-- check for collisions with the blocks
	for i = 0, 9 do
		for j = 0, 4 do
			-- calculate which block, as well as its x and y position
			local index = i + (10 * j)
			local x = i * blocks.size.x
			local y = j * blocks.size.y
			
			-- only check collisions if block exists
			if blocks[index] ~= 0 then
				-- bottom, top, left, right
				if ball.pos.y < y + blocks.size.y and (ball.pos.x < x + blocks.size.x or ball.pos.x + ball.size.x > x) then
					ball.pos.y = y + blocks.size.y
					ball.speed.y = ball.speed.y * -1
				elseif ball.pos.y + ball.size.y > y and (ball.pos.x < x + blocks.size.x or ball.pos.x + ball.size.x > x) then
					ball.pos.y = y - ball.size.y
					ball.speed.y = ball.speed.y * -1
				elseif ball.pos.x < x + blocks.size.x and (ball.pos.y < y + blocks.size.y or ball.pos.y + ball.size.y > y) then
					ball.pos.x = x + blocks.size.x
					ball.speed.x = ball.speed.x * -1
				elseif ball.pos.x + ball.size.x > x and (ball.pos.y < y + blocks.size.y or ball.pos.y + ball.size.y > y) then
					ball.pos.x = x - ball.size.x
					ball.speed.x = ball.speed.x * -1]]--
				end
			end
		end
	end
end

-- draw
function love.draw()
	-- draw the blocks
	for i = 0, 9 do
		for j = 0, 4 do
			-- calculate which block, as well as its x and y position
			local index = i + (10 * j)
			local x = i * blocks.size.x
			local y = j * blocks.size.y
			
			if blocks[index] == 1 then -- red
				love.graphics.draw(blocks.img.red, x, y)
			elseif blocks[index] == 2 then -- green
				love.graphics.draw(blocks.img.green, x, y)
			elseif blocks[index] == 3 then -- blue
				love.graphics.draw(blocks.img.blue, x, y)
			end
		end
	end

	-- draw the ball
	love.graphics.draw(ball.img.cry, ball.pos.x, ball.pos.y)
end

-- layout blocks
function layout_blocks()
	for i = 0, 9 do
		for j = 0, 4 do
			local index = i + (10 * j)
			local clr = (index % 3) + 1
			
			blocks[index] = clr
		end
	end
end