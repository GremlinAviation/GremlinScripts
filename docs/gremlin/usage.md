<!-- markdownlint-disable MD041 -->
## Usage

Gremlin is an abstraction framework that makes working with DCS in scripts much simpler. It doesn't do much on its own, yet, but we're working on adding more! Here's how to use some of what's already working:

```lua,editable
Gremlin:setup()

Gremlin.log.info('My Cool DCS Script', 'Starting up!')

Gremlin.comms.displayMessageTo('test', 'Hullabaloo!', timer.getTime() + 1)

local myArgs = Gremlin.utils.parseFuncArgs({ '{unit}:test', '{group}:test', timer.getTime() }, {
    unit = {
        test: Unit:getByName('test'),
    },
    group = {
        test: Group:getByName('test'),
    },
})

local mergedList = Gremlin.utils.mergeTables(list1, list2, list3)
```

Clearly, the above script doesn't actually _do_ anything, besides show some of how the framework can be used. The [function documentation](./functions.md) will be more helpful when building scripts that actually do things.
