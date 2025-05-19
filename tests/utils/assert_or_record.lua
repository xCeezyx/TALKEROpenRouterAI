package.path = package.path .. ";./bin/lua/?.lua;"
local luaunit = require('tests.utils.luaunit')
local files = require('infra.file_io')
local inspect = require('framework.inspect')

-- toggle this and run the tests to update the expected output
local override_mode = false

function assert_or_record(test_folder, test_name, actual)
    local file_name = "tests/" .. test_folder .. "/test_data/" .. test_name .. ".txt"
    local expected = files.read(file_name)
    local actual_inspect = inspect(actual)
    if expected == nil or override_mode then
        local success = files.override(file_name, actual_inspect)
        if not success then
            error("Failed to override file: ")
        end
    end
    if expected == nil then
        expected = files.read(file_name)
    end
    luaunit.assertEquals(actual_inspect, expected)
end

function record(test_folder, test_name, actual)
    local file_name = "tests/" .. test_folder .. "/test_data/" .. test_name .. ".txt"
    local actual_inspect = inspect(actual)
    local success = files.override(file_name, actual_inspect)
    if not success then
        error("Failed to override file: ")
    end
end

return assert_or_record