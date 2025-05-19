package.path = package.path .. ";./bin/lua/?.lua;"
local file_io = require('infra.file_io')
local json = require('infra.HTTP.json')

local function wrap_recorder(func, name)
    return function(...)
        local result = { func(...) }
        -- Save the result to a file or database
        local file = "tests/infra/test_data/" .. name .. ".jsonl"
        local result_text = json.encode(result)
        file_io.add_line(file, result_text)
        return unpack(result)
    end
end

function create_recorder(game_adapter)
    for k, v in pairs(game_adapter) do
        if type(v) == "function" then
            game_adapter[k] = wrap_recorder(v, k)
        end
    end
    return game_adapter
end


local function get_recorded_data(name)
    local file = "tests/infra/test_data/" .. name .. ".jsonl"
    local lines = file_io.read(file)
    if not lines then
        error("No recorded data for " .. name)
    end
    local results = {}
    for line in lines:gmatch("([^\n]*)\n") do
        table.insert(results, json.decode(line))
    end
    return results
end

-- 

-- this function wraps a regular function and replaces it's functionality with pre-recorded outputs
function wrap_replayer(func_name)
    
end


return create_recorder