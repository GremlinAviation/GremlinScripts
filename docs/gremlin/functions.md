<!-- markdownlint-disable MD041 -->
## Functions

### `Gremlin.logError(toolId, message)`

Logs an error message, the highest level DCS supports

### `Gremlin.logWarn(toolId, message)`

Logs a warning message

### `Gremlin.logInfo(toolId, message)`

Logs an info message

### `Gremlin.logDebug(toolId, message)`

Logs a debug message, if they're enabled

### `Gremlin.logTrace(toolId, message)`

Logs a trace message, if they're enabled

---

### `Gremlin.displayMessageTo(_name, _text, _time)`

Displays a message to a named Unit, Group, Country, or Coalition, or to everyone with the special name `all`

---

### `Gremlin.parseFuncArgs(_args, _objs)`

Preps arguments for things like scheduled functions, with some limited autocompletion of Units and Groups. Use a string placeholder for these autocompletions that meets one of the following criteria:

- `'{unit}:name'` will be replaced by the corresponding Unit
- `'{group}:name'` will be replaced by the corresponding Group

For `_objs`, simply pass a table with the appropriate structure:

```lua,editable
{
    unit = {
        [unitName] = Unit.getByName(unitName),
    },
    group = {
        [groupName] = Group.getByName(groupName),
    },
}
```

---

### `Gremlin.mergeTables(...)`

Combines two or more tables into a single one, for easier indexing and iteration across multiple tables.

---

### `Gremlin:setup(config)`

Sets up Gremlin Scripting Tools. Docs for this are in [the setup section](./setup.md).
