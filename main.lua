require "hump/vector"
require "hump/camera"

-- "constants"
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ARENA_WIDTH = 2400
ARENA_HEIGHT = 200

-- data about the walls
walls = {
	left = {},
	right = {},
	top = {},
	bottom = {},
}

-- data about the house
house = {
	radius = 75
}

-- data about the stones
stones = {}

function love.load()
	-- randomize the madness
	--math.randomseed(love.timer.getMicroTime())
	
	-- set background color
	love.graphics.setBackgroundColor(220, 220, 220)
	
	-- camera
	cam = Camera(vector(SCREEN_WIDTH / 4, ARENA_HEIGHT / 2))
	cam.moving = false
	cam.lastCoords = vector(-1, -1)
	
	-- create a new physics world
	world = love.physics.newWorld(0, 0, ARENA_WIDTH, ARENA_HEIGHT)
	world:setGravity(0, 0)
	world:setMeter(48)
	
	-- define our walls
	walls.left.body = love.physics.newBody(world, 2, ARENA_HEIGHT / 2, 0, 0)
	walls.left.shape = love.physics.newRectangleShape(walls.left.body, 0, 0, 5, ARENA_HEIGHT, 0)
	walls.right.body = love.physics.newBody(world, ARENA_WIDTH - 2, ARENA_HEIGHT / 2, 0, 0)
	walls.right.shape = love.physics.newRectangleShape(walls.right.body, 0, 0, 5, ARENA_HEIGHT, 0)
	walls.top.body = love.physics.newBody(world, ARENA_WIDTH / 2, 2, 0, 0)
	walls.top.shape = love.physics.newRectangleShape(walls.top.body, 0, 0, ARENA_WIDTH, 5, 0)
	walls.bottom.body = love.physics.newBody(world, ARENA_WIDTH / 2, ARENA_HEIGHT - 2, 0, 0)
	walls.bottom.shape = love.physics.newRectangleShape(walls.bottom.body, 0, 0, ARENA_WIDTH, 5, 0)
	
	-- define the house
	house.body = love.physics.newBody(world, ARENA_WIDTH - (3 * house.radius), ARENA_HEIGHT / 2, 0, 0)
	house.shape = love.physics.newCircleShape(house.body, 0, 0, house.radius)
	
	-- ball settings
	--[[
	ball.body = love.physics.newBody(world, 400, 300, 15, 10)
	ball.body:setLinearDamping(0.3)
	ball.body:setAngularDamping(0.3)
	ball.shape = love.physics.newCircleShape(ball.body, 0, 0, 24)
	ball.shape:setRestitution(0.5)
	ball.img = love.graphics.newImage("ball/cry.png")
	]]--
	
	-- pick a random sector for the goal
	--[[
	local randX = math.random(4)
	local randY = math.random(3)
	goal.sector = randX * randY
	goal.body = love.physics.newBody(world, 100 + ((randX - 1) * 200), 100 + ((randY - 1) * 200), 0, 0)
	goal.shape = love.physics.newRectangleShape(goal.body, 0, 0, 150, 150, 0)
	goal.shape:setSensor(true)
	]]--
end

function love.update(dt)
	if love.keyboard.isDown("right") then
		cam:translate(vector(5, 0))
	end
	if love.keyboard.isDown("left") then
		cam:translate(vector(-5, 0))
	end
	if love.keyboard.isDown("up") then
		cam:translate(vector(0, -5))
	end
	if love.keyboard.isDown("down") then
		cam:translate(vector(0, 5))
	end
	
	-- move the camera
	if cam.moving then
		local pos = cam:mousepos()
		local delta = cam.clickPos - pos
		cam:translate(delta)
	end

	-- update the physics world
	--world:update(dt)
	
	-- has the ball come to rest?
	--[[
	local x, y = ball.body:getLinearVelocity()
	local speed = vector(x, y):len()
	if speed > 0 and speed < 2 then
		ball.status = "waiting"
		ball.body:setLinearVelocity(0, 0)
		ball.shape:setSensor(true)
	end
	]]--
end

function drawPhysicsRectangle(obj)
	local x1, y1, x2, y2, x3, y3, x4, y4 = obj.shape:getBoundingBox()
	local w = x3 - x2
	local h = y2 - y1
	love.graphics.rectangle("fill", obj.body:getX() - (w / 2), obj.body:getY() - (h / 2), w, h)
end

function love.draw()
	-- convenience
	local gfx = love.graphics

	-- draw the world
	cam:predraw()

	-- draw ice
	gfx.setColor(255, 255, 255)
	gfx.rectangle("fill", 0, 0, ARENA_WIDTH, ARENA_HEIGHT)
	
	-- draw walls
	gfx.setColor(0, 0, 0)
	drawPhysicsRectangle(walls.left)
	drawPhysicsRectangle(walls.right)
	drawPhysicsRectangle(walls.top)
	drawPhysicsRectangle(walls.bottom)
	
	-- draw house
	gfx.setColor(0, 0, 255)
	gfx.circle("fill", house.body:getX(), house.body:getY(), house.radius, 50)
	gfx.setColor(255, 255, 255)
	gfx.circle("fill", house.body:getX(), house.body:getY(), house.radius * 2 / 3, 50)
	gfx.setColor(255, 0, 0)
	gfx.circle("fill", house.body:getX(), house.body:getY(), house.radius / 3, 25)
	gfx.setColor(255, 255, 255)
	gfx.circle("fill", house.body:getX(), house.body:getY(), 5, 10)

	-- done drawing the world
	cam:postdraw()
	
	-- draw launch vector
	--[[
	if launch_focus.x > -1 then
		love.graphics.setColor(255, 0, 0)
		love.graphics.setLine(3, "smooth")
		love.graphics.line(launch_focus.x, launch_focus.y, love.mouse.getX(), love.mouse.getY())
	end
	]]--

	-- draw ball
	--[[
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
	]]--
end

function love.mousepressed(x, y, button)
	-- handle zooming
	if button == "wd" then
		cam.zoom = cam.zoom - 0.1
		if cam.zoom < 0.3 then cam.zoom = 0.3 end
	end
	if button == "wu" then
		cam.zoom = cam.zoom + 0.1
		if cam.zoom > 2.0 then cam.zoom = 2.0 end
	end

	-- handle right click moving
	if button == "r" then
		cam.moving = true
		cam.clickPos = cam:mousepos()
	end

	--[[
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
	]]--
end

function love.mousereleased(x, y, button)
	-- handle right click moving
	if button == "r" then
		cam.moving = false
	end

	--[[
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
	]]--
end