package.path = package.path .. ';./bin/lua/?.lua;./bin/lua/*/?.lua'
local luaunit = require('tests.utils.luaunit')
local mic = require('infra.mic.microphone') -- Import the microphone module
local file_io = require("infra.file_io")

-- Define test file name for microphone
local mic_test_file = "talker_mic_io_commands"
local mic_transcription_file = "talker_mic_io_transcription"

function testMicStart()
    -- Define a test transcription prompt
    local transcription_prompt = "Recording situation: Testing mic start"
    
    -- Start the microphone and check if it's active
    mic.start(transcription_prompt)
    luaunit.assertTrue(mic.is_mic_on())
    
    -- Verify that the content written matches the prompt
    local content = file_io.read_temp(mic_test_file)
    luaunit.assertEquals(content, "START-" .. transcription_prompt)
    
    -- Clean up
    file_io.override_temp(mic_test_file, "")
end

function testMicStop()
    -- Stop the microphone and check if it's inactive
    mic.start()
    mic.stop()
    luaunit.assertFalse(mic.is_mic_on())

    -- Verify that "STOP" was written to the temp file
    local content = file_io.read_temp(mic_test_file)
    luaunit.assertEquals(content, "STOP")
    
    -- Clean up
    file_io.override_temp(mic_test_file, "")
end

function testGetTranscription()
    -- Write a mock transcription to the file
    local transcription_content = "TRANSCRIPTION-Test transcription"
    file_io.override_temp(mic_transcription_file, transcription_content)
    
    -- Check if the get_transcription function returns the correct transcription
    local transcription = mic.get_transcription()
    luaunit.assertEquals(transcription,"TRANSCRIPTION-Test transcription")
    
    -- Clean up
    file_io.override_temp(mic_transcription_file, "")
end

function testGetTranscriptionNoPrefix()
    -- Write non-transcription content to simulate an invalid state
    file_io.override_temp(mic_test_file, "Some other content")

    -- Ensure that get_transcription returns nil when no transcription is found
    local transcription = mic.get_transcription()
    luaunit.assertNil(transcription)
    
    -- Clean up
    file_io.override_temp(mic_test_file, "")
end

os.exit(luaunit.LuaUnit.run())