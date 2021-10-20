
-- houses
INSERT INTO `dd_properties` (id, blip) VALUES
	('The De Santa Residence', '[-803.4,175.9]'),
	('The Clinton Residence', '[-14.9,-1433.2]'),
	('3671 Whispymound Drive', '[-4.7,523.5]'),
	('Casa Philips', '[1973.6,3818.2]'),
	('7611 Goma Street', '[-1148.3,-1523.0]'),
	('The Crest Residence', '[1274.4,-1712.6]')
;

-- assigned properties
INSERT INTO `dd_properties` (id, owner, type, blip) VALUES
	('Sandy Shores SS', 'BCSO', 'law', '[1854.379,3687.33]'),
	('Paleto Bay SO', 'PBPD', 'law', '[-447.033,6014.55]'),
	('Cental Los Santos MC', 'BCHD', 'hospital', '[296.214,-1446.055]'),
	('Sandy Shores MC', 'BCHD', 'hospital', '[1827.779,3693.37]'),
	('Fort Zancudo MilSurp Vehicles', 'Fort Zancudo', 'dealer', '[-1831.178,2976.809]'),
	('Merryweather Dock', 'Peregrine Security', 'security', '[484.2,-3112.8]'),
	('Fort Zancudo', 'Fort Zancudo', 'military', '[-2345.2,3267.3]')
;

-- other properties
INSERT INTO `dd_properties` (id, type, blip) VALUES
	('Mirror Park Parking', 'garage', '[1032.0,-773.4]'),
	('Grove Street Parking', 'garage', '[-57.3,-1838.2]'),
	('Vinewood Bowl Parking', 'garage', '[689.4,614.0]'),
	('Pacific Bluffs Parking', 'garage', '[-2030.6,-465.7]'),
	('Harmony Parking', 'garage', '[1122.4,2662.5]'),
	('Grapeseed Airfield', 'airfield', '[2133.1,4782.3]'),
	('Sandy Shores Airfield', 'airfield', '[1710.4,3289.8]'),
	('N.O.O.S.E.', 'law', '[2516.8,-384.0]'),
	('Bolingbroke', 'prison', '[1691.438,2595.698]'),
	('Puerto Del Sol Yacht Club', 'dealer', '[-702.439,-1405.02]'),
	('Devin Weston Hangar', 'dealer', '[-956.998,-2988.354]'),
	('Benny''s Customs', 'mechanic', '[-212.941,-1325.022]'),
	('La Mesa LS Customs', 'mechanic', '[734.177,-1082.206]'),
	('LSIA LS Customs', 'mechanic', '[-1154.789,-2006.126]'),
	('Burton LS Customs', 'mechanic', '[-338.47,-136.324]'),
	('Route 68 LS Customs', 'mechanic', '[1178.587,2639.246]'),
	('Beeker''s Garage', 'mechanic', '[108.049,6623.952]'),
	('Tequila La La', 'club', '[-556.6,285.6]'),
	('Yellow Jack Inn', 'club', '[1987.4,3051.1]'),
	('Vanilla Unicorn', 'club', '[119.3,-1288.1]'),
	('Clucking Bell', 'industrial', '[-69.2,6254.5]'),
	('Darnell Bros', 'industrial', '[713.2,-963.4]'),
	('South LS Recycling', 'industrial', '[-344.5,-1561.9]'),
	('Rogers Salvage & Scrap', 'scrap', '[-620.1,-1619.2]'),
	('Thomson Scrapyard', 'scrap', '[2398.1,3104.6]'),
	('Murrieta Oil Field Scrapyard', 'scrap', '[1545.7,-2120.0]'),
	('Red''s Machine Supplies', 'scrap', '[-186.3,6280.7]'),
	('Pillbox Hill GoPostal', 'courier', '[-261.597,-839.2]'),
	('Downtown Vinewood GoPostal', 'courier', '[66.496,124.502]'),
	('Pillbox Hill PostOP', 'courier', '[-231.689,-913.17]'),
	('Paleto Bay PostOP', 'courier', '[-422.162,6132.338]'),
	('PoLS PostOP', 'courier', '[-412.407,-2798.336]'),
	('Terminal PostOP', 'courier', '[1195.814,-3254.502]'),
	('Del Perro Pier', 'pier', '[-1691.9,-1098.6]'),
	('The O''Neil Ranch', 'outlaw', '[2443.1,4975.0]'),
	('The Lost Clubhouse', 'outlaw', '[972.1,-124.5]'),
	('Stab City', 'outlaw', '[58.6,3712.1]'),
	('Galilee', 'outlaw', '[1323.2,4336.3]'),
	('Ace Liquor', 'outlaw', '[1390.9,3607.6]'),
	('Cape Catfish', 'outlaw', '[3808.0,4462.9]'),
	('Dignity Village', 'outlaw', '[1477.4,6363.8]'),
	('Senora Desert Trailer Park', 'outlaw', '[2330.1,2572.5]'),
	('Altruist Camp', 'altruist', '[-1115.5,4926.7]'),
	('Downtown Cab Co', 'taxi', '[906.5,-174.9]')
