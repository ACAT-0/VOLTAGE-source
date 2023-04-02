love.graphics.setDefaultFilter("nearest", "nearest")
local moonshine = require 'moonshine'
-- require 'vmodloader'



ScreenGfx = {
   scan = moonshine.effects.scanlines,
   crt = moonshine.effects.crt,
   glow = moonshine.effects.glow
}


-- Vector Library START (without require(), for conveinecnce)

function Vector(x, y)
   return {
      x = x,
      y = y,
      Add = function(self, add)
         self.x = self.x + add.x
         self.y = self.y + add.y
      end,
      AddRet = function(self, add)
         return Vector(
            self.x + add.x,
            self.y + add.y
         )
      end,
      Sub = function(self, add)
         self.x = self.x - add.x
         self.y = self.y - add.y
      end,
      Multi = function(self, multi)
         return Vector(self.x * multi, self.y * multi)
      end,
      Div = function(self, add)

      end,
      toAngle = function(self)
         local out = math.atan(self.y / self.x)
         out = out * (180 / math.pi)
         return out
      end,
      toString = function(self)
         local str = "{ "
         str = str .. "x: " .. self.x .. " / "
         str = str .. "y: " .. self.y .. " / "
         str = str .. "}"
         return str
      end,
      Normalize = function(self)
         local length = math.sqrt((self.x * self.x) + (self.y * self.y))
         return Vector(
            self.x / length,
            self.y / length
         )
      end,
      GetDiff = function(self, p2)
         local out = Vector(p2.x - self.x, p2.y - self.y)
         return out
      end,
      METATYPE = "VECTOR",
   }
end

function GetDiff(p1, p2)
   local out = Vector(p2.x - p1.x, p2.y - p1.y)
   return out
end

-- Vector Library END

-- Useful Functions
function indexOf(array, value)
   for i, v in ipairs(array) do
      if v == value then
         return i
      end
   end
   return nil
end

function table.contains(list, item)
   for i, v in pairs(list) do
      if v == item then return true end
   end
   return false
end

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
   return x1 < x2 + w2 and
       x2 < x1 + w1 and
       y1 < y2 + h2 and
       y2 < y1 + h1
end

function CheckCollsionFromOrigin(ox1, oy1, ox2, oy2)
   local x1 = ox1 - ox1
   local y1 = oy1 - oy1
   local w1 = ox1 * 2
   local h1 = oy1 * 2
   local x2 = ox2 - ox2
   local y2 = oy2 - oy2
   local w2 = ox2 * 2
   local h2 = oy2 * 2
   return CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
end

function TableLength(T)
   local count = 0
   for _ in pairs(T) do count = count + 1 end
   return count
end

-- Useful Functions END


--here are our bullettags
BulletTags = {
   Normal = 1,
   Decelerate = 2,
   Spiral = 3,
   Wiggle = 4,
   Player = 5,
   Accelerate = 6,
   Mark = 7,
   Bloodlust = 8,
   Mike = 9,
   Points = 10,
}

EntityType = {
   Cont = 1,
   Item = 2,
   BasicEnemy = 3,
   Horiz = 4,
   Idly = 5,
   Quadro = 6,
   Kapow = 7,
   Gorbix = 8,
   Cirrus = 9,
   Perix = 10,
}

--creates a new bullet object
function Bullet()
   return {
      Position = Vector(0, 0),
      Velocity = Vector(0, 0),
      Sprite = nil,
      Tags = {},
      Lifetime = 100,
      FrameCt = 0,
   }
end

function Entity(type)
   return {
      Position = Vector(0, 0),
      Velocity = Vector(0, 0),
      Sprite = nil,
      Tags = {},
      Type = type,
      FrameCt = 0,
      I1 = 0,
      I2 = 0,
      CollisionSize = 20,
      HitPoints = 4,
      Direction = 1,
      FrameIndex = 0,
      Conditions = {},
      Scale = Vector(love.math.random(5, 5.5), love.math.random(2.5, 3)),
      AddCondition = function(self, con)
         table.insert(self.Conditions, con)
      end
   }
end

function PickUp(pos, healamt)
   return {
      Sprite = pickupsprite,
      Position = pos,
      HealAmount = healamt,
      Scale = Vector(5, 3),
      FrameCt = 0,
   }
end

function Gfx(pos, spr)
   return {
      Position = pos,
      Sprite = gfxsprites[spr]
   }
end

function Item(sprite, title, description, heal)
   if heal == nil then
      heal = 0
   end
   return {
      Sprite = sprite,
      Name = title,
      Description = description,
      heal = heal,
   }
end

function AddtoBulletCache(obj)
   table.insert(Bullets, obj)
end

function AddtoNPCcache(obj)
   table.insert(Entities, obj)
end

function AddGFX(obj)
   table.insert(GfxCache, obj)
end

function SpawnPickup(pickup)
   table.insert(Pickups, pickup)
end

Items = {
   quickfinger = Item(love.graphics.newImage("items/quickfinger.png"), "quick fingers", "fire faster"),
   ppowergoo = Item(love.graphics.newImage("items/powergoo.png"), "power goo", "bullet power up"),
   gear = Item(love.graphics.newImage("items/gear.png"), "cog", "fire more \n pack less punch"),
   plasmaball = Item(love.graphics.newImage("items/plasmaball.png"), "plasma ball", "static power"),
   huntersmark = Item(love.graphics.newImage("items/huntermark.png"), "hunter's mark",
      "chance to mark enemies for dead \n marked enemies take extra damage"),
   gunboots = Item(love.graphics.newImage("items/gunboots.png"), "gun boots", "move as fast as you can shoot"),
   mike = Item(love.graphics.newImage("items/mike.png"), "mike", "strength boosting friend"),
   megabullet = Item(love.graphics.newImage("items/megabullet.png"), "mega bullet", "massive bullets \n fire much less"),
   panic = Item(love.graphics.newImage("items/panic.png"), "panic", "hyperventilate your trigger"),
   bandaid = Item(love.graphics.newImage("items/bandaid.png"), "bandaid", "heal", 4),
   energydrink = Item(love.graphics.newImage("items/energydrink.png"), "energy drink",
      "chug a monster \n hyperactive fire rate"),
   stopwatch = Item(love.graphics.newImage("items/stopwatch.png"), "stop watch", "slow time down to a crawl"),
   timegun = Item(love.graphics.newImage("items/timegun.png"), "hourglass", "fire through time"),
   carl = Item(love.graphics.newImage("items/carl.png"), "carl", "mike's beloved child \n plays baseball sometimes"),
   heartbox = Item(love.graphics.newImage("items/heartbox.png"), "heart shaped box",
      "locked within \n health up + blood is fuel", 2),
   rocketbullet = Item(love.graphics.newImage("items/rocketbulllet.png"), "rocket bullets",
      "shots go vroooooom zyooom \n less knockback"),
   supermike = Item(love.graphics.newImage("items/mike.png"), "SUPER MIKE", "teehee you found him \n mike bullets"),
   fist = Item(love.graphics.newImage('items/fist.png'), "fist", "melee shot"),
   pact = Item(love.graphics.newImage('items/pact.png'), "pact of the fragile",
      "one hit kill\ndestroy your foes"),
   chronos = Item(love.graphics.newImage('items/chronos.png'), "pact of chronos",
      "permanent slowdown\nextreme pain"),
   rebound = Item(love.graphics.newImage("items/rebound.png"), "re-bound", "bullets bounce back"),
   venom = Item(love.graphics.newImage('items/venom.png'), "venomous",
      "bullets instantly kill enemies below 5 hp"),
   flare = Item(love.graphics.newImage('items/flare.png'), "flare gun",
      "bullets can set enemies on fire"),
   muscle = Item(love.graphics.newImage('items/mymom.png'), "MUSCLES",
      "kerpow bang crash smash\nless range"),
   medkit = Item(love.graphics.newImage('items/medkit.png'), "medkit", "free heal \n+3 hp", 3)
}

function Quadshot(pos, offset, multi)
   local bullet = Bullet()
   bullet.Position = pos:Multi(1)
   bullet.Velocity = Vector(1 * multi, 0 - offset)
   bullet.Sprite = BulletVariants.Normal
   table.insert(Bullets, bullet)
   bullet = Bullet()
   bullet.Position = pos:Multi(1)
   bullet.Velocity = Vector(-1 * multi, 0 + offset)
   bullet.Sprite = BulletVariants.Normal
   table.insert(Bullets, bullet)
   bullet = Bullet()
   bullet.Position = pos:Multi(1)
   bullet.Velocity = Vector(0 - offset, -1 * multi)
   bullet.Sprite = BulletVariants.Normal
   table.insert(Bullets, bullet)
   bullet = Bullet()
   bullet.Position = pos:Multi(1)
   bullet.Velocity = Vector(0 + offset, 1 * multi)
   bullet.Sprite = BulletVariants.Normal
   table.insert(Bullets, bullet)
