# RS-JobCentre

A comprehensive job center script for FiveM servers with QBCore and ESX framework compatibility.

## Features

- Sleek and modern UI for job browsing and application
- Compatible with QBCore and ESX frameworks
- Support for QB and OX target systems
- Multiple interaction methods:
  - Command-based interaction
  - Target point interaction
  - NPC interaction with customizable peds
- Configurable job settings with auto-assign option
- Automatic waypoint setting to job locations
- Job history tracking
- Blip creation for job center locations

## Installation

1. Download the resource
2. Place it in your server's resources folder
3. Add `ensure rs-jobcentre` to your server.cfg
4. Configure the `config.lua` file to your liking
5. Restart your server

## Configuration

The `config.lua` file contains all the configurable options:

- Framework selection (QBCore or ESX)
- Target system selection (QB or OX)
- Interaction method selection:
  - `command`: Use a chat command to open the job center
  - `target_point`: Interact with specific locations using target system
  - `target_ped`: Interact with NPC job agents using target system
- Job center locations with blip settings (for target_point method)
- Job center ped configurations (for target_ped method)
- Command name (for command method)
- Automatic waypoint setting toggle
- Job definitions with descriptions, requirements, and locations
- Job history limit

### Adding Jobs

To add a new job, add an entry to the `Config.Jobs` table in `config.lua`:

```lua
['jobname'] = {
    label = "Job Title",
    description = "Job description text",
    salary = "Salary range",
    requirements = "Job requirements",
    autoAssign = true, -- Set to true to automatically give the job, false will only set waypoint
    jobLocation = vector3(x, y, z), -- Location where the job starts
    icon = "icon.png" -- Image in html/img/ folder
}
```

## Usage

### Player Usage

1. Visit any job center location
2. Interact with the job center NPC or target
3. Browse available jobs
4. Apply for desired jobs
5. If auto-assign is enabled, the job will be assigned immediately
6. A waypoint will be set to the job location (if enabled in config)
7. View job history in the "Job History" tab



## Dependencies

- QBCore or ESX framework
- QB-Target or OX-Target

## Credits

- Created by NRG Development

If you have any issues or suggestions, please open a ticket at our discord:
https://discord.gg/xkS7PtGN2W

