---@diagnostic disable: different-requires

local mock_characters = require('tests/mocks/mock_characters')
local Event = require('domain.model.event')

local killer = mock_characters[1]
local victim = mock_characters[2]
local witnesses = {mock_characters[1], mock_characters[2], mock_characters[3], mock_characters[4], mock_characters[5], mock_characters[6]}

local events = { -- lead up to the kill
-- insult
    Event.create_event("%s lost the map", {victim}, 0, "Cordon", witnesses),
    -- insult
    Event.create_event("%s insulted %s", {victim, killer}, 100, "Cordon", witnesses),
    -- fight
    Event.create_event("%s fought %s", {killer, victim}, 200, "Cordon", witnesses),
    -- kill
    Event.create_event("%s killed %s", {killer, victim}, 300, "Cordon", witnesses)
}

return events