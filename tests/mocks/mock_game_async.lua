talker_game_async = {}

talker_game_async.repeat_until_true = function(seconds, func, ...)
    print('async')
    if func(...) then
        return func(...)
    else
        -- wait for the seconds
        os.execute("sleep " .. seconds)
        print("Waiting for " .. seconds .. " seconds")
        talker_game_async.repeat_until_true(seconds, func, ...)
    end
end

return talker_game_async