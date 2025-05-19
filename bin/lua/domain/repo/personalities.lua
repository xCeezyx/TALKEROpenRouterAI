package.path = package.path .. ";./bin/lua/?.lua;"
local log = require("framework.logger")
local unique_characters = require("infra.STALKER.unique_characters")
local queries = talker_game_queries or require("tests.mocks.mock_game_queries")

local M = {}
local character_personalities = {}

function M.set_queries(q)
    log.spam("Setting queries...")
    queries = q
end

local function get_random_faction_personality(faction)
    log.spam("Fetching random personality for faction: "..faction)
    return queries.load_random_xml("traits_" .. faction)
end

local function get_random_personality()
    log.spam("Fetching a generic random personality...")
    return queries.load_random_xml("traits")
end

local function set_random_personality(character)
    -- If the character is unique, we need to assign a specific personality
    if tostring(character.game_id) == "0" then
        return "" -- player
    end
    if queries.is_unique_character_by_id(character.game_id) then
        log.debug("Handling unique character: "..character.game_id)
        local tech_name = queries.get_technical_name_by_id(character.game_id)
        local personality = unique_characters[tech_name]
        if not personality then
            log.warn("No personality found for unique character: ".. tech_name)
            return
        end
        character_personalities[character.game_id] = unique_characters[tech_name]
        return
    end
    -- Otherwise, we assign a random personality based on the faction
    local personality = get_random_faction_personality(character.faction)
    if not personality or personality == "" then
        log.spam("Faction personality empty, loading generic personality.")
        personality = get_random_personality()
    end
    log.spam("Assigning random personality to character: "..character.game_id .. " - " .. personality)
    character_personalities[character.game_id] = personality
end

function M.get_personality(character)
    log.spam("Retrieving personality for character: "..character.game_id)
    local personality = character_personalities[character.game_id]
    if not personality then
        log.spam("No personality cached, setting a random one.")
        set_random_personality(character)
        personality = character_personalities[character.game_id]
        if not personality then
            log.warn("No personality found after assignment: "..character.game_id)
        end
    end
    return personality or ""
end

function M.get_save_data()
    log.debug("Returning character personalities for save.")
    return character_personalities
end

function M.clear()
    log.debug("Clearing character personalities cache.")
    character_personalities = {}
end

function M.load_save_data(saved_character_personalities)
    log.debug("Loading saved character personalities.")
    character_personalities = saved_character_personalities
end

return M
