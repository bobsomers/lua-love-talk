require "hump/vector"

-- info about the arena walls
arena = {
	left = {},
	right = {},
	top = {},
	bottom = {},
}

-- data about the ball
ball = {
	status = "waiting"
}

-- data about our foes
foes = {}

-- data about the goal
goal = {}

-- focus of the launch vector
launch_focus = vector(-1, -1)

function love.load()
	-- randomize the madness
	math.randomseed(love.timer.getMicroTime())
	
	-- set background color
	love.graphics.setBackgroundColor(255, 255, 255)
	
	-- create a new physics world
	world = love.physics.newWorld(0, 0, 800, 600)
	world:setGravity(0, 0)
	world:setMeter(48)
	
	-- define extents of the arena	
	arena.left.body = love.physics.newBody(world, 0, 300, 0, 0)
	arena.left.shape = love.physics.newRectangleShape(arena.left.body, 0, 0, 5, 600, 0)
	arena.right.body = love.physics.newBody(world, 800, 300, 0, 0)
	arena.right.shape = love.physics.newRectangleShape(arena.right.body, 0, 0, 5, 600, 0)
	arena.top.body = love.physics.newBody(world, 400, 0, 0, 0)
	arena.top.shape = love.physics.newRectangleShape(arena.top.body, 0, 0, 800, 5, 0)
	arena.bottom.body = love.physics.newBody(world, 400, 600, 0, 0)
	arena.bottom.shape = love.physics.newRectangleShape(arena.bottom.body, 0, 0, 800, 5, 0)
	
	-- ball settings
	ball.body = love.physics.newBody(world, 400, 300, 15, 10)
	ball.body:setLinearDamping(0.3)
	ball.body:setAngularDamping(0.3)
	ball.shape = love.physics.newCircleShape(ball.body, 0, 0, 24)
	ball.shape:setRestitution(0.5)
	ball.img = love.graphics.newImage("ball/cry.png")
	
	-- pick a random sector for the goal
	local randX = math.random(4)
	local randY = math.random(3)
	goal.sector = randX * randY
	goal.body = love.physics.newBody(world, 100 + ((randX - 1) * 200), 100 + ((randY - 1) * 200), 0, 0)
	goal.shape = love.physics.newRectangleShape(goal.body, 0, 0, 150, 150, 0)
	goal.shape:setSensor(true)
end

function love.update(dt)
	-- update the physics world
	world:update(dt)
	
	-- has the ball come to rest?
	local x, y = ball.body:getLinearVelocity()
	local speed = vector(x, y):len()
	if speed > 0 and speed < 2 then
		ball.status = "waiting"
		ball.body:setLinearVelocity(0, 0)
		ball.shape:setSensor(true)
	end
end

function love.draw()
	-- draw goal
	local x1, y1, x2, y2, x3, y3, x4, y4 = goal.shape:getBoundingBox()
	local boxW = x3 - x2
	local boxH = y2 - y1
	love.graphics.setColor(200, 255, 200)
	love.graphics.rectangle("fill", goal.body:getX() - (boxW / 2), goal.body:getY() - (boxH / 2), boxW, boxH)
	love.graphics.setColor(0, 255, 0)
	love.graphics.setLine(2, "smooth")
	love.graphics.rectangle("line", goal.body:getX() - (boxW / 2), goal.body:getY() - (boxH / 2), boxW, boxH)

	-- draw launch vector
	if launch_focus.x > -1 then
		love.graphics.setColor(255, 0, 0)
		love.graphics.setLine(3, "smooth")
		love.graphics.line(launch_focus.x, launch_focus.y, love.mouse.getX(), love.mouse.getY())
	end

	-- draw ball
	if ball.status ~= "waiting" then
		local x = 0
		local y = 0
		
		if ball.status == "prepping" then
			x = love.mouse.getX()
			y = love.mouse.getY()
			love.graphics.setColor(255, 255, 255, 127)
		else
			x = ball.body:getX()
			y = ball.body:getY()
			love.graphics.setColor(255, 255, 255, 255)
		end
		
		love.graphics.draw(ball.img, x, y, ball.body:getAngle(), 1, 1, 24, 24)
	end
end

function love.mousepressed(x, y, button)
	if button == "l" then
		-- prep ball for launch
		launch_focus.x = x
		launch_focus.y = y
		ball.status = "prepping"
		ball.shape:setSensor(true)
		ball.body:setLinearVelocity(0, 0)
		ball.body:setAngularVelocity(0)
		ball.body:setAngle(0)
	elseif button == "r" and launch_focus.x > -1 then
		-- cancel launch
		launch_focus.x = -1
		launch_focus.y = -1
		ball.status = "waiting"
		ball.shape:setSensor(true)
	end
end

function love.mousereleased(x, y, button)
	if button == "l" and launch_focus.x > -1 then
		-- successful launch!
		ball.status = "launched"
		ball.shape:setSensor(false)
		ball.body:setX(x)
		ball.body:setY(y)
		
		local impulse = vector(launch_focus.x - x, launch_focus.y - y) / 2
		ball.body:applyImpulse(impulse.x, impulse.y)
		
		launch_focus.x = -1
		launch_focus.y = -1
	end
end