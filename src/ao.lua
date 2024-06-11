--[[--
Gremlin AO

DO NOT EDIT THIS SCRIPT DIRECTLY! Things WILL break that way.

Instead!

When calling `AO:setup()`, you can pass in a configuration table instead
of `nil`. Make your changes in the table you pass - defaults are already in
place if you want to leave those out.

An example, providing all the defaults, is available in the docs, or near
the end of this script.

@module AO
--]]--
AO = {
    Id = 'Gremlin AO',
    Version = '202406.01',

    config = {},
    _internal = {},
    _state = {},
}

--[[--
Setup Gremlin AO

The argument should contain a configuration table as shown below.

Example providing all the defaults:

```
AO:setup({
})
```

@function AO:setup
@tparam table config
--]] --
function AO:setup(config)
    if config == nil then
        config = {}
    end

    assert(Gremlin ~= nil,
        '\n\n** HEY MISSION-DESIGNER! **\n\nGremlin has not been loaded!\n\nMake sure Gremlin is loaded *before* running this script!\n')

    if not Gremlin.alreadyInitialized or config.forceReload then
        Gremlin:setup(config)
    end

    if AO.alreadyInitialized and not config.forceReload then
        AO.log.info(AO.Id, string.format('Bypassing initialization because AO.alreadyInitialized = true'))
        return
    end

    if config ~= nil then
        -- // TODO
    end

    AO.alreadyInitialized = true
end
