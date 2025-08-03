Config = {}

Config.Framework = 'qb' -- Options: 'qb', 'esx'
Config.Target = 'qb' -- Options: 'qb', 'ox'

-- Interaction Method: 'command', 'target_point', 'target_ped'
Config.InteractionMethod = 'target_ped' -- Choose how players interact with the job center

-- Command Settings (if InteractionMethod = 'command')
Config.Command = 'jobcentre' -- Command to open job center

-- Target Point Settings (if InteractionMethod = 'target_point')
Config.JobCentreLocations = {
    {
        coords = vector3(-269.46, -955.38, 31.22),
        blip = {
            enabled = true,
            sprite = 407,
            color = 0,
            scale = 0.8,
            label = "Job Centre"
        }
    },
}

-- Target Ped Settings (if InteractionMethod = 'target_ped')
Config.JobCentrePeds = {
    {
        model = "a_m_y_business_03", -- Ped model
        coords = vector4(-269.46, -955.38, 31.22, 180.0), -- x, y, z, heading
        scenario = "WORLD_HUMAN_CLIPBOARD", -- Animation scenario
        blip = {
            enabled = true,
            sprite = 407,
            color = 0,
            scale = 0.8,
            label = "Job Centre"
        }
    },
}

Config.AutoSetWaypoint = true -- Set to false if you want players to manually set waypoints

Config.Jobs = {
    ['taxi'] = {
        label = "Taxi Driver",
        description = "Drive around the city and transport passengers to their destinations.",
        salary = "$500 - $1500 per hour",
        requirements = "Driver's License",
        autoAssign = true, -- Set to true to automatically give the job, false will only set waypoint
        jobLocation = vector3(895.46, -179.52, 74.7), -- Location where the player can start the job
        icon = "taxi.png" -- Image in html/img/ folder
    },
    ['trucker'] = {
        label = "Truck Driver",
        description = "Transport goods across the state with heavy vehicles.",
        salary = "$1000 - $2000 per hour",
        requirements = "Commercial Driver's License",
        autoAssign = true,
        jobLocation = vector3(1208.68, -3115.19, 5.54),
        icon = "truck.png"
    },
}

Config.MaxJobHistory = 10 -- Maximum number of job entries in history