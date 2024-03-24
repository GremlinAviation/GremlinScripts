<!-- markdownlint-disable MD041 -->
### Menu

Only one function in here for the moment! But it's pretty powerful, so the configuration can be a bit complex.

#### `Gremlin.menu.updateF10({ toolId, commands, getForUnits })`

> **WARNING - DO NOT CALL THIS FUNCTION MORE THAN ONCE PER SCRIPT!**
> This is a _great_ way to confuse the poor thing and break your missions.

Registers a set of menu commands to be updated automatically (every 10 seconds) by Gremlin itself. These commands will be grouped under a parent menu named after the tool itself - `Gremlin Evac` for `evac.lua`, `Gremlin Waves` for `waves.lua`, etc. Here's an example:

```lua,editable
Gremlin.menu.updateF10({ MyScript.Id, {
    {
        text = 'My Cool Unit Command',
        func = MyScript.commands.myCoolUnitFunc,
        args = { '{unit}:name' },
        when = true,
    },
    {
        text = 'My Cool Group Command',
        func = MyScript.commands.myCoolGroupFunc,
        args = { '{group}:name' },
        when = {
            func = MyScript.unit.inTheZone,
            args = { '{unit}:name' },
            comp = 'equal',
            value = true,
        },
    },
}, function()
    return MyScript._state.pilotedUnits
end })
```

- `toolId` - should be a string identifying your script by name for the menu. Should be the same value used for Gremlin's logging methods.

- `commands` - an array of commands to register
  - `text` - a string or a function that returns a string; used for the menu text
  - `func` - the function to call when this menu command is selected
  - `args` - any arguments to pass to `func` (and `text`, if it's a function)
    - `{unit}:name` - placeholder value for the name of the unit whose menu is being updated
    - `{group}:name` - placeholder value for the name of the group whose menu is being updated
  - `when` - indicates when a command should be visible in the menu; can either be a boolean or a table
    - `func` - the function to call when deciding whether to add a command to the menu
    - `args` - the arguments to pass to `func`; uses the same placeholders as `args` a level up
    - `comp` - one of `equal` or `inequal` (at the moment); denotes what kind of comparison to make between `func`'s return value and `value`
    - `value` - the value to compare against `func`'s result

- `getForUnits` - a function that returns a table of units to add menus to; this is a function so that your list can change over time
