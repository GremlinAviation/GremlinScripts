# Gremlin Scripts

This is the Gremlin Scripts repo! Everything you need to succeed with DCS mission scripting can be found within.

## Installation

Simply copy the contents of the `src` directory to your `Missions` folder in `Saved Games`. If you like, you can also grab MiST from this project's `lib` folder, though it's usually best to grab the latest version [directly from GitHub](https://github.com/mrSkortch/MissionScriptingTools).

Once you have the files in place, add a trigger to load MiST (follow its documentation for the best ways to do this), a second to load Gremlin Script Tools, and then a third to load the exact script you wish to use, such as Gremlin Evac. Once all three are loaded, the final step is to fully set up the script(s) to do their thing - see the relevant Configuration section, below, for more on this.

And that's it! The scripts are installed and working from this point on.

## Components

### gremlin.lua

The Gremlin Script Tools file provides common features that all Gremlin Scripts use to do their thing. It must be loaded after MiST, and before any other Gremlin Scripts components.

### evac.lua

The Gremlin Evac script sets up your missions to include evacuation scenarios. Simply call `Evac:setup()` to get sane defualts, or customize everything by filling out the available options you wish to override. [Full documentation is here](https://ilsystems.github.io/GremlinScripts/evac/).

## Development and Testing

Gremlin Scripts are fully tested before release. You can run these tests yourself by simply running `runtests.bat` at the top level of this project. It will run _all_ defined tests, at the moment, but that's fine since only Gremlin Evac is available today.

Development follows standard project rules for Git - create a fork, make your changes on a new branch, submit a PR on GitHub, and we'll review and do our best to merge. If none of these words make any sense to you, let us know and we'll help you figure something out.
