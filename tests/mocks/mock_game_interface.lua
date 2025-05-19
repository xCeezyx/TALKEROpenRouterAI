local interface = {}
function interface.register_game_event(unformatted_description, event_objects, witnesses)
    local event_data = {
        unformatted_description, event_objects, witnesses
    }
    assert_or_record('triggers', 'testTriggerReload', event_data)
end

return interface
