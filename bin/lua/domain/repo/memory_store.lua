local Event = require "domain.model.event"
-- memory_store:lua
package.path = package.path .. ";./bin/lua/?.lua;"
local event_store = require("domain.repo.event_store")
local logger = require('framework.logger')

local memory_store = {}
local compressed_memories = {}

 -- for saving and loading
function memory_store:get_save_data()
    return compressed_memories
end

function memory_store:clear()
    compressed_memories = {}
end

function memory_store:load_save_data(saved_compressed_memories)
    compressed_memories = saved_compressed_memories
end

-- local functions
local function create_memory(content, game_time_ms)
    return {
        content = content,
        game_time_ms = game_time_ms
    }
end

-- main module
function memory_store:get_memories(character_id)
    local memories = {}
    local events = event_store:get_all_events()
    for i, event in ipairs(events) do
        if Event.was_witnessed_by(event, character_id) then
            table.insert(memories, event)
        end
    end
    table.sort(memories, function(a, b) return a.game_time_ms < b.game_time_ms end)
    return memories
end

function memory_store:store_compressed_memory(character_id, content, game_time_ms)
    local memory = create_memory(content, game_time_ms)
    if not compressed_memories[character_id] then
        compressed_memories[character_id] = {}
    end
    table.insert(compressed_memories[character_id], memory)
end

function memory_store:get_compressed_memories(character_id)
    return compressed_memories[character_id] or {}
end

function memory_store:get_new_memories(character_id)
    if not character_id then
        error("memory_store:get_new_memories: No character id provided")
    end
    logger.debug("Getting new memories for character: " .. character_id)
    local last_compressed_memory_time = 0
    local compressed = compressed_memories[character_id]

    if compressed and #compressed > 0 then
        last_compressed_memory_time = compressed[#compressed].game_time_ms
        logger.debug("Last compressed memory time: " .. last_compressed_memory_time)
    end

    local events = event_store:get_all_events()
    logger.debug("Total events: " .. #events)
    local uncompressed_memories = {}

    for i = #events, 1, -1 do
        local event = events[i]
        logger.spam("Checking event")
        if Event.was_witnessed_by(event, character_id) and event.game_time_ms > last_compressed_memory_time then
            table.insert(uncompressed_memories, event)
            logger.debug("Added new memory at time: " .. event.game_time_ms)
        else
            logger.spam("Not adding memory at time: " .. event.game_time_ms)
        end
    end
    logger.debug("Total new memories: " .. #uncompressed_memories)
    return uncompressed_memories
end

-- for the input speaker id, retrieves all new memories and the latest compressed memory
function memory_store:get_current_memories(character_id)
    if type(character_id) ~= "string" then
        error("character_id must be string")
    end
    if not character_id then
        error("memory_store:get_current_memories: No speaker id provided")
    end
    local new_memories = memory_store:get_new_memories(character_id)
    logger.debug("New memories: " .. #new_memories)
    local current_compressed_memories = memory_store:get_compressed_memories(character_id)
    logger.debug("Compressed memories: " .. #current_compressed_memories)

    -- todo, why does this need sorting? Verify all output is chronological from the start
    table.sort(new_memories, function(a, b) return a.game_time_ms < b.game_time_ms end)
    table.sort(current_compressed_memories, function(a, b) return a.game_time_ms < b.game_time_ms end)
    logger.debug("Sorted new memories: " .. #new_memories)

    local current_memories = new_memories
    -- insert the latest compressed memory at the start
    if #current_compressed_memories > 0 then
        logger.debug("Inserting last compressed memory")
        local last_memory = current_compressed_memories[#current_compressed_memories]
        table.insert(current_memories, 1, last_memory)
    end
    logger.debug("Current memories: " .. #current_memories)
    return current_memories
end

local function merge_table(t1, t2)
    for _, v in ipairs(t2) do
        table.insert(t1, v)
    end
    table.sort(t1, function(a, b) return a.game_time_ms < b.game_time_ms end)  -- Ensure the merged table is sorted
end

-- gets new and compressed memories ready for dialogue generation
function memory_store:get_all_memories(character_id)
    if type(character_id) ~= "string" then
        error("character_id must be string")
    end
    if not character_id then
        error("memory_store:get_all_memories: No character id provided")
    end
    logger.debug("Getting all memories for character: " .. character_id)
    local memories = memory_store:get_compressed_memories(character_id)
    logger.debug("Compressed memories: " .. #memories)
    local new_memories = memory_store:get_new_memories(character_id)
    logger.debug("New memories: " .. #new_memories)

    merge_table(memories, new_memories)
    logger.debug("All memories: " .. #memories)
    return memories
end

-- for mocks

function memory_store:insert_mocks(mock_event_store)
    event_store = mock_event_store
end
return memory_store