end

function Reset()
   -- love.load()
   p.HitPoints = 4
   Wave = 0
   EnemiesKilled = 0
   p.Items = {}
   Entities = {}
   Bullets = {}
   GfxCache = {}
   TimeUntilNextWave = 100
   GameState = "play"
   p.Position = Vector(450, 450)
   Points = 0
   PointMult = 1
end

--[[
love.load


]]
function love.load()
   love.window.setMode(960, 960)
   love.graphics.setDefaultFilter("nearest", "nearest")
   Screenshake = 1

   GfxChain = moonshine.chain(ScreenGfx.scan)
   GfxChain.scanlines.frequency = love.graphics.getHeight() / 4
   GfxChain.scanlines.opacity = 0.1
   GfxChain.resize(960, 960)
   GfxChain = GfxChain.chain(ScreenGfx.crt)
   GfxChain.crt.distortionFactor = { 1.05, 1.05 }
   -- GfxChain = GfxChain.chain(moonshine.effects.chromasep)
   -- GfxChain.chromasep.radius = 0
   GfxChain = GfxChain.chain(moonshine.effects.pixelate)
   GfxChain.pixelate.size = { 0.05, 0.05 }
   GfxChain = GfxChain.chain(moonshine.effects.godsray)
   GfxChain.godsray.decay = 0

   GfxGlow = moonshine.chain(moonshine.effects.glow)
   GfxGlow.glow.strength = 10

   Debug = 0

   love.window.setTitle("VOLTAGE")
   FULLSCREEN = false
   SP = 30
   delta = 0
   Bullets = {}
   Entities = {}
   GfxCache = {}
   Pickups = {}
   TimeUntilNextWave = 100

   --IMPORTANT!
   GameState = "menu"

   gfxsprites = {
      love.graphics.newImage("particles/stain1.png"),
      love.graphics.newImage("particles/stain2.png"),
      love.graphics.newImage("particles/stain3.png"),
      love.graphics.newImage("particles/stain4.png"),
   }
   markedSprite = love.graphics.newImage("hud/mark.png")
   flareSprite = love.graphics.newImage("hud/flareparticle.png")
   --placeholder sprites for now
   BulletVariants = {
      Normal = love.graphics.newImage("bullets/bullet1.png"),
      Player = love.graphics.newImage("bullets/bullet2.png"),
      Point = love.graphics.newImage("bullets/points.png")
   }
   pickupsprite = love.graphics.newImage("hud/pickup.png")

   p = {
      s = 1,
      dir = 1,
      sprite = love.graphics.newImage("player/player.png"),
      Position = Vector(450, 450),
      Velocity = Vector(0, 0),
      Speed = (15 * SP) * delta,
      FireDelay = 0,
      MaxFireDelay = 10,
      Damage = 1,
      HitPoints = 4,
      ShootSFX = love.audio.newSource("sfx/playershoot1.wav", "static"),
      KnockbackMultiplier = 2,
      Items = {

      },
      Range = 50,
      MaxCooldown = 3,
      CanDash = true,
      IsDashing = false,
      CoolDown = 0,
      BulletTags = { BulletTags.Player },
      DeathSprite = love.graphics.newImage("player/player-gameover.png"),
      Rotation = 0,
      Scale = Vector(4, 4)
   }
   Alagard = love.graphics.newFont("alagard.ttf")
   PixAntiqua = love.graphics.newFont("PixAntiqua.ttf")

   Heart = love.graphics.newImage("hud/heart.png")
   p.ShootSFX:setPitch(3)
   EnemyShootSFX = love.audio.newSource("sfx/pewpew.wav", "static")
   EnemyShootSFX:setVolume(0.4)
   HorizShootSFX = love.audio.newSource("sfx/dash.wav", "static")
   EnemyDeathSFX = love.audio.newSource("sfx/enemydie.wav", "static")
   KapowSfx = love.audio.newSource("sfx/shotgun.wav", "static")
   KapowSfx:setVolume(0.2)
   CollectSfx = love.audio.newSource('sfx/collect.wav', 'static')
   CollectSfx:setVolume(0.2)
   dashy = 0
   dash = 0
   dashcool = 0
   EnemiesKilled = 0

   EntitySprites = {
      love.graphics.newImage("entities/staircase.png"),
      nil,
      love.graphics.newImage("enemies/pew.png"),
      love.graphics.newImage("enemies/horix.png"),
      love.graphics.newImage("enemies/idly.png"),
      love.graphics.newImage("enemies/quadro.png"),
      love.graphics.newImage("enemies/kapow.png"),
      love.graphics.newImage("enemies/gorb.png"),
      love.graphics.newImage("enemies/cirrus.png"),
      love.graphics.newImage("enemies/perix.png"),
      love.graphics.newImage("enemies/perix-2.png"),
   }

   Wave = 0
   Highscore = 0
   t = 0

   PointsParticle = love.graphics.newParticleSystem(BulletVariants.Point, 100)

   PointsParticle:setDirection(-1)
   PointsParticle:setEmissionRate(0)
   PointsParticle:setParticleLifetime(2)
   PointsParticle:setLinearAcceleration(10, -10, -10, 10)
   PointsParticle:setLinearDamping(0.1, 0.5)
   PointsParticle:setSpeed(0)

   AmbientLayer = love.audio.newSource("sfx/ambient.wav", "static")
   CombatLayer = love.audio.newSource("sfx/layer.wav", "static")
   AmbientLayer:setVolume(0.25)
   AmbientLayer:setLooping(true)
   CombatLayer:setVolume(0.25)
   CombatLayer:setLooping(true)
   -- CombatLayer:play()
   StartSfx = love.audio.newSource("sfx/start.wav", "static")
   StormSfx = love.audio.newSource("sfx/storm.wav", "static")
   StormSfx:setVolume(0.2)
   StormSfx:setPitch(0.7)
   StormSfx:setLooping(true)
   StormSfx:play()
   itemspawned = ""

   vmodloader = love.filesystem.load("vmodloader.lua")
   vmodloader()
end

--LOVE.LOAD END!!!

function EvaluateCache()
   p.Speed = 8
   p.KnockbackMultiplier = 2
   p.MaxFireDelay = 10
   p.Damage = 2
   p.Range = 35
   p.ShotSpeed = 50
   p.BulletTags = { BulletTags.Player }
   for i, item in pairs(p.Items) do
      if item == Items.quickfinger then
         p.MaxFireDelay = p.MaxFireDelay - 1
      elseif item == Items.ppowergoo then
         p.Damage = p.Damage + 0.5
         p.KnockbackMultiplier = p.KnockbackMultiplier + 0.2
         p.Damage = p.Damage * 0.9
      elseif item == Items.megabullet then
         p.Damage = p.Damage + 5
         table.insert(p.BulletTags, BulletTags.Decelerate)
      elseif item == Items.panic then
         p.MaxFireDelay = p.MaxFireDelay - 1.2
         p.MaxFireDelay = p.MaxFireDelay - ((6 - p.HitPoints) / 2)
      elseif item == Items.huntersmark then
         table.insert(p.BulletTags, BulletTags.Mark)
      elseif item == Items.carl then
         p.Range = p.Range + 20
      elseif item == Items.rocketbullet then
         p.ShotSpeed = p.ShotSpeed + 30
         p.KnockbackMultiplier = p.KnockbackMultiplier / 4
         table.insert(p.BulletTags, BulletTags.Accelerate)
      elseif item == Items.heartbox then
         table.insert(p.BulletTags, BulletTags.Bloodlust)
      elseif item == Items.supermike then
         table.insert(p.BulletTags, BulletTags.Mike)
      elseif item == Items.pact then
         p.Speed = p.Speed + 1
         p.Damage = p.Damage + 1
      elseif item == Items.muscle then
         p.Damage = p.Damage + 3
         p.Range = p.Range / 2
         p.Range = p.Range - 10
      elseif item == Items.fist then
         p.Damage = p.Damage + 10
         p.Range = 2
         p.KnockbackMultiplier = (p.KnockbackMultiplier + 4)
      elseif item.Modded == "yep" then
         p.Damage = p.Damage + item.Damage
         p.MaxFireDelay = p.MaxFireDelay + item.FireDelay
         p.Speed = p.Speed + item.Speed
         p.Range = p.Range + item.Range
         item.onUpdate()
      elseif item == nil then
      end
   end
   -- dmg mulitpliers go here !!
   for i, item in pairs(p.Items) do
      if item == Items.plasmaball then
         p.ShotSpeed = p.ShotSpeed + 10
         local modifier = p.Velocity.x + p.Velocity.y
         if modifier < 0 then modifier = modifier * -1 end
         p.Damage = p.Damage + modifier
      elseif item == Items.gunboots then
         p.Speed = p.Speed + (8 - (p.MaxFireDelay * 0.5))
      elseif item == Items.mike then
         p.Damage = p.Damage + 2
         p.Damage = p.Damage * 0.9
      elseif item == Items.gear then
         p.MaxFireDelay = p.MaxFireDelay * 0.9
         p.Damage = p.Damage * 0.9
      elseif item == Items.energydrink then
         p.MaxFireDelay = p.MaxFireDelay * 0.25
         p.Damage = p.Damage * 0.1
      elseif item == Items.megabullet then
         p.Damage = p.Damage * 2
         p.KnockbackMultiplier = p.KnockbackMultiplier * 2
         p.MaxFireDelay = p.MaxFireDelay * 2
      elseif item == Items.carl then
         p.MaxFireDelay = p.MaxFireDelay * 0.99
      elseif item == Items.pact then
         p.Damage = p.Damage * 10
         p.MaxireDelay = p.MaxFireDelay / 10
      end
   end

   if p.Speed < 4 then
      p.Speed = 4
   end
   if p.MaxFireDelay < 0 then
      p.MaxFireDelay = 0.1
   end
   p.Speed = (p.Speed * 45) * delta
