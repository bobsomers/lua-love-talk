require "hump.vector"
require "hump.camera"

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
end

function love.update(dt)
	-- update the physics world
	world:update(dt)
    
    -- update camera
    cam.pos = vector.new(ball.body:getX(), ball.body:getY() - 100)
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

	-- draw arena
	gfx.setColor(255, 255, 255)
	gfx.rectangle("fill", 0, 0, ARENA_WIDTH, ARENA_HEIGHT)
	
	-- draw walls
	gfx.setColor(0, 0, 0)
	drawPhysicsRectangle(walls.left)
	drawPhysicsRectangle(walls.right)
	drawPhysicsRectangle(walls.top)
	drawPhysicsRectangle(walls.bottom)
    
    -- draw ball
    gfx.setColor(255, 255, 255)
    gfx.draw(ball.img, ball.body:getX(), ball.body:getY(), ball.body:getAngle(), 1, 1, ball.RADIUS, ball.RADIUS)

	-- done drawing the world
	cam:postdraw()
end

function love.keypressed(key, unicode)
    if key == " " and ball.body:getY() > ARENA_HEIGHT - ball.RADIUS - 20 then
        ball.body:applyImpulse(0, 280)
    end
end