package.path = package.path .. ';./bin/lua/?.lua;./bin/lua/*/?.lua'
local luaunit = require('tests.utils.luaunit')

-- Mocks for game mod code
local game_api = {}
local mic = {}
local async = {}
local event_creator = {}
local DIK_keys = { DIK_LMENU = "left_alt_key" }

-- Mock implementations
function game_api.get_player()
    return { name = "Player1", position = { x = 0, y = 0, z = 0 } }
end

function game_api.get_nearby_characters(player)
    return {
        { name = "NPC1" },
        { name = "NPC2" },
        { name = "NPC3" },
    }
end

function game_api.get_name(character)
    return character.name
end

function game_api.is_player_alive()
    return true
end

mic.active = false
mic.prompt = nil
mic.transcription = nil




function mic.is_mic_on()
    return mic.active
end

function mic.start(prompt)
    mic.active = true
    mic.prompt = prompt
end

function mic.stop()
    mic.active = false
    mic.prompt = nil
end

function mic.get_transcription()
    return mic.transcription
end

function async.repeat_until_true(interval, func)
    -- For testing purposes, call the function immediately
    func()
end

local function table_to_args(table_input)
    local args = {}
    for key, value in pairs(table_input) do
        table.insert(args, value)
    end
    return unpack(args)
end

event_creator.last_event = nil

function event_creator.register_game_event_near_player(event_string, args)
    event_creator.last_event = string.format(event_string, table_to_args(args))
end

-- Import the module under test, replacing dependencies with mocks
local left_alt = DIK_keys.DIK_LMENU

local function get_names_of_nearby_characters()
    local player_obj = game_api.get_player()
    local nearby_characters = game_api.get_nearby_characters(player_obj)
    local names = {}
    for _, character in ipairs(nearby_characters) do
        table.insert(names, game_api.get_name(character))
    end
    return names
end

function create_transcription_prompt(list_of_names)
    local prompt = "START-STALKER setting, nearby characters are, "
    for i, name in ipairs(list_of_names) do
        prompt = prompt .. name
        if i < #list_of_names then
            prompt = prompt .. ", "
        end
    end
    return prompt
end

local function toggle_mic()
    if mic.is_mic_on() then
        mic.stop()
    else
        local names = get_names_of_nearby_characters()
        local prompt = create_transcription_prompt(names)
        mic.start(prompt)
    end
end

local function player_character_speaks(dialogue)
    local player_name = game_api.get_name(game_api.get_player())
    event_creator.register_game_event_near_player("%s said: %s", {player_name, dialogue})
end

local function on_key_press(key)
    if key ~= left_alt or not game_api.is_player_alive() then return end
    toggle_mic()
    async.repeat_until_true(0.1, function()
        local dialogue = mic.get_transcription()
        if dialogue then
            player_character_speaks(dialogue)
            return true
        end
    end)
end

function testGetNamesOfNearbyCharacters()
    local expected_names = {"NPC1", "NPC2", "NPC3"}
    local names = get_names_of_nearby_characters()
    luaunit.assertEquals(names, expected_names)
end

function testCreateTranscriptionPrompt()
    local names = {"NPC1", "NPC2", "NPC3"}
    local expected_prompt = "START-STALKER setting, nearby characters are, NPC1, NPC2, NPC3"
    local prompt = create_transcription_prompt(names)
    luaunit.assertEquals(prompt, expected_prompt)
end

function testToggleMicWhenOff()
    mic.active = false
    mic.prompt = nil
    toggle_mic()
    luaunit.assertTrue(mic.is_mic_on())
    local expected_prompt = "START-STALKER setting, nearby characters are, NPC1, NPC2, NPC3"
    luaunit.assertEquals(mic.prompt, expected_prompt)
end

function testToggleMicWhenOn()
    mic.active = true
    mic.prompt = "Existing Prompt"
    toggle_mic()
    luaunit.assertFalse(mic.is_mic_on())
    luaunit.assertNil(mic.prompt)
end

function testRegisterPlayerSpeakEvent()
    local dialogue = "Hello there!"
    player_character_speaks(dialogue)
    local expected_event = "Player1 said: Hello there!"
    luaunit.assertEquals(event_creator.last_event, expected_event)
end

function testOnKeyPressWithLeftAltAndPlayerAlive()
    mic.active = false
    mic.transcription = "Test dialogue"
    event_creator.last_event = nil

    on_key_press(left_alt)

    -- Mic should be toggled on
    luaunit.assertTrue(mic.is_mic_on())

    -- Mic prompt should be set correctly
    local expected_prompt = "START-STALKER setting, nearby characters are, NPC1, NPC2, NPC3"
    luaunit.assertEquals(mic.prompt, expected_prompt)

    -- Since async.repeat_until_true calls the function immediately, the event should be registered
    local expected_event = "Player1 said: Test dialogue"
    luaunit.assertEquals(event_creator.last_event, expected_event)
end

function testOnKeyPressWithNonLeftAltKey()
    mic.active = false
    mic.transcription = nil
    event_creator.last_event = nil

    on_key_press("other_key")

    -- Mic should not be toggled
    luaunit.assertFalse(mic.is_mic_on())
    luaunit.assertNil(mic.prompt)
    luaunit.assertNil(event_creator.last_event)
end

function testOnKeyPressWhenPlayerDead()
    mic.active = false
    mic.transcription = nil
    event_creator.last_event = nil

    -- Mock player is dead
    function game_api.is_player_alive()
        return false
    end

    on_key_press(left_alt)

    -- Mic should not be toggled
    luaunit.assertFalse(mic.is_mic_on())
    luaunit.assertNil(mic.prompt)
    luaunit.assertNil(event_creator.last_event)

    -- Restore player alive status for other tests
    function game_api.is_player_alive()
        return true
    end
end


os.exit(luaunit.LuaUnit.run())