end

function clearRoom()
   for i, entity in pairs(Entities) do
      table.remove(Entities, indexOf(Entities, entity))
   end
   for i, bullet in pairs(Bullets) do
      table.remove(Bullets, indexOf(Bullets, bullet))
   end
end

function Spawn(type, pos)
   local newentity = Entity(tonumber(type))
   AddtoNPCcache(newentity)
   newentity.Position = pos
   newentity.Sprite = EntitySprites[type]
   newentity.Velocity = Vector(0, 0)
   newentity.FrameCt = love.math.random(1, 30)
   if type == EntityType.BasicEnemy then
      newentity.HitPoints = 10
   elseif type == EntityType.Horiz then
      newentity.HitPoints = 8
   elseif type == EntityType.Idly then
      newentity.HitPoints = 6
   elseif type == EntityType.Quadro then
      newentity.HitPoints = 5
   elseif type == EntityType.Kapow then
      newentity.HitPoints = 20
   elseif type == EntityType.Gorbix then
      newentity.HitPoints = 15
   elseif type == EntityType.Cirrus then
      newentity.HitPoints = 12
   elseif type == EntityType.Perix then
      newentity.HitPoints = 40
   end
end

function SpawnItem(pos, item)
   local newentity = Entity(2)
   AddtoNPCcache(newentity)
   newentity.I1 = item
   newentity.Position = pos
   newentity.Sprite = item.Sprite
   newentity.Velocity = Vector(0, 0)
   newentity.FrameCt = 0
   newentity.HitPoints = 1
end

function SelectItem()
   -- Insert the keys of the table into an array
   local keys = {}

   for key, _ in pairs(Items) do
      table.insert(keys, key)
   end

   -- Get the amount of possible values
   local max = #keys
   local number = love.math.random(1, max)
   local selectedKey = keys[number]

   -- Return the value
   return Items[selectedKey]
end

function SelectMonster()
   if Wave <= 4 then
      return love.math.random(3, 5)
   elseif Wave <= 8 then
      return love.math.random(3, 6)
   elseif Wave > 8 then
      local out = love.math.random(3, 9)
      if out == 7 or out == 8 or out == 9 then
         out = love.math.random(3, 9)
      end
      return out
   end
end

function GetWaveMonsters()
   local output = love.math.random(math.floor(Wave / 2), math.ceil(Wave))
   if output < 6 then output = output + 6 end
   return output
end

function love.keypressed(key)
   if key == "a" then
      p.Scale.x = 2
      p.Scale.y = 5
   elseif key == "d" then
      p.Scale.x = 2
      p.Scale.y = 5
   elseif key == "w" then
      p.Scale.x = 5
      p.Scale.y = 2
   elseif key == "s" then
      p.Scale.x = 5
      p.Scale.y = 2
   end

   if key == 'escape' then
      if GameState == "pause" then
         GfxChain.crt.distortionFactor = { 1.05, 1.05 }
         CombatLayer:setVolume(0.25)
         GameState = "play"
      elseif GameState == "play" then
         GfxChain.crt.distortionFactor = { 1.2, 1.2 }
         AmbientLayer:setPitch(0.5)
         CombatLayer:setVolume(0)
         GameState = "pause"
      end

      -- SpawnItem(Vector(400, 400), SelectItem())
   end
   if key == 'return' and (GameState == "pause" or GameState == 'gameover') then
      GfxChain.crt.distortionFactor = { 1.05, 1.05 }
      CombatLayer:setVolume(0.25)
      GameState = 'menu'
      StormSfx:play()
   end
   if key == 'tab' then
      if Debug == 1 then
         Debug = 0
      else
         Debug = 1
      end
   end
   if key == 'r' and Debug == 1 then
      for i = 1, 10 do
         clearRoom()
      end
   end
   if key == 'space' then
      if GameState == "gameover" then
         Reset()
         AmbientLayer:play()
         StartSfx:play()
      elseif GameState == "menu" then
         StormSfx:stop()
         AmbientLayer:play()
         StartSfx:play()
         Reset()
      end
   end
   if Debug == 1 then
      if key == 'y' then
         SpawnItem(Vector(450, 450), Items['cool'])
      end
      if tonumber(key) ~= nil then
         -- SpawnItem(p.Position, SelectItem())
         -- Spawn(tonumber(key), Vector(450, 450))
         Wave = Wave + tonumber(key)
      end
      if key == 'space' then
         -- SpawnItem(Vector(450, 450), Items.bandaid)
         SpawnPickup(PickUp(Vector(450, 450), 1))
      end
   end
end

