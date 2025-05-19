-- local logger = require "logger"
-- the goal of this module is to test the concept of a special logger: logger.start and logger.end
-- they behave as expected for the most part, the start logger explicitely receives all input args and the end
-- logs the return arguments

-- what makes them special is that during testing, a test can override the logger function to save or validate the data instead

function func_name()
    local info = debug.getinfo(2, "n")  -- Get info about the caller function
    local func_name = info.name or "[anonymous]"
    return func_name
end

local function print_args(...)
    local to_print = ''
    -- Pack the variable arguments into a table
    local terms = {...}
    for _, term in ipairs(terms) do
        to_print = to_print .. ', ' .. term
    end
    return to_print
end

function log_start(func_name, ...)
    local to_print = print_args(...)
    print(func_name .. '-' .. 'start' .. ': ' .. to_print)
end

function log_end(func_name, ...)
    local to_print = print_args(...)
    print(func_name .. '-' .. 'end' .. ': ' .. to_print)
end

function log_start(func_name, ...)
end


-- Example function
function exampleFunction(input_a, input_b)
    log_start(func_name(), input_a, input_b)
    print('blabla')
    log_end(func_name(), input_a, input_b)
end

exampleFunction('fish', 'cat')  -- This will print "exampleFunction"