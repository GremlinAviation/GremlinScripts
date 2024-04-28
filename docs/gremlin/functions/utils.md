<!-- markdownlint-disable MD041 -->
### Utils

#### `Gremlin.utils.checkTrigger(_trigger, _type, _extra)`

Checks a trigger definition against a type and optional extra data - returns true when any conditions are met

---

#### `Gremlin.utils.countTableEntries(_tbl)`

Counts the number of entries in a table, regardless of type

---

#### `Gremlin.utils.getUnitZones(_unit)`

Looks up a list of all the zones a unit is currently in

---

#### `Gremlin.utils.innerSquash(_tbl, _idx)`

Flatten a table by one level, by removing the second level:

```lua
Gremlin.utils.innerSquash({
    walnut = { 'redWalnut', 'blueWalnut', [0] = 'noWalnut' },
    pecan = { 'redPecan', 'bluePecan', [0] = 'noPecan' },
    almond = { 'redAlmond', 'blueAlmond', [0] = 'noAlmond' },
}, coalition.side.BLUE)
```

would become

```lua
{
    walnut = 'blueWalnut',
    pecan = 'bluePecan',
    almond = 'blueAlmond',
}
```

---

#### `Gremlin.utils.inspect(_value, _depth)`

Converts a Lua value to a string for display or logging. It tries to make the string valid Lua, but there are a few types we can't reconstruct. Leave the second argument off if calling this directly!

---

#### `Gremlin.utils.isInTable(_tbl, _needle)`

Checks whether `_needle` is in the haystack `_tbl`

---

#### `Gremlin.utils.parseFuncArgs(_args, _objs)`

Preps arguments for things like scheduled functions, with some limited autocompletion of Units and Groups. Use a string placeholder for these autocompletions that meets one of the following criteria:

- `'{unit}:name'` will be replaced by the corresponding Unit
- `'{group}:name'` will be replaced by the corresponding Group

For `_objs`, simply pass a table with the appropriate structure:

```lua
{
    unit = Unit.getByName(unitName),
    group = Group.getByName(groupName),
}
```

---

#### `Gremlin.utils.mergeTables(...)`

Combines two or more tables into a single one, for easier indexing and iteration across multiple tables.