function love.update(dt)
   VMod.Player = p
   VMod:RunCallback(VMod.Callbacks.ON_PLAYER_UPDATE, { p })
   -- GfxChain.chromasep.radius = p.MaxHitPoints - p.HitPoints
   delta = dt
   t = t + delta
   PointsParticle:update(dt * SP)
   if GameState == "play" then
      EvaluateCache()
      SelectedItem = {
         name = "",
         desc = "",
      }
      p.ShootSFX:setPitch(1.5)
      p.Rotation = 0
      if PointMult > 1 then PointMult = PointMult - ((0.2 * PointMult) * delta) end
      if PointMult < 1 then PointMult = 1 end
      Points = math.floor(Points)
      if p.Scale.x > 4 then p.Scale.x = p.Scale.x - 10 * (delta) end
      if p.Scale.x < 4 then p.Scale.x = p.Scale.x + 10 * (delta) end
      if p.Scale.y > 4 then p.Scale.y = p.Scale.y - 10 * (delta) end
      if p.Scale.y < 4 then p.Scale.y = p.Scale.y + 10 * (delta) end
      if #Entities == 0 then
         TimeUntilNextWave = TimeUntilNextWave - 1 * (SP * delta)
      else
         TimeUntilNextWave = 100
      end

      if TimeUntilNextWave < 0 then
         Wave = Wave + 1
         StartSfx:play()
         if Wave % 20 == 0 then
            Spawn(EntityType.Perix, Vector(480, 480))
            local spawnsfx = KapowSfx:clone()
            love.audio.setEffect("echo", { type = "echo", delay = "0.1" })
            love.audio.setEffect("reverb", { type = "reverb", decaytime = "10" })
            spawnsfx:setEffect("reverb")
            spawnsfx:setEffect("echo")
            spawnsfx:play()
            spawnsfx:release()
            CombatLayer:play()
         elseif Wave == 1 then
            TimeUntilNextWave = 200
            for i = 1, GetWaveMonsters() do
               local spawnpoint = Vector(
                  love.math.random(100, 800),
                  love.math.random(100, 800)
               )
               Spawn(SelectMonster(), spawnpoint)
               CombatLayer:play()
            end
         elseif (Wave + 1) % 20 == 0 then
            KapowSfx:play()
            Spawn(EntityType.Cont, Vector(960 / 2, 960 / 2))
            CombatLayer:stop()
         elseif Wave % 4 == 0 or (Wave - 1) % 20 == 0 then
            Spawn(EntityType.Cont, Vector(960 / 2, 960 / 2))
            local selected = {}
            CombatLayer:stop()
            for i = 1, 3 do
               item = SelectItem()
               local count = 0
               repeat
                  count = count + 1
                  if count == TableLength(Items) then
                     item = Items.mike
                     break
                  end
               until not table.contains(p.Items, item) and not table.contains(selected, item)
               local pos = Vector(
                  340 + (70 * i),
                  550
               )
               SpawnItem(pos, item)
               table.insert(selected, item)
            end
         else
            TimeUntilNextWave = 200
            for i = 1, GetWaveMonsters() do
               local spawnpoint = Vector(
                  love.math.random(100, 800),
                  love.math.random(100, 800)
               )
               Spawn(SelectMonster(), spawnpoint)
               CombatLayer:play()
            end
         end
      end
      if p.HitPoints < 1 then
         Screenshake = 5
         local diesfx = EnemyDeathSFX:clone()
         if Highscore < Wave then Highscore = Wave end
         -- diesfx:setVolume(0.2)
         love.audio.stop()
         diesfx:setPitch(0.8)
         love.audio.setEffect("echo", { type = "echo", delay = "0.1" })
         love.audio.setEffect("reverb", { type = "reverb", decaytime = "10" })
         diesfx:setEffect("reverb")
         diesfx:setEffect("echo")
         diesfx:play()
         for i = 1, 10 do
            clearRoom()
         end
         GameState = "gameover"
         GfxChain.godsray.decay = 0
      end
      --[[if not GfxChain.chromasep.radius == nil then
      if GfxChain.chromasep.radius > 0 then GfxChain.chromasep.radius = GfxChain.chromasep.radius - 0.5 end
   end]]
      if p.Position.x > 950 then
         p.Position.x = 950
      end
      if p.Position.x < 10 then
         p.Position.x = 10
      end
      if p.Position.y > 950 then
         p.Position.y = 950
      end
      if p.Position.y < 10 then
         p.Position.y = 10
      end

      if p.FireDelay > 0 then p.FireDelay = p.FireDelay - 1 * (SP * delta) end
      if (love.mouse.isDown(1) == true or love.keyboard.isDown('c') == true) and p.FireDelay <= 0 then
         p.ShootSFX:stop()
         p.ShootSFX:play()
         p.FireDelay = p.MaxFireDelay
         local playerbullet = Bullet()
         AddtoBulletCache(playerbullet)
         playerbullet.Position.x = p.Position.x
         playerbullet.Position.y = p.Position.y
         playerbullet.Sprite = BulletVariants.Player
         playerbullet.Tags = p.BulletTags
         playerbullet.Lifetime = p.Range
         local target = GetDiff(p.Position, Vector(love.mouse.getX(), love.mouse.getY())):Normalize():Multi(p.ShotSpeed)
         playerbullet.Velocity = target
         playerbullet.Velocity:Add(p.Velocity)
         VMod:RunCallback(VMod.Callbacks.ON_PLAYER_SHOOT, { playerbullet })
      end
      if not table.contains(p.Items, Items.chronos) then
         if love.mouse.isDown(2) then
            SP = 10
            CombatLayer:setPitch(0.75)
            AmbientLayer:setPitch(0.9)
            GfxChain.godsray.decay = 0.9
            if table.contains(p.Items, Items.stopwatch) then
               AmbientLayer:setPitch(0.5)
               CombatLayer:setPitch(0.5)
               SP = 0.5
            end
            if not table.contains(p.Items, Items.timegun) then
               p.FireDelay = p.MaxFireDelay
            end
         else
            SP = 30
            CombatLayer:setPitch(1)
            AmbientLayer:setPitch(1)
            GfxChain.godsray.decay = 0
         end
      else
         GfxChain.godsray.decay = 0.8
         CombatLayer:setPitch(0.95)
         AmbientLayer:setPitch(0.95)
         SP = 15
         if table.contains(p.Items, Items.stopwatch) then
            SP = 10
         end
      end
      --[[
   if p.FireDelay == 0 or p.FireDelay < 0 then
      if love.keyboard.isDown('up', 'down', 'left', 'right') then
         local playerbullet = Bullet()
         playerbullet.Position.x = p.Position.x
         playerbullet.Position.y = p.Position.y
         playerbullet.Sprite = BulletVariants.Player
         playerbullet.Tags = { BulletTags.Player }
         playerbullet.Lifetime = p.Range
         AddtoBulletCache(playerbullet)
         if love.keyboard.isDown('up') then
            p.ShootSFX:stop()
            p.ShootSFX:play()
            p.FireDelay = p.MaxFireDelay
            playerbullet.Velocity = Vector(0, -35)
         elseif love.keyboard.isDown('down') then
            p.ShootSFX:stop()
            p.ShootSFX:play()
            p.FireDelay = p.MaxFireDelay
            playerbullet.Velocity = Vector(0, 35)
         elseif love.keyboard.isDown('left') then
            p.ShootSFX:stop()
            p.ShootSFX:play()
            p.s = -1
            p.FireDelay = p.MaxFireDelay
            playerbullet.Velocity = Vector(-35, 0)
         elseif love.keyboard.isDown('right') then
            p.ShootSFX:stop()
            p.ShootSFX:play()
            p.s = 1
            p.FireDelay = p.MaxFireDelay
            playerbullet.Velocity = Vector(35, 0)
         end
      end
   end
   ]]
      if love.keyboard.isDown("a") then
         p.Velocity.x = -p.Speed
         p.s = -1
         p.Rotation = -0.09
      elseif love.keyboard.isDown("d") then
         p.s = 1
         p.Velocity.x = p.Speed
         p.Rotation = 0.09
      else
         p.Velocity.x = 0
      end
      if love.keyboard.isDown("w") then
         p.Velocity.y = -p.Speed
      elseif love.keyboard.isDown("s") then
         p.Velocity.y = p.Speed
      else
         p.Velocity.y = 0
      end
      --[[
   if love.keyboard.isDown("lshift") then
      if p.CanDash == true then
         p.IsDashing = true
      else
         p.IsDashing = false
      end
   end

   if p.IsDashing == true then
      p.CoolDown = p.CoolDown + (1 * delta)
   else p.CoolDown = p.CoolDown - (1 * delta)
   end

   if p.CoolDown > 1 then
      p.IsDashing = false
      p.CanDash = false
   elseif p.CoolDown < 0 then
      p.CanDash = true
   end
      ]]
      if love.keyboard.isDown('v') then SP = 0 end

      p.Position:Add(p.Velocity)

      for i, entity in ipairs(Pickups) do
         entity.FrameCt = entity.FrameCt + delta

         if CheckCollision(p.Position.x - 20, p.Position.y - 20, 40, 40,
                entity.Position.x - 10, entity.Position.y - 10, 20, 20) == true then
            p.HitPoints = p.HitPoints + entity.HealAmount
            table.remove(Pickups, indexOf(Pickups, entity))
         else
         end
         entity.Scale.y = 4
         entity.Scale.x = 4 + ((math.sin(t * 4) * 0.4))
         if entity.FrameCt > 5 then
            table.remove(Pickups, indexOf(Pickups, entity))
         end
      end

      for i, bullet in pairs(Bullets) do
         VMod:RunCallback(VMod.Callbacks.ON_BULLET_UPDATE, { bullet })
         local marked = false
         bullet.FrameCt = bullet.FrameCt + (SP * delta)
         bullet.Position:Add(bullet.Velocity:Multi((SP * delta)))
         for i, tag in pairs(bullet.Tags) do
            local velcomp = bullet.Velocity:Multi(0.1)
            if tag == BulletTags.Decelerate then
               bullet.Velocity:Sub(velcomp:Multi(SP * delta))
            end
            if tag == BulletTags.Accelerate then
               bullet.Velocity = bullet.Velocity:Multi(1.025)
            end
            if tag == BulletTags.Mark then
               bullet.Marked = true
            end
            if tag == BulletTags.Mike then
               bullet.Velocity:Add(p.Velocity:Multi(0.5))
            end
         end

         if table.contains(bullet.Tags, BulletTags.Player) then
            for i, entity in pairs(Entities) do
               local bulletscale = (9 + (p.Damage * 3)) * 2
               if CheckCollision(bullet.Position.x - (bulletscale / 2), bullet.Position.y - (bulletscale / 2),
                      bulletscale,
                      bulletscale,
                      entity.Position.x - 20, entity.Position.y - 20, 40, 40) == true and
                   entity.Type ~= EntityType.Cont then
                  VMod:RunCallback(VMod.Callbacks.ON_ENEMY_TAKE_DAMAGE, { entity, bullet })
                  table.remove(Bullets, indexOf(Bullets, bullet))
                  SP = 0
                  entity.HitPoints = entity.HitPoints - p.Damage
                  entity.Scale.y = 5
                  entity.Scale.x = 3
                  if entity.HitPoints <= 0 and table.contains(bullet.Tags, BulletTags.Bloodlust) and
                      love.math.random(0, 20) == 20 then
                     p.HitPoints = p.HitPoints + 1
                  end
                  if table.contains(entity.Conditions, "marked") then
                     entity.HitPoints = entity.HitPoints - (entity.HitPoints / 5)
                  end
                  if table.contains(p.Items, Items.rebound) then
                     local playerbullet = Bullet()
                     AddtoBulletCache(playerbullet)
                     playerbullet.Position.x = entity.Position.x
                     playerbullet.Position.y = entity.Position.y
                     playerbullet.Position:Add(GetDiff(entity.Position,
                           p.Position):Normalize()
                        :
                        Multi(100))
                     playerbullet.Sprite = BulletVariants.Player
                     playerbullet.Tags = p.BulletTags
                     playerbullet.Lifetime = p.Range
                     local target = GetDiff(entity.Position,
                            p.Position:AddRet(Vector(love.math.random(-300, 300), love.math.random(-300, 300))))
                         :Normalize()
                         :Multi(p.ShotSpeed)
                     playerbullet.Velocity = target
                     playerbullet.Velocity:Add(entity.Velocity)
                  end

                  if table.contains(p.Items, Items.venom) and love.math.random(1, 90) < 4 then
                     entity.HitPoints = 0
                  end
                  -- Screenshake = Screenshake + 0.2
                  if entity.Type ~= EntityType.Perix then entity.FrameCt = love.math.random(0, 10) end
                  entity.Velocity:Add(bullet.Velocity:Multi((0.1 * p.KnockbackMultiplier)))
                  if bullet.Marked == true and love.math.random(0, 5) == 1 then
                     entity:AddCondition("marked")
                  end
                  if table.contains(p.Items, Items.flare) == true and love.math.random(0, 5) == 1 then
                     entity:AddCondition("fire")
                  end
               end
            end
         elseif table.contains(bullet.Tags, BulletTags.Points) then
            if CheckCollision(p.Position.x - 20, p.Position.y - 20, 40, 40,
                   bullet.Position.x - 10, bullet.Position.y - 10, 20, 20) == true then
               -- GfxChain.chromasep.radius = 5
               Screenshake = Screenshake + (0.1 / PointMult)
               Points = Points + 10
               PointsParticle:emit(1)
               table.remove(Bullets, indexOf(Bullets, bullet))
               local collect = CollectSfx:clone()
               collect:setPitch(love.math.random(0.8, 2))
               collect:play()
               PointMult = PointMult + (0.7 / PointMult)
               -- collect:release()
            end
            local target =
                GetDiff(bullet.Position,
                   p.Position:AddRet(Vector(
                      love.math.random(-100, 100),
                      love.math.random(-100, 100)
                   ))):Normalize()
            bullet.Velocity = target:Multi(30)
         else
            if CheckCollision(p.Position.x - 20, p.Position.y - 20, 40, 40,
                   bullet.Position.x - 10, bullet.Position.y - 10, 20, 20) == true then
               -- GfxChain.chromasep.radius = 5
               VMod:RunCallback(VMod.Callbacks.ON_PLAYER_TAKE_DAMAGE, { bullet })
               Screenshake = Screenshake + 1
               p.HitPoints = p.HitPoints - 1
               if table.contains(p.Items, Items.chronos) then
                  Screenshake = Screenshake + 1
                  p.HitPoints = p.HitPoints - 1
               end
               if table.contains(p.Items, Items.pact) then
                  p.HitPoints = 0
               end

               local diesfx = EnemyDeathSFX:clone()
               -- diesfx:setVolume(0.1)
               diesfx:setPitch(1.5)
               diesfx:play()
               table.remove(Bullets, indexOf(Bullets, bullet))
            end
         end
         if bullet.FrameCt > bullet.Lifetime then
            table.remove(Bullets, indexOf(Bullets, bullet))
         end
      end



      for i, entity in pairs(Entities) do
         VMod:RunCallback(VMod.Callbacks.ON_ENTITY_UPDATE, { entity })
         entity.FrameIndex = entity.FrameIndex + (SP * delta)
         if entity.FrameIndex < 2 then
         end
         if entity.Position.x > 960 then
            entity.Position.x = 10
         end
         if entity.Position.x < 0 then
            entity.Position.x = 950
         end
         if entity.Position.y > 960 then
            entity.Position.y = 10
         end
         if entity.Position.y < 0 then
            entity.Position.y = 950
         end
         if entity.Scale.x > 4 then entity.Scale.x = entity.Scale.x - 5 * (delta) end
         if entity.Scale.x < 4 then entity.Scale.x = entity.Scale.x + 5 * (delta) end
         if entity.Scale.y > 4 then entity.Scale.y = entity.Scale.y - 5 * (delta) end
         if entity.Scale.y < 4 then entity.Scale.y = entity.Scale.y + 5 * (delta) end
         if entity.Type == EntityType.Cont then
            if CheckCollision(p.Position.x - 20, p.Position.y - 20, 40, 40,
                   entity.Position.x - 10, entity.Position.y - 10, 20, 20) == true and love.keyboard.isDown('e') then
               entity.FrameCt = entity.FrameCt + (SP * delta)
            else
               entity.FrameCt = 0
            end
            if CheckCollision(p.Position.x - 20, p.Position.y - 20, 40, 40,
                   entity.Position.x - 10, entity.Position.y - 10, 20, 20) == true then
               SelectedItem.desc = " ( press [E] to continue to the next sector ) "
            end
            if entity.FrameCt > 2 then
               entity.FrameCt = 0
               table.remove(Entities, indexOf(Entities, entity))
               Entities = {}
            end
         elseif entity.Type == EntityType.Item then
            if CheckCollision(p.Position.x - 20, p.Position.y - 20, 40, 40,
                   entity.Position.x - 10, entity.Position.y - 10, 20, 20) == true then
               SelectedItem = {
                  name = entity.I1.Name,
                  desc = entity.I1.Description
               }
               if love.keyboard.isDown('e') then
                  entity.FrameCt = entity.FrameCt + (SP * delta)
               end
            else
               entity.FrameCt = 0
            end
            if entity.FrameCt > 1 then
               entity.FrameCt = 0
               VMod:RunCallback(VMod.Callbacks.ON_ITEM_PICKUP, { entity.I1 })
               table.insert(p.Items, #p.Items + 1, entity.I1)
               p.HitPoints = p.HitPoints + entity.I1.heal
               table.remove(Entities, indexOf(Entities, entity))
               for i = 1, TableLength(Entities) do
                  for i, ent in pairs(Entities) do
                     if ent.Type == EntityType.Item then
                        table.remove(Entities, indexOf(Entities, ent))
                     end
                  end
               end
            end
         else
            -- all enemies
            if table.contains(entity.Conditions, "fire") then
               entity.HitPoints = entity.HitPoints - ((p.Damage) * delta)
            end
            if entity.Position.x > p.Position.x and not entity.Type == EntityType.Perix then
               entity.Direction = -1
            else
               entity.Direction = 1
            end


            if entity.HitPoints < 0 or entity.HitPoints == 0 then
               Screenshake = Screenshake + 1
               local diesfx = EnemyDeathSFX:clone()
               -- diesfx:setVolume(0.1)
               diesfx:setPitch(2)
               diesfx:play()

               local bloodstain = Gfx(entity.Position, love.math.random(4))
               AddGFX(bloodstain)
               if love.math.random(1, 20 + p.HitPoints) == 1 then
                  SpawnPickup(PickUp(entity.Position, 1))
               end
               table.remove(Entities, indexOf(Entities, entity))
               EnemiesKilled = EnemiesKilled + 1
               if entity.Type == EntityType.Perix then
                  for i = 1, ((10 * (Wave / 20)) * math.floor(PointMult * 2)) do
                     local bullet = Bullet()
                     AddtoBulletCache(bullet)
                     bullet.Position.x = entity.Position.x
                     bullet.Position.y = entity.Position.y
                     table.insert(bullet.Tags, BulletTags.Points)

                     -- bullet.Tags = { BulletTags.Decelerate }
                     bullet.Lifetime = 100
                     bullet.Sprite = BulletVariants.Point
                  end
               else
                  for i = 1, (entity.Type * math.floor(PointMult)) do
                     local bullet = Bullet()
                     AddtoBulletCache(bullet)
                     bullet.Position.x = entity.Position.x
                     bullet.Position.y = entity.Position.y
                     table.insert(bullet.Tags, BulletTags.Points)

                     -- bullet.Tags = { BulletTags.Decelerate }
                     bullet.Lifetime = 100
                     bullet.Sprite = BulletVariants.Point
                  end
               end
            end


            -- position n that jazz
            entity.Position:Add(entity.Velocity:Multi((SP * delta)))
            entity.FrameCt = entity.FrameCt + (SP * delta)
            if entity.Velocity.x > 0 then
               entity.Velocity.x = entity.Velocity.x - 1 * (SP * delta)
            end
            if entity.Velocity.x < 0 then
               entity.Velocity.x = entity.Velocity.x + 1 * (SP * delta)
            end
            if entity.Velocity.y > 0 then
               entity.Velocity.y = entity.Velocity.y - 1 * (SP * delta)
            end
            if entity.Velocity.y < 0 then
               entity.Velocity.y = entity.Velocity.y + 1 * (SP * delta)
            end

            -- basic enemy ai start
            if entity.Type == EntityType.BasicEnemy then
               if entity.FrameCt < 30 then
                  if entity.I1 == 1 then
                     entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-1)
                  elseif entity.I1 == 2 then
                     entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(2)
                  end
               end
               if entity.FrameCt > 40 then
                  local shootsfx = EnemyShootSFX:clone()
                  -- shootsfx:setVolume(0.1)
                  shootsfx:setPitch(1.2)
                  shootsfx:play()
                  entity.Scale.y = 3
                  entity.Scale.x = 5
                  entity.FrameCt = 0
                  entity.I1 = love.math.random(1, 2)
                  local bullet = Bullet()
                  AddtoBulletCache(bullet)
                  bullet.Position.x = entity.Position.x
                  bullet.Position.y = entity.Position.y
                  local target = GetDiff(entity.Position, p.Position):Normalize()
                  bullet.Velocity = target:Multi(10)
                  -- bullet.Tags = { BulletTags.Decelerate }
                  bullet.Lifetime = 100
                  bullet.Sprite = BulletVariants.Normal
                  entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-3)
               end
            end

            if entity.Type == EntityType.Horiz then
               local shootsfx = HorizShootSFX:clone()
               -- shootsfx:setVolume(10)
               shootsfx:setPitch(1)
               if entity.FrameCt > 40 and entity.FrameCt < 45 then
                  entity.FrameCt = 50
                  shootsfx:play()
                  entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-15)
                  entity.Scale.y = 4.5
                  entity.Scale.x = 3
               elseif entity.FrameCt > 70 then
                  entity.FrameCt = 0
                  Quadshot(entity.Position, 5, 5)
                  shootsfx:play()
                  entity.Scale.y = 3
                  entity.Scale.x = 4.5
                  entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(20)
               end
            end
            if entity.Type == EntityType.Idly then
               if entity.FrameCt < 20 then
                  entity.Velocity = Vector(entity.I1, entity.I2):Multi(3)
               end
               if entity.FrameCt > 36 then
                  entity.I1 = love.math.random(-1, 1)
                  entity.I2 = love.math.random(-1, 1)
                  entity.FrameCt = 0
                  entity.Scale.y = 3
                  entity.Scale.x = 5
                  local bullet = Bullet()
                  AddtoBulletCache(bullet)
                  bullet.Position.x = entity.Position.x
                  bullet.Position.y = entity.Position.y
                  bullet.Velocity = Vector(0, 0)
                  bullet.Lifetime = 100
                  bullet.Sprite = BulletVariants.Normal
               end
            end
            if entity.Type == EntityType.Quadro then
               if entity.FrameCt < 100 then
                  entity.Velocity = Vector(entity.I1, entity.I2):Multi(10)
               end

               if entity.FrameCt > 36 and entity.FrameCt < 40 then
                  entity.FrameCt = 100
                  entity.I1 = love.math.random(-1, 1)
                  entity.I2 = love.math.random(-1, 1)
               end
               if entity.FrameCt > 200 then
                  entity.FrameCt = 0
                  entity.Scale.y = 3
                  entity.Scale.x = 5
                  Quadshot(entity.Position, 0, 5)
                  Quadshot(entity.Position, 5, 5)
               end
            end
            if entity.Type == EntityType.Kapow then
               if entity.FrameCt < 15 then
                  if entity.I1 == 1 then
                     entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-1)
                  elseif entity.I1 == 2 then
                     entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(2)
                  end
               end
               if entity.FrameCt > 20 then
                  entity.FrameCt = 0
                  if love.math.random(1, 2) == 2 then
                     local shootsfx = KapowSfx:clone()
                     -- shootsfx:setVolume(0.1)
                     shootsfx:setPitch(1.2)
                     shootsfx:play()
                     entity.I1 = love.math.random(1, 2)
                     for i = 1, 4 do
                        local bullet = Bullet()
                        AddtoBulletCache(bullet)
                        bullet.Position.x = entity.Position.x
                        bullet.Position.y = entity.Position.y
                        entity.Scale.y = 3
                        entity.Scale.x = 6
                        local target =
                            GetDiff(entity.Position,
                               p.Position:AddRet(Vector(
                                  love.math.random(-300, 300),
                                  love.math.random(-300, 300)
                               ))):Normalize()
                        bullet.Velocity = target:Multi(10)
                        -- bullet.Tags = { BulletTags.Decelerate }
                        bullet.Lifetime = 100
                        bullet.Sprite = BulletVariants.Normal
                        entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-1)
                     end
                  end
               end
            end
            if entity.Type == EntityType.Gorbix then
               local shootsfx = HorizShootSFX:clone()
               -- shootsfx:setVolume(10)
               shootsfx:setPitch(1)
               if entity.FrameCt > 30 and entity.FrameCt < 35 then
                  -- Quadshot(entity.Position, 5 * i, 6)
                  Quadshot(entity.Position, -10, 6)
                  entity.Scale.y = 3
                  entity.Scale.x = 6
                  entity.FrameCt = 60
                  shootsfx:play()
                  entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-15)
               elseif entity.FrameCt > 70 then
                  entity.Scale.y = 7
                  entity.Scale.x = 2
                  entity.FrameCt = 0
                  Quadshot(entity.Position, 5, 6)
                  -- Quadshot(entity.Position, 0 + i, 6)               shootsfx:play()
                  entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(20)
               end
            end
            if entity.Type == EntityType.Cirrus then
               if entity.FrameCt < 10 then
                  if entity.I1 == 1 then
                     entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-1)
                  elseif entity.I1 == 2 then
                     entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(2)
                  end
               end
               if entity.FrameCt > 30 then
                  local shootsfx = EnemyShootSFX:clone()
                  -- shootsfx:setVolume(0.1)
                  shootsfx:setPitch(1.2)
                  shootsfx:play()
                  entity.FrameCt = 0
                  entity.I1 = love.math.random(1, 2)
                  entity.Scale.y = 2.5
                  entity.Scale.x = 6.5
                  for i = 1, 14 do
                     local bullet = Bullet()
                     AddtoBulletCache(bullet)
                     bullet.Position.x = entity.Position.x
                     bullet.Position.y = entity.Position.y
                     local target =
                         Vector(
                            entity.Position.x + love.math.random(-900, 900),
                            entity.Position.y + love.math.random(-900, 900)
                         )
                     target = GetDiff(entity.Position, target)
                     bullet.Velocity = target:Normalize():Multi(6)
                     -- bullet.Tags = { BulletTags.Decelerate }
                     bullet.Lifetime = 100
                     bullet.Sprite = BulletVariants.Normal
                     entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-3)
                  end
               end
            end
            if entity.Type == EntityType.Perix then
               if math.floor(entity.FrameIndex) % 15 == 0 then
                  entity.FrameIndex = entity.FrameIndex + 1
                  if entity.Sprite == EntitySprites[10]
                  then
                     entity.Sprite = EntitySprites[11]
                  else
                     entity.Sprite = EntitySprites[10]
                  end
               end
               if entity.HitPoints == 40 and entity.FrameIndex < 10 then entity.HitPoints = 120 * (Wave / 20) end
               if table.contains(entity.Conditions, "marked") then
                  entity.Conditions = {}
               end
               if entity.FrameCt > (60 - (Wave / 5)) then
                  entity.FrameCt = 0
                  entity.I1 = love.math.random(1, 7)
               else
                  if entity.I1 == 1 then
                     if entity.FrameCt < 2 then
                        local shootsfx = EnemyShootSFX:clone()
                        -- shootsfx:setVolume(0.1)
                        shootsfx:setPitch(1.2)
                        shootsfx:play()
                        entity.FrameCt = 0
                        entity.Scale.y = 2.5
                        entity.Scale.x = 6.5
                        for i = 1, 20 do
                           local bullet = Bullet()
                           AddtoBulletCache(bullet)
                           bullet.Position.x = entity.Position.x
                           bullet.Position.y = entity.Position.y
                           local target =
                               Vector(
                                  entity.Position.x + love.math.random(-900, 900),
                                  entity.Position.y + love.math.random(-900, 900)
                               )
                           target = GetDiff(entity.Position, target)
                           bullet.Velocity = target:Normalize():Multi(6):Multi(Wave / 20)
                           -- bullet.Tags = { BulletTags.Decelerate }
                           bullet.Lifetime = 100
                           bullet.Sprite = BulletVariants.Normal
                           entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-3)
                           entity.FrameCt = 60
                        end
                     end
                  elseif entity.I1 == 2 then
                     if math.floor(entity.FrameCt) % 4 == 0 then
                        entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-2):Multi(Wave / 20)
                        local shootsfx = EnemyShootSFX:clone()
                        -- shootsfx:setVolume(0.1)
                        shootsfx:setPitch(1.2)
                        shootsfx:play()
                        entity.Scale.y = 3
                        entity.Scale.x = 5
                        local bullet = Bullet()
                        AddtoBulletCache(bullet)
                        bullet.Position.x = entity.Position.x
                        bullet.Position.y = entity.Position.y
                        local target = GetDiff(entity.Position, p.Position:AddRet(Vector(
                           love.math.random(-50, 50),
                           love.math.random(-50, 50)
                        )):AddRet(p.Velocity)):Normalize()
                        bullet.Velocity = target:Multi(10):Multi(Wave / 20)
                        -- bullet.Tags = { BulletTags.Decelerate }
                        bullet.Lifetime = 100
                        bullet.Sprite = BulletVariants.Normal
                        entity.FrameCt = entity.FrameCt + 1
                     end
                  elseif entity.I1 == 3 then
                     if entity.FrameCt > 36 and entity.FrameCt < 40 then
                        entity.Velocity = Vector(love.math.random(-20, 20), love.math.random(-20, 20))
                        entityFrameCt = 41
                     end
                     if entity.FrameCt > 40 then
                        entity.FrameCt = 100
                        entity.Scale.y = 3
                        entity.Scale.x = 5
                        Quadshot(entity.Position, 0, 5)
                        Quadshot(entity.Position, 5, 5)
                     end
                  elseif entity.I1 == 4 then
                     if math.floor(entity.FrameCt) % 10 == 0 then
                        local shootsfx = KapowSfx:clone()
                        -- shootsfx:setVolume(0.1)
                        shootsfx:setPitch(1.2)
                        shootsfx:play()
                        entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(-5):Multi(Wave /
                           20)
                        for i = 1, 3 do
                           entity.Scale.y = 3
                           entity.Scale.x = 5
                           local bullet = Bullet()
                           AddtoBulletCache(bullet)
                           bullet.Position.x = entity.Position.x
                           bullet.Position.y = entity.Position.y
                           local target = GetDiff(entity.Position, p.Position:AddRet(Vector(
                              love.math.random(-300, 300),
                              love.math.random(-300, 300)
                           )):AddRet(p.Velocity)):Normalize()
                           bullet.Velocity = target:Multi(35):Multi(Wave / 20)
                           bullet.Tags = { BulletTags.Decelerate }
                           bullet.Lifetime = 60
                           bullet.Sprite = BulletVariants.Normal
                           entity.FrameCt = entity.FrameCt + 1
                        end
                     end
                  elseif entity.I1 == 5 then
                     if math.floor(entity.FrameCt) % 2 == 0 then
                        entity.Velocity = GetDiff(entity.Position, p.Position):Normalize():Multi(1)
                        local shootsfx = EnemyShootSFX:clone()
                        -- shootsfx:setVolume(0.1)
                        shootsfx:setPitch(1.5)
                        shootsfx:setVolume(0.1)
                        shootsfx:play()
                        entity.Scale.y = 3
                        entity.Scale.x = 5
                        local bullet = Bullet()
                        AddtoBulletCache(bullet)
                        bullet.Position.x = entity.Position.x
                        bullet.Position.y = entity.Position.y
                        local target = GetDiff(entity.Position, p.Position:AddRet(Vector(
                           love.math.random(-200, 200),
                           love.math.random(-200, 200)
                        ))):Normalize()
                        bullet.Velocity = target:Multi(15):Multi(Wave / 30)
                        -- bullet.Tags = { BulletTags.Decelerate }
                        bullet.Lifetime = 100
                        bullet.Sprite = BulletVariants.Normal
                        entity.FrameCt = entity.FrameCt + 1
                     end
                     if entity.FrameCt > 50 then entity.FrameCt = 100 end
                  elseif entity.I1 == 6 then
                     if type(entity.I2) ~= "table" then
                     else
                        entity.Velocity = entity.I2
                     end
                     if math.floor(entity.FrameCt) % 4 == 0 then
                        local shootsfx = EnemyShootSFX:clone()
                        -- shootsfx:setVolume(0.1)
                        shootsfx:setPitch(1.2)
                        shootsfx:play()

                        local bullet = Bullet()
                        AddtoBulletCache(bullet)
                        bullet.Position = Vector(
                           950, love.math.random(10, 900)
                        )

                        bullet.Velocity = Vector(-11, 0):Multi(Wave / 20)
                        -- bullet.Tags = { BulletTags.Decelerate }
                        bullet.Lifetime = 500
                        bullet.Sprite = BulletVariants.Normal
                        entity.FrameCt = entity.FrameCt + 1
                        if love.math.random(1, 2) == 2 then
                           entity.I2 = Vector(
                              love.math.random(-1, 1), love.math.random(-1, 1)
                           ):Multi(30)
                        end
                     end
                  elseif entity.I1 == 7 and #Entities < 2 then
                     StartSfx:play()
                     KapowSfx:play()
                     for i = 1, love.math.random(2, 4) do
                        local spawnpoint = Vector(
                           love.math.random(100, 800),
                           love.math.random(100, 800)
                        )
                        Spawn(SelectMonster(), spawnpoint)
                     end
                     entity.FrameCt = 100
                  end
               end
               if #Entities > 1 and entity.HitPoints < 40 then
                  entity.HitPoints = entity.HitPoints + ((Wave / 20) * dt) / 6
               end
            end
         end
      end
   end
