-- Item class definition
Item = {}
Item.__index = Item

function Item.new(game_id, name)
    local self = setmetatable({}, Item)
    self.game_id = game_id
    self.name = name
    return self
end

function Item.describe(item)
    return string.format("%s, a %s %s", item.name)
end

function Item.describe_short(item)
    return item.name
end

return Item