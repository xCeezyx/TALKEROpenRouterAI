

package.path = package.path .. ';./bin/lua/?.lua'
package.path = package.path .. ';./bin/lua/*/?.lua'

local prompt_builder = require("infra.AI.prompt_builder")
local assert_or_record = require("tests.utils.assert_or_record")
local mock_situation = require("tests/mocks/mock_situation")
local luaunit = require('tests.utils.luaunit')

function TestCreatePickSpeakerPrompt()
    print("TestCreatePickSpeakerPrompt")
    local prompt = prompt_builder.create_pick_speaker_prompt(mock_situation, mock_situation[4].witnesses)
    assert_or_record('app', 'TestCreatePickSpeakerPrompt', prompt)
end

function TestCreateCompressMemoriesPrompt()
    print("TestCompressMemoriesPrompt")
    local prompt = prompt_builder.create_compress_memories_prompt(mock_situation)
    assert_or_record('app', 'TestCompressMemoriesPrompt', prompt)
end

function TestCreateDialogueRequestPrompt()
    print("TestCompressMemoriesPrompt")
    local speaker = mock_situation[1].witnesses[1]
    local prompt = prompt_builder.create_dialogue_request_prompt(speaker, mock_situation)
    assert_or_record('app', 'TestCreateDialogueRequestPrompt', prompt)
end

function TestCreateTranscriptionPrompt()
    print("TestCreateTranscriptionPrompt")
    local names = {"Alex", "Boris", "Catherine"}
    local prompt = prompt_builder.create_transcription_prompt(names)
    assert_or_record('app', 'TestCreateTranscriptionPrompt', prompt)
end

os.exit(luaunit.LuaUnit.run())

