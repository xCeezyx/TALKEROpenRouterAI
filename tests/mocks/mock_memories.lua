---@diagnostic disable: different-requires

local memory_store = require('domain.repo.memory_store')
local mock_event_store = require('domain.repo.event_store')
memory_store:insert_mocks(mock_event_store)

local character_id = '1'
local content = 'This is a memory content'
local game_time_ms = 50

memory_store:store_compressed_memory(character_id, content, game_time_ms)

return memory_store