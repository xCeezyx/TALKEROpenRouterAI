local luaunit = require('tests.utils.luaunit')
local cleaner = require('infra.AI.dialogue_cleaner')


function testRemoveSpeakerAndSingleQuotes()
    local input = "Speaker:'Message here'"
    local expected = "Message here"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testUncensorBasicProfanity()
    local input = "This f**k is censored"
    local expected = "This fuck is censored"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end


function testRemoveCharacterNameAndQuotes()
    local input = 'Character: "Hello there"'
    local expected = "Hello there"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testRemoveSurroundingQuotes()
    local input = '"Just quoted text"'
    local expected = "Just quoted text"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end


function testNoModificationNeeded()
    local input = "Plain text without quotes"
    local expected = "Plain text without quotes"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testMultipleUncensorings()
    local input = "This f**k and sh*t needs uncensoring"
    local expected = "This fuck and shit needs uncensoring"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testRegularResponse()
    local input = '"Complex quoted message"'
    local expected = "Complex quoted message"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testRegularResponseNoQuotes()
    local input = "Complex quoted message"
    local expected = "Complex quoted message"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testComplexQuoteRemoval()
    local input = 'Character_123:"Complex quoted message"'
    local expected = "Complex quoted message"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testComplexQuoteRemovalWithLastName()
    local input = 'Character_123 lastName: "Complex quoted message"'
    local expected = "Complex quoted message"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testComplexQuoteRemovalWithLastNameAndSaid()
    local input = 'Character_123 lastName said: "Complex quoted message"'
    local expected = "Complex quoted message"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testLastNameandFirstNameNoQuotes()
    local input = 'Character_123 lastName: Complex quoted message'
    local expected = "Complex quoted message"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testSpecialQuoteCharacters()
    local input = 'Speaker: "Special quotes"'
    local expected = "Special quotes"
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testDialogueClean(input, expected)
    local result = cleaner.improve_response_text(input)
    luaunit.assertEquals(result, expected)
end

function testSampleFromDiscord()
    local input = 'Private Anisiev: "Hope you packed a snorkel, \'cause it\'s about to rain lead on your parade!"'
    local expected = "Hope you packed a snorkel, 'cause it's about to rain lead on your parade!"
    testDialogueClean(input, expected)
end


function testResponseValidity()
    local valid_response = "This is a valid response"
    local invalid_response = "Sorry, I can't help with that request"
    
    luaunit.assertTrue(cleaner.was_response_valid(valid_response))
    luaunit.assertFalse(cleaner.was_response_valid(invalid_response))
end

os.exit(luaunit.LuaUnit.run())