;

-- slave keys
INSERT INTO `dd_keys` (name, property, exempt_doors, exempt_zones) VALUES
	('Standard', 'Mission Row PS', '[7]', '[]'),
	('Standard', 'Simeon''s Dealership', '[5]', '[]')
;

DELIMITER $$
CREATE TRIGGER dd_doors_trigger
BEFORE INSERT ON dd_doors
FOR EACH ROW BEGIN
   SET NEW.`designation` = IFNULL((SELECT MAX(designation) + 1 FROM dd_doors WHERE property = NEW.property), 1);
END $$
DELIMITER ;

INSERT INTO `dd_doors` (property, name, hash, object, text, locked, distance, axis) VALUES
	('Bolingbroke', 'Front Gate A', 741314661, '[1844.998,2604.81,44.638]', '[1844.998,2608.5,48.0]', 1, 12, NULL),
	('Bolingbroke', 'Front Gate B', 741314661, '[1818.542,2604.812,44.611]', '[1818.542,2608.4,48.0]', 1, 12, NULL),
	('MSandy Shores SS', 'Entrance', -1765048490, '[1855.105,3683.516,34.266]', '[1855.105,3683.516,35.0]', 0, 2.5, NULL),
	('Paleto Bay SO', 'Entrance A', -1501157055, '[-443.14,6015.685,31.716]', '[-443.14,6015.685,32.0]', 0, 2.5, NULL),
	('Paleto Bay SO', 'Entrance B', -1501157055, '[-443.951,6016.622,31.716]', '[-443.951,6016.622,32.0]', 0, 2.5, NULL),
	('Simeon''s Dealership', 'Car Park Entrance A', 2059227086, '[-39.13366,-1108.218,26.7198]', '[-38.6830275,-1108.38175,27.4698]', 0, 2.5, NULL),
	('Simeon''s Dealership', 'Car Park Entrance B', 1417577297, '[-37.33113,-1108.873,26.7198]', '[-37.7817625,-1108.70925,27.4698]', 0, 2.5, NULL),
	('Simeon''s Dealership', 'Street Entrance A', 2059227086, '[-59.89302,-1092.952,26.88362]', '[-60.05622,-1093.40125,27.634895]', 0, 2.5, NULL),
	('Simeon''s Dealership', 'Street Entrance B', 1417577297, '[-60.54582,-1094.749,26.88872]', '[-60.38262,-1094.29975,27.637445]', 0, 2.5, NULL),
	('Simeon''s Dealership', 'Office A', -2051651622, '[-33.80989,-1107.579,26.57225]', '[-34.070685,-1108.2955,27.32225]', 1, 2.5, NULL),
	('Simeon''s Dealership', 'Office B', -2051651622, '[-31.72353,-1101.847,26.57225]', '[-31.984325,-1102.5635,27.32225]', 1, 2.5, NULL),
	('Route 68 LS Customs', 'Spray', 1544229216, '[1182.645,2641.904,38.05187]', '[1182.645,2641.904,38.05187]', 1, 5, NULL),
	('Route 68 LS Customs', 'Garage A', -822900180, '[1174.654,2645.232,38.67961]', '[1174.654,2645.232,38.67961]', 1, 5, NULL),
	('Route 68 LS Customs', 'Garage B', -822900180, '[1182.305,2645.243,38.68462]', '[1182.305,2645.243,38.68462]', 1, 5, NULL),
	('Route 68 LS Customs', 'Office', 1335311341, '[1187.202,2644.95,38.55176]', '[1187.902,2644.95,39.05176]', 1, 2.5, NULL),
	('Paleto Bay LS Customs', 'Spray', 1544229216, '[106.2797,6620.02,32.08532]', '[106.2797,6620.02,32.08532]', 1, 5, NULL),
	('Paleto Bay LS Customs', 'Garage A', -822900180, '[114.3209,6623.226,32.71817]', '[114.3209,6623.226,32.71817]', 1, 5, NULL),
	('Paleto Bay LS Customs', 'Garage B', -822900180, '[108.8573,6617.87,32.7166]', '[108.8573,6617.87,32.7166]', 1, 5, NULL),
	('Paleto Bay LS Customs', 'Office', 1335311341, '[105.1518,6614.655,32.58521]', '[104.5518,6614.155,32.78521]', 1, 2.5, NULL),
	('Benny''s Customs', 'Entrance', -427498890, '[-205.6828,-1310.683,30.29771]', '[-205.6828,-1310.683,31.79771]', 1, 10, 'z'),
	('La Mesa LS Customs', 'Garage', 270330101, '[723.1056,-1088.831,23.27616]', '[723.1056,-1088.831,23.27616]', 1, 10, NULL),
	('La Mesa LS Customs', 'Spray', 1544229216, '[735.6767,-1075.977,22.50473]', '[735.6767,-1075.977,22.50473]', 1, 5, NULL),
	('LSIA LS Customs', 'Garage', -550347177, '[-1145.89,-1991.137,14.22722]', '[-1145.89,-1991.137,14.22722]', 1, 10, NULL),
	('LSIA LS Customs', 'Spray', 1544229216, '[-1164.55,-2010.75,13.50284]', '[-1164.55,-2010.75,13.50284]', 1, 5, NULL),
	('Burton LS Customs', 'Garage', -550347177, '[-356.1003,-134.7679,40.05737]', '[-356.1003,-134.7679,40.05737]', 1, 10, NULL),
	('Burton LS Customs', 'Spray', 1544229216, '[-330.4327,-143.3929,39.30275]', '[-330.4327,-143.3929,39.30275]', 1, 5, NULL)
