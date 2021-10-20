return {
    type = 'dealer',
    blip = vec(-40.709, -1099.769),
    doors = {
        {
            name = 'Street Entrance A',
            hash = 2059227086,
            type = 'door',
            coords = vec(-59.89302444458, -1092.9517822266, 26.883617401123),
            onstart = false,
            distance = 2.5,
            axis = nil,
        },
        {
            name = 'Street Entrance B',
            hash = 1417577297,
            type = 'door',
            coords = vec(-60.545818328857, -1094.7489013672, 26.888715744019),
            onstart = false,
            distance = 2.5,
            axis = nil,
        },
        {
            name = 'Car Park Entrance A',
            hash = 2059227086,
            type = 'door',
            coords = vec(-39.13366317749, -1108.2181396484, 26.719799041748),
            onstart = false,
            distance = 2.5,
            axis = nil,
        },
        {
            name = 'Car Park Entrance B',
            hash = 1417577297,
            type = 'door',
            coords = vec(-37.331127166748, -1108.8732910156, 26.719799041748),
            onstart = false,
            distance = 2.5,
            axis = nil,
        },
        {
            name = 'Office A',
            hash = -2051651622,
            type = 'door',
            coords = vec(-33.809894561768, -1107.5787353516, 26.572254180908),
            onstart = true,
            distance = 2.5,
            axis = nil,
        },
        {
            name = 'Office B',
            hash = -2051651622,
            type = 'door',
            coords = vec(-31.723529815674, -1101.8465576172, 26.572254180908),
            onstart = true,
            distance = 2.5,
            axis = nil,
        },
    },
    zones = {
        {
            name = 'Boss',
            type = 'boss',
            public = false,
            poly = {
                vec(-29.704624176025, -1110.2766113281),
                vec(-31.831315994263, -1116.0166015625),
                vec(-36.002246856689, -1114.4670410156),
                vec(-34.633644104004, -1111.32421875),
            },
            minZ = 25.5,
            maxZ = 27.5,
        },
        {
            name = 'Office',
            type = 'stash',
            public = false,
            poly = {
                vec(-28.818559646606, -1108.8767089844),
                vec(-33.348148345947, -1107.1220703125),
                vec(-32.114559173584, -1103.8699951172),
                vec(-29.746871948242, -1102.4656982422),
                vec(-26.987701416016, -1103.3507080078),
            },
            minZ = 25.5,
            maxZ = 27.5,
        },
        {
            name = 'Front Desk',
            type = 'property',
            public = false,
            poly = {
                vec(-54.791240692139, -1095.2119140625),
                vec(-59.913288116455, -1098.1843261719),
                vec(-58.330078125, -1100.8508300781),
                vec(-53.391841888428, -1097.990234375),
            },
            minZ = 25.5,
            maxZ = 27.5,
        },
        {
            name = 'Showroom',
            type = 'showroom',
            public = false,
            poly = {
                vec(-49.929862976074, -1088.7864990234),
                vec(-37.376575469971, -1093.6428222656),
                vec(-35.690528869629, -1098.9594726562),
                vec(-39.453567504883, -1107.9655761719),
                vec(-54.834255218506, -1101.9210205078),
            },
            minZ = 25.5,
            maxZ = 27.5,
        },
        {
            name = 'Garage A',
            type = 'garage',
            public = false,
            poly = {
                vec(-63.451034545898, -1119.6665039062),
                vec(-38.897029876709, -1118.3724365234),
                vec(-36.507881164551, -1111.7186279297),
                vec(-63.421985626221, -1102.1765136719),
            },
            minZ = 25.5,
            maxZ = 27.5,
        },
    },
}
