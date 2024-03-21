<!-- markdownlint-disable MD041 -->
### Utils

#### `Gremlin.utils.displayMessageTo(_name, _text, _time)`

Displays a message to a named Unit, Group, Country, or Coalition, or to everyone with the special name `all`

---

#### `Gremlin.utils.parseFuncArgs(_args, _objs)`

Preps arguments for things like scheduled functions, with some limited autocompletion of Units and Groups. Use a string placeholder for these autocompletions that meets one of the following criteria:

- `'{unit}:name'` will be replaced by the corresponding Unit
- `'{group}:name'` will be replaced by the corresponding Group

For `_objs`, simply pass a table with the appropriate structure:

```lua
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

#### `Gremlin.utils.mergeTables(...)`

Combines two or more tables into a single one, for easier indexing and iteration across multiple tables.
