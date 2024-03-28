<!-- markdownlint-disable MD041 -->
### Setup

#### Configuration

```lua,editable
Urgency:setup({
    adminPilotNames = {
        'Steve Jobs',
        'Linus Torvalds',
        'Bill Gates',
    },
    countdowns = {
        missionDuration = {
            reuse = false,
            startTrigger = {
                type = 'time',
                value = 0, -- mission start (or, well, as close as we can manage)
            },
            startFlag = 'MissionRunning',
            endTrigger = {
                type = 'time',
                value = 25200, -- 7 hours
            },
            endFlag = 'MissionTimeout',
            messages = {
                [0] = { to = 'blue', text = 'Mission is a go! We only get seven hours to complete our objectives!', duration = 15 },
                [-1800] = { to = 'blue', text = '30 minutes left in mission! Are we gonna make it?', duration = 15 },
                [-900] = { to = 'blue', text = '15 minutes left in mission! Are we gonna make it?', duration = 15 },
                [-600] = { to = 'blue', text = '10 minutes left in mission! Are we gonna make it?', duration = 15 },
                [-300] = { to = 'blue', text = '5 minutes left in mission! Are we gonna make it?', duration = 15 },
                [-60] = { to = 'blue', text = '1 minute left in mission! Are we gonna make it?', duration = 15 },
                [-30] = { to = 'blue', text = '30 seconds left in mission...', duration = 5 },
                [-15] = { to = 'blue', text = '15 seconds left in mission...', duration = 5 },
                [-10] = { to = 'blue', text = '10 seconds left in mission...', duration = 1 },
                [-9] = { to = 'blue', text = '9 seconds left in mission...', duration = 1 },
                [-8] = { to = 'blue', text = '8 seconds left in mission...', duration = 1 },
                [-7] = { to = 'blue', text = '7 seconds left in mission...', duration = 1 },
                [-6] = { to = 'blue', text = '6 seconds left in mission...', duration = 1 },
                [-5] = { to = 'blue', text = '5 seconds left in mission...', duration = 1 },
                [-4] = { to = 'blue', text = '4 seconds left in mission...', duration = 1 },
                [-3] = { to = 'blue', text = '3 seconds left in mission...', duration = 1 },
                [-2] = { to = 'blue', text = '2 seconds left in mission...', duration = 1 },
                [-1] = { to = 'blue', text = '1 seconds left in mission...', duration = 1 },
                [25200] = { to = 'all', text = "Time's up! Ending mission...", duration = 15 },
            },
        },
        easterEgg1 = {
            reuse = true,
            startTrigger = {
                type = 'event',
                value = {
                    id = world.event.S_EVENT_TRIGGER_ZONE,
                    filter = function(_event)
                        local _unit = _event.initiator
                        local _zone = _event.target

                        if _zone == 'egg1' then
                            return true
                        end

                        return false
                    end,
                },
            },
            startFlag = 'Egg1Found',
            endTrigger = {
                type = 'time',
                value = 3600, -- 1 hour
            },
            endFlag = 'Egg1Expired',
            messages = {
                [0] = { to = 'all', text = 'An Easter Egg Was Discovered!', duration = 15 },
                [3600] = { to = 'all', text = 'An Easter Egg Has Vanished!', duration = 15 },
            },
        },
    },
})
```

- `adminPilotNames` table
  - A list of pilots who should get the admin menu

- `countdowns` table
  - A list of countdowns to register at mission start
  - countdown
    - `reuse` whether to put this countdown back in the queue to be triggered again
    - `startTrigger` table
      - `type` one of `time`, `flag`, `event`, or `menu`
      - `value` the time, event id and handler, or menu text to trigger on
    - `startFlag` the flag to set true when the countdown starts
    - `endTrigger` table
      - `type` one of `time`, `flag`, `event`, or `menu`
      - `value` the time, event id and handler, or menu text to trigger on
    - `endFlag` the flag to set true when the countdown ends
    - `messages` a list of messages to display, keyed by the countdown's seconds since start (or seconds until end, if negative)
      - `text` the message to display
      - `duration` how long the message should be visible (in seconds)