end

function DrawHUD()
   for i = 0, p.HitPoints - 1 do
      love.graphics.draw(Heart, 72 + (i * 40), 70, 0, 4, 4, 8, 8)
   end
   local dmg = tostring(p.Damage):sub(1, 3)
   local pref = 10 / p.MaxFireDelay
   local firerate = tostring(pref):sub(1, 3)
   love.graphics.print("points: " .. math.floor(Points) .. " x" .. math.floor(PointMult), PixAntiqua, 40, 80, 0, 2, 2)
   love.graphics.print("wave: " .. Wave, PixAntiqua, 40, 110, 0, 2, 2)
   love.graphics.print("firerate: " .. firerate, PixAntiqua, 40, 140, 0, 2, 2)
   love.graphics.print("dmg: " .. dmg, PixAntiqua, 40, 170, 0, 2, 2)
   local y = ((math.sin(t * 5) * 5)) + 80
   love.graphics.printf(SelectedItem.name, PixAntiqua, 0, y, love.graphics.getWidth() / 2.5, "center", 0, 2.5, 2.5)
   love.graphics.printf(SelectedItem.desc, PixAntiqua, 0, y + 40, love.graphics.getWidth() / 2, "center", 0, 2, 2)
   if (Wave + 1) % 20 == 0 then
      love.graphics.setColor(1, 0.1, 0.1, 1)
      love.graphics.printf("A FORMIDABLE FOE APPROACHES..", PixAntiqua, 0, y + 240, love.graphics.getWidth() / 2,
         "center"
         , 0, 2,
         2)
   end
   -- love.graphics.print(tostring(p.CoolDown), PixAntiqua, 40, 170, 0, 2, 2)
   love.graphics.setColor(1, 1, 1, 0.5)
   for i, item in pairs(p.Items) do
      love.graphics.draw(item.Sprite, 900 - (36 * (i - 1)), 70, 0, 2, 2, 8, 8)
   end
   love.graphics.setColor(1, 1, 1, 1)