;

DELIMITER $$
CREATE TRIGGER dd_zones_trigger
BEFORE INSERT ON dd_zones
FOR EACH ROW BEGIN
   SET NEW.`designation` = IFNULL((SELECT MAX(designation) + 1 FROM dd_zones WHERE property = NEW.property), 1);
END $$
DELIMITER ;

INSERT INTO `dd_zones` (property, name, type, zone, spawn, public) VALUES
	('Pillbox Hill Parking', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[215.800,-810.057,29.727],"r":2}', '[[233.3,-805.4,29.8,70.0],[237.8,-810.2,29.6,250.0],[242.3,-797.1,29.9,70.0],[238.9,-790.2,29.9,250.0],[248.1,-782.1,29.9,250.0],[227.7,-771.5,30.1,70.0],[226.4,-794.4,30.0,70.0],[216.0,-801.8,30.1,250.0],[207.9,-796.0,30.3,70.0],[212.9,-783.6,30.2,70.0]]', 1),
	('Vinewood Bowl Parking', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[664.544,629.024,127.911],"r":2}', '[[657.646,630.719,127.911,340.0]]', 1),
	('Clucking Bell', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[85.357,6391.778,30.376],"r":2}', '[[70.421,6390.602,30.11,160.0]]', 1),
	('Sandy Shores Parking', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[1694.571,3610.924,34.319],"r":2}', '[[1713.492,3598.938,34.338,160.0]]', 1),
	('Pacific Bluffs Parking', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[-2982.561,327.506,13.935],"r":2}', '[[-2977.238,337.777,13.768,160.0]]', 1),
	('Harmony Parking', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[1136.377,2666.630,37.013],"r":2}', '[[1120.981,2668.868,37.048,180.0]]', 1),
	('Grove Street Parking', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[-69.514,-1822.947,25.941],"r":2}', '[[-67.720,-1835.778,25.883,225.0]]', 1),
	('Tequila La La', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[-575.663,318.413,83.614],"r":2}', '[[-569.475,323.535,83.474,20.0]]', 0),
	('Pacific Standard', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[363.483,296.836,102.500],"r":2}', '[[378.006,288.130,102.166,60.0]]', 1),
	('Mirror Park Parking', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[1033.922,-767.106,57.003],"r":2}', '[[1040.683,-778.181,57.022,0.0]]', 1),
	('Yellow Jack Inn', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[2008.058,3051.514,46.156],"r":2}', '[[2009.074,3061.370,46.051,330.0]]', 0),
	('Merryweather Dock', 'Dock A', 'garage', '{"vehicle":"boat","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 0),
	('Del Perro Pier', 'Boss', 'boss', '{"type":"poly","vecs":[[-1821.141,-1205.201],[-1824.382,-1203.345],[-1818.657,-1193.249],[-1815.291,-1195.135]],"min":19.0,"max":20.0}', '[]', 0),
	('Del Perro Pier', 'Dock A', 'garage', '{"vehicle":"boat","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 1),
	('Puerto Del Sol Yacht Club', 'Dock A', 'garage', '{"vehicle":"boat","type":"circle","vec":[-742.470,-1332.470,0.59],"r":2}', '[[-736.470,-1342.470,0.0,230.0]]', 1),
	('Puerto Del Sol Yacht Club', 'Pad A', 'garage', '{"vehicle":"heli","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 1),
	('Puerto Del Sol Yacht Club', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 0),
	('LSIA', 'Hangar A', 'garage', '{"vehicle":"plane","type":"circle","vec":[-1280.115,-3378.164,12.940],"r":2}', '[[-1285.115,-3382.164,12.940,160.0]]', 1),
	('Devin Weston Hangar', 'Hangar A', 'garage', '{"vehicle":"plane","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 0),
	('Grapeseed Airfield', 'Hangar A', 'garage', '{"vehicle":"plane","type":"circle","vec":[2132.0,4787.0,40.0],"r":2}', '[[2125.0,4805.0,40.18,120.0]]', 1),
	('Sandy Shores Airfield', 'Hangar A', 'garage', '{"vehicle":"plane","type":"circle","vec":[2132.0,4787.0,40.0],"r":2}', '[[2125.0,4805.0,40.18,120.0]]', 1)
;
