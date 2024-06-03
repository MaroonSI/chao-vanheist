Config                  = {}
Config.ox_target        = true

Config.DeliveryStations = {
	-- PostOp = {
    --     Vehicle = 'boxville2',
    --     Blip = {
    --         blipLabel = "PostOp Warehouse",
    --         blipCoords = vector3(-429.615, -2789.28, 6.5285), --vector3(1183.032, -3323.88, 6.0287)
    --         blipID = 478, 
    --         blipScale = 0.8,
    --         blipColor = 16, 
    --         blipToggle = true,
    --     },
    --     SpawnPoint = {
    --         coords = vector3(-413.257, -2793.60, 6.0003), 
    --         heading = 317.03,
    --     },
    --     JobPoint = {
    --         coords = vector3(),
    --         marker = 2,
    --         blip = 1,
    --     },
    --     Jobs = {
    --         vector3(),
    --         vector3(),
    --         vector3(),
    --         vector3(),
    --     }
    -- },
    AlphaMail = {
        Vehicle = 'boxville2',
        Blip = {
            blipLabel = "AlphaMail Warehouse",
            blipCoords = vector3(1225.907, -3234.75, 6.0287), 
            blipID = 478, 
            blipScale = 0.8,
            blipColor = 16, 
            blipToggle = true,
        },
        SpawnPoint = {
            coords = vector3(1233.583, -3230.71, 5.6753), 
            heading = 0.55,
        },
        JobPoint = {
            coords = vector3(1242.127, -3234.42, 6.0287),
            marker = 2,
            blip = 1,
        },
        Jobs = {
            {},
            1,
            1,
            1,
            1,
            1,
        }
    },
    -- GoPostal = {
    --     Vehicle = 'boxville2',
    --     Blip = {
    --         blipLabel = "GoPostal Warehouse",
    --         blipCoords = vector3(84.38631, 110.3909, 79.186), 
    --         blipID = 478, 
    --         blipScale = 0.8,
    --         blipColor = 16, 
    --         blipToggle = true,
    --     },
    --     SpawnPoint = {
    --         coords = vector3(70.22800, 120.9349, 79.165), 
    --         heading = 158.47,
    --     },
    --     JobPoint = {
    --         coords = vector3(),
    --         marker = 2,
    --         blip = 1,
    --     },
    --     Jobs = {
    --         vector3(),
    --         vector3(),
    --         vector3(),
    --         vector3(),
    --     }
    -- },
}

Config.DeliveryPoints = {
    vector3(-2007.41, 367.2967, 94.814),
    vector3(-1932.45, 362.1942, 93.790),
    vector3(-1941.12, 403.8673, 96.507),
    vector3(1302.010, -530.093, 71.262),
    vector3(1324.746, -580.539, 73.213),
    vector3(1347.341, -549.523, 73.820),
}

Config.StarterPeds = {
    Supervisors = {
        [1] = { --Post Op
            pedModel = "s_m_m_ups_01",
            pedCoords = vector4(-429.615, -2789.28, 6.5285 - 1, 226.39), --vector4(1183.032, -3323.88, 6.0287 - 1, 90.0)
            pedAnims = "WORLD_HUMAN_CLIPBOARD",
        },
        [2] = { --AlphaMail
            pedModel = "s_m_y_airworker",
            pedCoords = vector4(1225.904, -3234.74, 6.0233 - 1, 0.0),
            pedAnims = "WORLD_HUMAN_CLIPBOARD",
        },
        [3] = { --GoPostal
            pedModel = "s_m_m_postal_01",
            pedCoords = vector4(84.18168, 110.5302, 79.186 - 1, 160.0),
            pedAnims = "WORLD_HUMAN_CLIPBOARD",
        },
    },
}