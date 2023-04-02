function checkFileExtension(v, fileexlength)
    return string.sub(v, string.len(v) - fileexlength, string.len(v))
end

VMod = {}
ModUpdates = {}
VMod.ModdedEnemyTypes = {}
VMod.ModdedItems = {}
VMod.Callbacks = {}
VMod.Callbacks.ON_PLAYER_TAKE_DAMAGE = { INPUT = {} }
VMod.Callbacks.ON_PLAYER_UPDATE = { INPUT = {} }
VMod.Callbacks.ON_BULLET_UPDATE = {}
VMod.Callbacks.ON_ENEMY_TAKE_DAMAGE = {}
VMod.Callbacks.ON_ENTITY_UPDATE = {}
VMod.Callbacks.ON_ITEM_PICKUP = {}
VMod.Callbacks.ON_PLAYER_SHOOT = {}
VMod.Player = p
VMod.Game = {}


function VMod.Player:HasItem(item)
end
function VMod.Game:getSpeed()
    return SP
end

function VMod.dt()
    return SP * delta
end

function VMod:RunCallback(callback, args)
    local isValidCallback = nil
    for i, v in pairs(VMod.Callbacks) do
        if callback == v then
            isValidCallback = true
            break
        end
    end
    if isValidCallback ~= true then
        love.window.showMessageBox("MOD ERROR",
            " AddCallback: invalid callback!"
            , "error")
    else
        for i, v in ipairs(callback) do
            local input = { callback.INPUT }
            if type(callback[i]) == "function" then
                callback[i](args[1], args[2])
            end
        end
    end
end

function VMod:Enemy(name, sprite, ai)
    return {
        "ENEMYMETATYPE",
        TypeName = name,
        Sprite = sprite,
        AIFunc = ai
    }
end

function VMod:AddEnemy(enemy)
    if enemy[1] ~= "ENEMYMETATYPE" then
        return nil
    else
    end
end

function VMod:LoadImage(path)
    path = path or "nil"
    if path == "nil" then
        love.window.showMessageBox("MOD ERROR",
            "LoadImage : error loading image, no image path provided. this will cause the game to error!", "error")
    else return love.graphics.newImage("mods/" .. path)
    end
end

function VMod:AddCallback(callback, func)
    local isValidCallback = true
    for i, v in pairs(VMod.Callbacks) do
        if callback == v then
            isValidCallback = true
            break
        end
    end
    if isValidCallback ~= true then
        love.window.showMessageBox("MOD ERROR",
            " AddCallback: invalid callback!"
            , "error")
    else table.insert(callback, func)
    end
end

function VMod:NewItem(id, sprite, name, description, healamt)
    if sprite:getPixelWidth() ~= 16 or sprite:getPixelHeight() ~= 16 then
        love.window.showMessageBox("MOD ERROR",
            " NewItem: error creating new item '" .. name .. "', supplied sprite is not the correct size (16x16 pixels)!"
            , "error")
        logOutput = logOutput ..
            " NewItem: error creating new item '" ..
            name .. "', supplied sprite is not the correct size (16x16 pixels)! \n"

    else
        local item = Item(sprite, name, description, healamt)
        item.Damage = 0
        item.FireDelay = 0
        item.Speed = 0
        item.Range = 0
        item.id = id

        function item:setItemStats(dmg, firedelay, speed, range)
            self.Damage = dmg or 0
            self.FireDelay = firedelay or 0
            self.Speed = speed or 0
            self.Range = range or 0

        end

        function item:addBulletTags(tags)
            for i, tag in tags do
                table.insert(self.BulletTags, tag)
            end

        end

        item.Modded = "yep"
        return item
    end
end

function VMod:AddItemToPool(item)
    Items[item.id] = item
end

love.filesystem.createDirectory("mods")
local log = love.filesystem.newFile("mods/log.txt")
log:open("w")
local thing = love.filesystem.getDirectoryItems("mods")
logOutput = ""
for i, v in pairs(thing) do
    if checkFileExtension(v, 3) == ".lua" then
        logOutput = logOutput .. "FOUND FILE: " .. v .. "\n"
        local mod = love.filesystem.load("mods/" .. v)
        mod()

    end

end
local modslist = logOutput
log:write(tostring(modslist))

return VMod
