require "hump.vector"
require "hump.camera"

-- convenience
local vector = hump.vector
local camera = hump.camera

-- "constants"
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ARENA_WIDTH = 2400
ARENA_HEIGHT = 400

-- data about the walls
walls = {
	left = {},
	right = {},
	top = {},
	bottom = {},
}

-- data about the ball
ball = {
    RADIUS = 50
}

-- data about the boxes
boxes = {}

-- what state is the game in? (starting, playing, finished)
state = "starting"

function love.load()
	-- convenience
	local gfx = love.graphics
	local phys = love.physics

	-- set background color
	gfx.setBackgroundColor(220, 220, 220)
	
	-- camera
	cam = camera.new(vector.new(SCREEN_WIDTH / 4, ARENA_HEIGHT / 2))
	cam.moving = false
	cam.lastCoords = vector.new(-1, -1)
	
	-- create a new physics world
	world = phys.newWorld(0, 0, ARENA_WIDTH, ARENA_HEIGHT)
    world:setGravity(0, 350)
	
	-- define our walls
	walls.left.body = phys.newBody(world, 2, ARENA_HEIGHT / 2, 0, 0)
	walls.left.shape = phys.newRectangleShape(walls.left.body, 0, 0, 5, ARENA_HEIGHT, 0)
	walls.right.body = phys.newBody(world, ARENA_WIDTH - 2, ARENA_HEIGHT / 2, 0, 0)
	walls.right.shape = phys.newRectangleShape(walls.right.body, 0, 0, 5, ARENA_HEIGHT, 0)
	walls.top.body = phys.newBody(world, ARENA_WIDTH / 2, 2, 0, 0)
	walls.top.shape = phys.newRectangleShape(walls.top.body, 0, 0, ARENA_WIDTH, 5, 0)
	walls.bottom.body = phys.newBody(world, ARENA_WIDTH / 2, ARENA_HEIGHT - 2, 0, 0)
	walls.bottom.shape = phys.newRectangleShape(walls.bottom.body, 0, 0, ARENA_WIDTH, 5, 0)
    
    -- define the ball
    ball.img = gfx.newImage("ball.png")
    ball.body = phys.newBody(world, 2 * ball.RADIUS, ARENA_HEIGHT / 2, 10, 15)
    ball.shape = phys.newCircleShape(ball.body, 0, 0, ball.RADIUS)
    ball.shape:setRestitution(0.5)
    
    -- define the boxes
    boxes[1] = {}
    boxes[1].body = phys.newBody(world, ARENA_WIDTH / 5, ARENA_HEIGHT / 2, 5, 0)
    boxes[1].shape = phys.newRectangleShape(boxes[1].body, 0, 0, 75, 75)
    boxes[2] = {}
    boxes[2].body = phys.newBody(world, 2 * ARENA_WIDTH / 5, ARENA_HEIGHT / 2, 5, 0)
    boxes[2].shape = phys.newRectangleShape(boxes[2].body, 0, 0, 25, 200)
    boxes[3] = {}
    boxes[3].body = phys.newBody(world, 3 * ARENA_WIDTH / 5, ARENA_HEIGHT / 2, 5, 0)
    boxes[3].shape = phys.newRectangleShape(boxes[3].body, 0, 0, 75, 75)
    boxes[4] = {}
    boxes[4].body = phys.newBody(world, 4 * ARENA_WIDTH / 5, ARENA_HEIGHT / 2, 5, 0)
    boxes[4].shape = phys.newRectangleShape(boxes[4].body, 0, 0, 25, 200)
end

function love.update(dt)
    -- update based on the state
    if state == "playing" then
        
        -- apply 1000 units/sec force in the x direction
        ball.body:applyForce(1000 * dt, 0)

        -- update the physics world
        world:update(dt)
        
    elseif state == "finished" then
        
        -- update the physics world
        world:update(dt)
        
    end
    
    -- always update camera
    cam.pos = vector.new(ball.body:getX(), ball.body:getY() - 100)
    
    -- check for win condition
    if ball.body:getX() > ARENA_WIDTH - 150 then
        state = "finished"
    end
end

function drawSimpleRect(obj)
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

	-- draw arena
	gfx.setColor(255, 255, 255)
	gfx.rectangle("fill", 0, 0, ARENA_WIDTH, ARENA_HEIGHT)
	
    -- draw "win zone"
    gfx.setColor(0, 255, 0, 100)
    gfx.rectangle("fill", ARENA_WIDTH - 150, 0, 150, ARENA_HEIGHT)
    
	-- draw walls
	gfx.setColor(0, 0, 0)
	drawSimpleRect(walls.left)
	drawSimpleRect(walls.right)
	drawSimpleRect(walls.top)
	drawSimpleRect(walls.bottom)
    
    -- draw boxes
    gfx.setColor(200, 0, 0)    
    drawSimpleRect(boxes[1])
    gfx.setColor(0, 200, 0)
    drawSimpleRect(boxes[2])
    gfx.setColor(0, 0, 200)
    drawSimpleRect(boxes[3])
    gfx.setColor(0, 200, 200)
    drawSimpleRect(boxes[4])
    
    -- draw ball
    gfx.setColor(255, 255, 255)
    gfx.draw(ball.img, ball.body:getX(), ball.body:getY(), ball.body:getAngle(), 1, 1, ball.RADIUS, ball.RADIUS)

	-- done drawing the world
	cam:postdraw()
    
    if state == "finished" then
        gfx.setColor(0, 0, 0)
        gfx.print("YOU WIN!", 300, 250, 0, 3, 3)
    end
end

function love.keypressed(key, unicode)
    if key == " " and ball.body:getY() > ARENA_HEIGHT - ball.RADIUS - 20 then
        ball.body:applyImpulse(0, 280)
    end
end

function love.mousepressed(x, y, button)
    if state == "starting" then
    
        if button == "l" then
            -- start the game!
            state = "playing"
        end
    
    elseif state == "finished" then
    
        if button == "l" then
            -- reset the game!
            state = "playing"
            ball.body:setPosition(2 * ball.RADIUS, ARENA_HEIGHT / 2)
            ball.body:setLinearVelocity(0, 0)
            ball.body:setAngularVelocity(0)
        end
    
    end
end