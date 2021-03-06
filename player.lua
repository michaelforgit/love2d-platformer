Player = Object:extend(Object);
bullets = {};
function Player:new()
    self.jump = 0;
    self.speed = 150;
    self.x = 0;
    self.y = 0;
    self.height = 48;
    self.width = 48;
    self.direction = 1;
    self.collider = world:newRectangleCollider(self.x, self.y, self.width-30, self.height-12)
    self.collider:setCollisionClass("Player");
    self.collider:setFixedRotation(true);
    self.collider:setObject(self);
end

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end
timer = 0;
animation = newAnimation(love.graphics.newImage("assets/images/teamgunner/CHARACTER_SPRITES/Black/Gunner_Black_Run.png"), 48, 48, 1)
debounce = false;
function Player:update(dt)
    self.x = self.collider:getX()-self.width/2;
    self.y = self.collider:getY()-self.height/2;
    local vx = 0;
    jumpHeight = 5;
    gravity = 9.81;
    initJumpVelocity = math.sqrt(2*gravity*jumpHeight);
    initImpulse = self.collider:getMass()*initJumpVelocity;
    if (love.keyboard.isDown("up")) and (self.jump==0) then
        self.collider:applyLinearImpulse(0, -325); ---300
        self.jump = 1;
        return;
    end
    if love.keyboard.isDown("right") then
        vx = self.speed * 1;
        self.direction = 1
    end  
    if love.keyboard.isDown("left") then
        vx = self.speed * -1;
        self.direction = -1
    end     
    _, vy = self.collider:getLinearVelocity();  --[[Throw away useless first return value]]
    self.collider:setLinearVelocity(vx, vy);

    if self.collider:enter("Platform") or self.collider:enter("Floor") then
        self.jump = 0;
    end
    timer = timer + dt;
    --print(timer);
    if timer >=.2 then
        debounce = true;
        timer = 0;
    end

    if love.keyboard.isDown("space") and debounce then
        debounce = false;
        table.insert(listOfBullets, Bullet(self.x+self.width/2, self.y, self.direction));
    end

    animation.currentTime = animation.currentTime + dt;
    if animation.currentTime >= animation.duration then
        animation.currentTime = animation.currentTime - animation.duration;
    end
end

function Player:draw()

    local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1;
    if self.direction == -1 then
        love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.x, self.y, 0, -1, 1, self.width, -3);
    else
        love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.x, self.y, 0, 1, 1, 0, -3);
    end
end

