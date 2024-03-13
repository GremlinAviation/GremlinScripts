<!-- markdownlint-disable MD041 -->
## Usage

Gremlin Script Tools is an abstraction framework built on MiST. It doesn't do much on its own, yet, but we're working on adding more! Here's how to use what's already working:

```lua,editable
Gremlin:setup()

Gremlin.log.info('My Cool DCS Script', 'Starting up!')

Gremlin.utils.displayMessageTo('test', 'Hullabaloo!', timer.getTime() + 1)

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
