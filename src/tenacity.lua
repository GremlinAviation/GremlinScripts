--[[--
Gremlin Tenacity

DO NOT EDIT THIS SCRIPT DIRECTLY! Things WILL break that way.

Instead!

When calling `Tenacity:setup()`, you can pass in a configuration table instead
of `nil`. Make your changes in the table you pass - defaults are already in
place if you want to leave those out.

An example, providing all the defaults, is available in the docs, or near
the end of this script.

@module Tenacity
--]]--
Tenacity = {
    Id = 'Gremlin Tenacity',
    Version = '202406.01',

    config = {},
    _internal = {},
    _state = {},
}

--[[--
Setup Gremlin Tenacity

The argument should contain a configuration table as shown below.

Example providing all the defaults:

```
Tenacity:setup({
})
```

@function Tenacity:setup
@tparam table config
--]] --
function Tenacity:setup(config)
    if config == nil then
        config = {}
    end

    assert(Gremlin ~= nil,
        '\n\n** HEY MISSION-DESIGNER! **\n\nGremlin has not been loaded!\n\nMake sure Gremlin is loaded *before* running this script!\n')

    if not Gremlin.alreadyInitialized or config.forceReload then
        Gremlin:setup(config)
    end

    if Tenacity.alreadyInitialized and not config.forceReload then
        Tenacity.log.info(Tenacity.Id, string.format('Bypassing initialization because Tenacity.alreadyInitialized = true'))
        return
    end

    if config ~= nil then
        -- // TODO
    end

    Tenacity.alreadyInitialized = true
end