end

function love.draw()
   if Screenshake > 0 then
      local s = Screenshake
      love.graphics.translate(love.math.random(-s, s), love.math.random(-s, s))
      Screenshake = Screenshake - 0.05
   end
   GfxChain.draw(function()
      if GameState == "play" then
         for i, gfx in pairs(GfxCache) do
            love.graphics.draw(gfx.Sprite, gfx.Position.x, gfx.Position.y, 0, 4, 4, 8, 8)
         end


         for i, entity in pairs(Entities) do
            love.graphics.setColor(1, 1, 1, 1)
            if table.contains(entity.Conditions, "marked") then
               love.graphics.draw(markedSprite, entity.Position.x, entity.Position.y - 48, 0, 4, 4, 8, 8)
               love.graphics.setColor(1, 0.8, 0.8, 0.8)
            end
            if entity.Sprite == nil then
               table.remove(Entities, indexOf(Entities, entity))
            else
               if entity.Type == EntityType.Perix then
                  love.graphics.draw(entity.Sprite, entity.Position.x,
                     entity.Position.y, 0,
                     entity.Scale.x * entity.Direction, entity.Scale.y, 16, 16)
               else
                  love.graphics.draw(entity.Sprite, entity.Position.x, entity.Position.y, 0,
                     entity.Scale.x * entity.Direction, entity.Scale.y, 8, 8)
               end
               if Debug == 1 then
                  love.graphics.print(tostring(entity.Velocity:toString()), entity.Position.x,
                     entity.Position.y)
                  love.graphics.print(tostring(entity.HitPoints), entity.Position.x, entity.Position.y + 30)
                  love.graphics.print(tostring(entity.I1), entity.Position.x,
                     entity.Position.y + 60)
               end
            end
            if table.contains(entity.Conditions, "fire") then
               love.graphics.draw(flareSprite, entity.Position.x, entity.Position.y, 0, 4, 4, 8, 8)
               love.graphics.setColor(20, 0.8, 0.8, 1)
            end
            love.graphics.setColor(1, 1, 1, 1)
         end

         -- drawing player character
         love.graphics.draw(p.sprite, p.Position.x, p.Position.y, p.Rotation, p.Scale.x * p.s, p.Scale.y, 8, 8)

         if Debug == 1 then
            love.graphics.rectangle("line", p.Position.x - 20, p.Position.y - 20, 40, 40)

            love.graphics.print(tostring(dashcool), p.Position.x, p.Position.y + 30)
            -- love.graphics.print(tostring(dashcool), p.Position.x, p.Position.y + 50)
            for i, item in pairs(Entities) do
               love.graphics.print(tostring(item.Velocity:toString()), p.Position.x, p.Position.y + (i * 10))
            end
         end
         --drawing bullets
         GfxGlow.draw(function()
            love.graphics.draw(PointsParticle, p.Position.x, p.Position.y, 0, 4, 4)
            for i, pickup in pairs(Pickups) do
               love.graphics.draw(pickup.Sprite, pickup.Position.x, pickup.Position.y, 0, pickup.Scale.x, pickup.Scale.y
               , 8, 8)
            end
            for i, bullet in pairs(Bullets) do
               if table.contains(bullet.Tags, BulletTags.Player) then
                  local bulletscale = 3 + (p.Damage)
                  love.graphics.draw(bullet.Sprite, bullet.Position.x, bullet.Position.y, 0, bulletscale, bulletscale, 8
                  , 8)
               else
                  love.graphics.draw(bullet.Sprite, bullet.Position.x, bullet.Position.y, 0, 4, 4, 8, 8)
               end
               if Debug == 1 then
                  love.graphics.print(tostring(bullet.Velocity:toString()), bullet.Position.x, bullet.Position.y)
                  love.graphics.print(tostring(CheckCollision(p.Position.x - 40, p.Position.y - 40, 80, 80,
                     bullet.Position.x - 40
                     ,
                     bullet.Position.y - 40, 80
                     , 80)), bullet.Position.x, bullet.Position.y + 30)
                  love.graphics.rectangle("line", bullet.Position.x - 10, bullet.Position.y - 10, 20
                  , 20)
               end
            end
         end)
         -- love.graphics.print("WAVE: " .. Wave, PixAntiqua, 40, 40, 0, 3, 3)
         DrawHUD()
      elseif GameState == "pause" then
         GfxChain.godsray.decay = 0.85
         love.graphics.translate(love.math.random(-0.01, 0.01), love.math.random(-0.01, 0.01))
         for i = 1, 5 do
            love.graphics.setColor(0.05 * i, 0.2 * i, 0.35 * i, 0.5)
            love.graphics.printf("VOLTAGE IS PAUSED", PixAntiqua, 0, (180 * i) - 145, love.graphics.getWidth() / 8,
               "center", 0, 8
               , 8)
            love.graphics.printf("PRESS ESC TO RESUME", PixAntiqua, 0, (180 * i) - 50,
               love.graphics.getWidth() / 7,
               "center", 0, 7
               , 7)
         end
         love.graphics.setColor(1, 1, 1, 1)
         love.graphics.printf("press ESCAPE to unpause", PixAntiqua, 0, 450, love.graphics.getWidth() / 3.9,
            "center", 0, 3.9
            , 3.9)
         love.graphics.printf("press ENTER to return to main menu", PixAntiqua, 0, 510, love.graphics.getWidth() / 3.9,
            "center", 0, 3.9
            , 3.9)
      elseif GameState == "gameover" then
         love.graphics.setColor(155 / 255, 14 / 255, 62 / 255, 1)
         love.graphics.printf("YOU DID NOT SURVIVE", PixAntiqua, 0, 378, love.graphics.getWidth() / 6,
            "center", 0, 6
            , 6)
         love.graphics.setColor(1, 1, 1, 1)
         love.graphics.printf("YOU DID NOT SURVIVE", PixAntiqua, 0, 387, love.graphics.getWidth() / 6,
            "center", 0, 6
            , 6)
         love.graphics.printf("waves survived: " ..
            Wave ..
            "\npoints gathered: " ..
            Points ..
            "\nenemies slain: " ..
            EnemiesKilled .. "\nFINAL SCORE: " .. (Points + (EnemiesKilled * 10) * (Wave * 0.5)),
            PixAntiqua
            ,
            250
            ,
            490, love.graphics.getWidth() / 2,
            "left", 0, 2
            , 2)
         love.graphics.printf("[ press space to begin once more ]", PixAntiqua, 0, 635, love.graphics.getWidth() / 2,
            "center", 0, 2
            , 2)
         love.graphics.printf("[ press enter to return to the menu ]", PixAntiqua, 0, 675, love.graphics.getWidth() / 2,
            "center", 0, 2
            , 2)
         love.graphics.draw(p.DeathSprite, 450, 270, 0, 12, 12, 8, 8)
      elseif GameState == "menu" then
         for i = 1, 20 do
            love.graphics.setColor(0.1, 0.5, 1, 0.1)
            love.graphics.printf("voltage voltage voltage voltage voltage voltage voltage", PixAntiqua,
               0 + ((math.sin(t * 1) * 2)),
               (45 * i),
               love.graphics.getWidth() / 3,
               "left", 0, 3
               , 3)
         end
         love.graphics.setColor(0, 0, 0, 1)
         GfxChain.godsray.decay = 0.85
         love.graphics.setColor(0.25, 1, 1.75, 1)
         local y = ((math.sin(t * 2.5) * 4))
         love.graphics.printf("VOLTAGE", PixAntiqua, 0, 360 + y, love.graphics.getWidth() / 8,
            "center", 0, 8
            , 8)
         love.graphics.setColor(1, 1, 1, 1)
         love.graphics.printf("[ press space to begin ]", PixAntiqua, 0, 495 - y, love.graphics.getWidth() / 2,
            "center", 0, 2
            , 2)
         love.graphics.draw(p.sprite, 460, 300, 0, 12, 12, 8, 8)
      end
   end)
   if GameState == 'menu' or GameState == 'pause' then
      love.graphics.print("version 1.0", PixAntiqua, 9, 9, 0, 1.5, 1.4)
      if GameState == 'pause' then
         love.graphics.print((#Entities + #Pickups + #Bullets) .. " entities", PixAntiqua, 9, 27, 0,
            1.5
            , 1.4)
      end
   end
end
