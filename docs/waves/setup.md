<!-- markdownlint-disable MD041 -->
### Setup

#### Configuration

```lua,editable
Waves:setup({
    adminPilotNames = {
        'Steve Jobs',
        'Linus Torvalds',
        'Bill Gates',
    },
    waves = {
        ['Wave 2'] = {
            trigger = {
                type = 'time',
                value = 12600, -- 3.5 hours
            },
            groups = {
                ['F-14B'] = {
                    category = Group.Category.AIRPLANE,
                    country = country.USA,
                    zone = 'Reinforcement Staging',
                    scatter = 15,
                    orders = {},
                    units = {
                        ['F-14B'] = 3,
                    },
                },
                ['Ground A'] = {
                    category = Group.Category.GROUND,
                    country = country.USA,
                    zone = 'Reinforcement Staging',
                    scatter = 5,
                    orders = {},
                    units = {
                        ['Infantry'] = 4,
                    }
                },
                ['Ground B'] = {
                    category = Group.Category.GROUND,
                    country = country.USA,
                    zone = 'Reinforcement Staging',
                    scatter = 5,
                    orders = {},
                    units = {
                        ['RPG'] = 1,
                        ['Infantry'] = 3,
                        ['JTAC'] = 1,
                    }
                },
            },
        },
    },
})
```

- `adminPilotNames` table
  - list of pilots who should see the menu
- `waves` table
  - collection of reinforcement waves for this mission
  - wave
    - `trigger` table
      - `type` one of `time`, `flag`, `event`, or `menu`
      - `value` a time, flag name / number, event id / filter, or menu item text
    - `groups` table
      - list of groups to spawn
      - group
        - `category` a member of `Groups.Category` indicating the group's category
        - `country` a `country` id
        - `zone` where to spawn the group
        - `scatter` how far apart, in meters, to scatter units at spawn
        - `orders` table
          - a list of [DCS AI tasks](https://www.digitalcombatsimulator.com/en/support/faq/1267/#3307680) for the group to perform
        - `units` table
          - key: the unit type to spawn
          - value: how many to spawn in the group
