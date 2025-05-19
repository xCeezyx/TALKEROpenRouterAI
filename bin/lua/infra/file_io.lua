-- file_io.lua is a module that provides functions for reading and writing files.
local file_io = {}

-- forgive me, for I have sinned, this module uses hacky boolean flags that are there for legacy reasons
-- TODO redeem myself

-- hacky load late
local function get_base_path()
    local game_files = talker_game_files or require('tests.mocks.mock_game_adapter')
    return game_files.get_base_path()
end

function file_io.read(file_name, not_game)
    local full_path = not_game and file_name or get_base_path() .. file_name
    local file = io.open(full_path, "r")
    if file == nil then
        return nil
    end
    local contents = file:read("*a")
    file:close()
    return contents
end

function file_io.write(file_name, contents, not_game)
    local full_path = not_game and file_name or get_base_path() .. file_name
    contents = contents or ""
    local file, err = io.open(full_path, "a")
    if not file then
        print("Error opening file:", err)
        return false
    end
    local success, err = file:write(contents)
    if not success then
        print("Error writing to file:", err)
        return false
    end
    file:close()
    return true
end

function file_io.add_line(file_name, contents)
    return file_io.write(file_name, contents .. "\n")
end

function file_io.override(file_name, contents, not_game)
    local full_path = not_game and file_name or get_base_path() .. file_name
    local file, err = io.open(full_path, "w")
    if not file then
        print("Error opening file:", err)
        return false
    end
    local success, err = file:write(contents)
    if not success then
        print("Error writing to file:", err)
        return false
    end
    file:close()
    return true
end

function file_io.delete(file_name, not_game)
    local full_path = not_game and file_name or get_base_path() .. file_name
    os.remove(full_path)
    return true
end

-- temp files

function get_MIC_FILE_PATH(filename)
    local temp_dir = os.getenv("TMPDIR") or os.getenv("TMP") or os.getenv("TEMP")
    if not temp_dir then
        error("Temporary directory not found")
    end
    return temp_dir .. "/" .. filename
end

function file_io.read_temp(filename)
    local MIC_FILE_PATH = get_MIC_FILE_PATH(filename)
    local contents = file_io.read(MIC_FILE_PATH, true)
    if not contents then
        error("Temporary file not found: " .. MIC_FILE_PATH)
    end
    return contents
end

function file_io.override_temp(filename, contents)
    local MIC_FILE_PATH = get_MIC_FILE_PATH(filename)
    local success = file_io.override(MIC_FILE_PATH, contents, true)
    if not success then
        error("Failed to write to temporary file: " .. MIC_FILE_PATH)
    end
    return success
end


return file_io