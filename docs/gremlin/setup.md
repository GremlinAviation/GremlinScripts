<!-- markdownlint-disable MD041 -->
## Setup

First, you need to add MiST to your mission. Follow [its instructions](https://github.com/mrSkortch/MissionScriptingTools) to do this.

Next, copy the contents of Gremlin Scripts' `src/` directory to your missions folder. Include `gremlin.lua` as a DoScriptFile action, immediately followed by the specific Gremlin Scripts you wish to use in your mission.

Finally, run a single line of code to set everything up. Note that the Gremlin Scripts will set up Gremlin Script Tools automatically, so unless you're building your own scripts on this framework, **you don't need to do this step in your own missions.**

```lua,editable
Gremlin:setup()
```

Yep. That's it. One line of code to ensure everything is working.

Of course, there are a couple of things that you can configure:

```lua,editable
Gremlin:setup({
    trace: false,
    debug: true,
})
```

- `trace`: boolean
  Turn on trace level logs if `true`
- `debug`: boolean
  Turn on debug level logs if `true`

If you aren't building your own script, you can still configure these by passing them to any Gremlin Script's `:setup()` method, instead.

That's it for now. Check out the rest of these docs for more info!
