ALTER TABLE `users`
	ADD COLUMN `dd_keys` TEXT DEFAULT '[]'
;

DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
	`name` VARCHAR(100) NOT NULL,
	`label` VARCHAR(100) NOT NULL,
	`colour` TINYINT NOT NULL DEFAULT 0,
	`account` INT NOT NULL DEFAULT 0,

	PRIMARY KEY (`name`)
);

INSERT INTO `jobs` (name, label, colour) VALUES
	('unemployed', 'Unemployed', 0),
	('doka&doka', 'Doka & Doka', 5),
	('bcso', 'BCSO', 1),
	('lspd', 'LSPD', 29),
	('sasp', 'SASP', 7),
	('pbpd', 'PBPD', 3),
	('health', 'BCHD', 25),
	('security', 'Peregrine Security', 2),
	('zancudo', 'Fort Zancudo', 17),
	('simeon', 'Simeon''s Vehicles', 76)
;

DROP TABLE IF EXISTS `job_grades`;
CREATE TABLE `job_grades` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`job_name` VARCHAR(100) NOT NULL,
	`grade` TINYINT NOT NULL,
	`name` VARCHAR(100) NOT NULL,
	`label` VARCHAR(100) NOT NULL,
	`salary` INT NOT NULL DEFAULT 0,

	PRIMARY KEY (`id`)
);

DELIMITER $$
CREATE TRIGGER job_grades_trigger
BEFORE INSERT ON job_grades
FOR EACH ROW BEGIN
   SET NEW.`grade` = IFNULL((SELECT MAX(grade) + 1 FROM job_grades WHERE job_name = NEW.job_name), 0);
END $$
DELIMITER ;

INSERT INTO `job_grades` (job_name, name, label, salary) VALUES
	('unemployed', 'unemployed', 'Unemployed', 10),
	('doka&doka', 'junior', 'Junior', 25),
	('doka&doka', 'officer', 'Officer', 50),
	('doka&doka', 'senior', 'Senior', 75),
	('doka&doka', 'manager', 'Manager', 150),
	('doka&doka', 'ceo', 'CEO', 0),
	('bcso', 'grunt', 'Grunt', 25),
	('bcso', 'deputy', 'Deputy', 50),
	('bcso', 'lieutenant', 'Lieutenant', 75),
	('bcso', 'underboss', 'Under-Sheriff', 150),
	('bcso', 'sheriff', 'Sheriff', 0),
	('lspd', 'grunt', 'Grunt', 25),
	('lspd', 'officer', 'Officer', 50),
	('lspd', 'lieutenant', 'Lieutenant', 75),
	('lspd', 'capitan', 'Capitan', 150),
	('lspd', 'chief', 'Chief', 0),
	('sasp', 'grunt', 'Grunt', 25),
	('sasp', 'officer', 'Officer', 50),
	('sasp', 'lieutenant', 'Lieutenant', 75),
	('sasp', 'capitan', 'Capitan', 150),
	('sasp', 'chief', 'Chief', 0),
	('pbpd', 'grunt', 'Grunt', 25),
	('pbpd', 'officer', 'Officer', 50),
	('pbpd', 'lieutenant', 'Lieutenant', 75),
	('pbpd', 'capitan', 'Capitan', 150),
	('pbpd', 'chief', 'Chief', 0),
	('health', 'grunt', 'Grunt', 25),
	('health', 'officer', 'Officer', 50),
	('health', 'lieutenant', 'Lieutenant', 75),
	('health', 'underboss', 'Under-Boss', 150),
	('health', 'boss', 'Boss', 0),
	('security', 'grunt', 'Grunt', 25),
	('security', 'officer', 'Officer', 50),
	('security', 'lieutenant', 'Lieutenant', 75),
	('security', 'underboss', 'Under-Boss', 150),
	('security', 'boss', 'Boss', 0),
	('zancudo', 'grunt', 'Grunt', 25),
	('zancudo', 'officer', 'Officer', 50),
	('zancudo', 'lieutenant', 'Lieutenant', 75),
	('zancudo', 'underboss', 'Under-Boss', 150),
	('zancudo', 'boss', 'Boss', 0),
	('simeon', 'grunt', 'Grunt', 25),
	('simeon', 'officer', 'Officer', 50),
	('simeon', 'lieutenant', 'Lieutenant', 75),
	('simeon', 'underboss', 'Under-Boss', 150),
	('simeon', 'boss', 'Boss', 0)
;

DROP TABLE IF EXISTS `dd_bills`;
CREATE TABLE `dd_bills` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`player` VARCHAR(100) NOT NULL,
	`target` VARCHAR(100) NOT NULL,
	`amount` INT NOT NULL,
	`details` TEXT NOT NULL,
	`timestamp` INT NOT NULL,

	PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `dd_properties`;
CREATE TABLE `dd_properties` (
	`id` VARCHAR(100) NOT NULL,
	`owner` VARCHAR(100) NOT NULL DEFAULT 'Doka & Doka',
	`type` VARCHAR(100) NULL DEFAULT 'house',
	`blip` VARCHAR(100) NOT NULL,

	PRIMARY KEY (`id`)
);

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
	('Mission Row PS', 'LSPD', 'law', '[425.130,-979.558]'),
	('Sandy Shores SS', 'BCSO', 'law', '[1854.379,3687.33]'),
	('Paleto Bay SO', 'PBPD', 'law', '[-447.033,6014.55]'),
	('Cental Los Santos MC', 'BCHD', 'hospital', '[296.214,-1446.055]'),
	('Sandy Shores MC', 'BCHD', 'hospital', '[1827.779,3693.37]'),
	('Simeon''s Dealership', 'Simeon''s Vehicles', 'dealer', '[-40.709,-1099.769]'),
	('Fort Zancudo MilSurp Vehicles', 'Fort Zancudo', 'dealer', '[-1831.178,2976.809]'),
	('Pacific Standard', 'Doka & Doka', 'bank', '[249.234,217.942]'),
	('Merryweather Dock', 'Peregrine Security', 'security', '[484.2,-3112.8]'),
	('Fort Zancudo', 'Fort Zancudo', 'military', '[-2345.2,3267.3]')
;

-- other properties
INSERT INTO `dd_properties` (id, type, blip) VALUES
	('Mirror Park Parking', 'garage', '[1032.0,-773.4]'),
	('Pillbox Hill Parking', 'garage', '[226.4,-789.0]'),
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

DROP TABLE IF EXISTS `dd_keys`;
CREATE TABLE `dd_keys` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(100) NOT NULL,
	`property` VARCHAR(100) NOT NULL,
	`designation` SMALLINT NOT NULL,
	`exempt_doors` TEXT DEFAULT '[]',
	`exempt_zones` TEXT DEFAULT '[]',

	PRIMARY KEY (`id`)
);

DELIMITER $$
CREATE TRIGGER dd_keys_trigger
BEFORE INSERT ON dd_keys
FOR EACH ROW BEGIN
   SET NEW.`designation` = IFNULL((SELECT MAX(designation) + 1 FROM dd_keys WHERE property = NEW.property), 1);
END $$
DELIMITER ;

-- slave keys
INSERT INTO `dd_keys` (name, property, exempt_doors, exempt_zones) VALUES
	('Standard', 'Mission Row PS', '[7]', '[]'),
	('Standard', 'Simeon''s Dealership', '[5]', '[]')
;

DROP TABLE IF EXISTS `dd_doors`;
CREATE TABLE `dd_doors` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`property` VARCHAR(100) NOT NULL,
	`designation` SMALLINT NOT NULL,
	`name` VARCHAR(100) NULL DEFAULT NULL,
	`hash` INT(11) NOT NULL,
	`object` VARCHAR(100) NOT NULL,
	`text` VARCHAR(100) NOT NULL,
	`locked` INT(1) DEFAULT 1,
	`distance` FLOAT NOT NULL,
	`axis` VARCHAR(1) NULL DEFAULT NULL,

	PRIMARY KEY (`id`)
);

DELIMITER $$
CREATE TRIGGER dd_doors_trigger
BEFORE INSERT ON dd_doors
FOR EACH ROW BEGIN
   SET NEW.`designation` = IFNULL((SELECT MAX(designation) + 1 FROM dd_doors WHERE property = NEW.property), 1);
END $$
DELIMITER ;

INSERT INTO `dd_doors` (property, name, hash, object, text, locked, distance, axis) VALUES
	('Mission Row PS', 'Entrance A', -1215222675, '[434.747,-980.618,30.839]', '[434.747,-981.5,31.5]', 1, 2.5, NULL),
	('Mission Row PS', 'Entrance B', 320433149, '[434.747,-983.215,30.839]', '[434.747,-982.5,31.5]', 1, 2.5, NULL),
	('Mission Row PS', 'Reception to Corridor', 1557126584, '[449.698,-986.469,30.689]', '[450.104,-986.388,31.739]', 1, 2.5, NULL),
	('Mission Row PS', 'Rooftop', -340230128, '[464.361,-984.678,43.834]', '[464.361,-984.05,44.834]', 1, 2.5, NULL),
	('Mission Row PS', 'Rooftop Stairwell', 749848321, '[461.286,-985.32,30.839]', '[461.5,-986.0,31.5]', 1, 2.5, NULL),
	('Mission Row PS', 'Armory', 749848321, '[452.618,-982.702,30.689]', '[453.079,-982.6,31.739]', 1, 2.5, NULL),
	('Mission Row PS', 'Captain''s Office', -1320876379, '[447.238,-980.63,30.689]', '[447.2,-980.01,31.739]', 1, 2.5, NULL),
	('Mission Row PS', 'Main Stairwell A', 185711165, '[443.97,-989.033,30.6896]', '[444.02,-989.445,31.739]', 1, 4, NULL),
	('Mission Row PS', 'Main Stairwell B', 185711165, '[445.37,-988.705,30.6896]', '[445.35,-989.445,31.739]', 1, 4, NULL),
	('Mission Row PS', 'Main Cell Door', 631614199, '[463.815,-992.686,24.9149]', '[463.3,-992.686,25.1]', 1, 2.5, NULL),
	('Mission Row PS', 'Cell A', 631614199, '[462.381,-993.651,24.914]', '[461.806,-993.308,25.064]', 1, 2.5, NULL),
	('Mission Row PS', 'Cell B', 631614199, '[462.331,-998.152,24.914]', '[461.806,-998.8,25.064]', 1, 2.5, NULL),
	('Mission Row PS', 'Cell C', 631614199, '[462.704,-1001.92,24.9149]', '[461.806,-1002.45,25.064]', 1, 2.5, NULL),
	('Mission Row PS', 'Cells to Rear', -1033001619, '[463.478,-1003.538,25.005]', '[464.0,-1003.5,25.5]', 1, 2.5, NULL),
	('Mission Row PS', 'Rear A', -2023754432, '[467.371,-1014.452,26.536]', '[468.09,-1014.452,27.1362]', 1, 3, NULL),
	('Mission Row PS', 'Rear B', -2023754432, '[469.967,-1014.452,26.536]', '[469.35,-1014.452,27.136]', 1, 3, NULL),
	('Mission Row PS', 'Rear Gate', -1603817716, '[488.894,-1017.21,27.146]', '[488.894,-1020.21,30.0]', 1, 14, NULL),
	('Mission Row PS', 'Locker Room', -2023754432, '[452.6248,-987.3626,30.8393]', '[452.0248,-987.4626,31.3393]', 1, 2.5, NULL),
	('Mission Row PS', 'Briefing Room A', -131296141, '[443.0298,-994.5412,30.8393]', '[443.0298,-994.0412,31.4393]', 1, 4, NULL),
	('Mission Row PS', 'Briefing Room B', -131296141, '[443.0298,-991.941,30.8393]', '[443.0298,-992.441,31.4393]', 1, 4, NULL),
	('Mission Row PS', 'Garage A', -190780785, '[459.5504,-1014.646,29.10957]', '[459.5504,-1014.646,29.10957]', 1, 10, NULL),
	('Mission Row PS', 'Garage B', -190780785, '[459.5504,-1019.699,29.08874]', '[459.5504,-1019.699,29.08874]', 1, 10, NULL),
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

DROP TABLE IF EXISTS `dd_zones`;
CREATE TABLE `dd_zones` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`property` VARCHAR(100) NOT NULL,
	`designation` SMALLINT NOT NULL,
	`name` VARCHAR(100) NOT NULL,
	`type` VARCHAR(100) NOT NULL,
	`zone` TEXT NOT NULL,
	`spawn` TEXT NOT NULL DEFAULT '[]',
	`public` INT(1) DEFAULT 0,

	PRIMARY KEY (`id`)
);

DELIMITER $$
CREATE TRIGGER dd_zones_trigger
BEFORE INSERT ON dd_zones
FOR EACH ROW BEGIN
   SET NEW.`designation` = IFNULL((SELECT MAX(designation) + 1 FROM dd_zones WHERE property = NEW.property), 1);
END $$
DELIMITER ;

INSERT INTO `dd_zones` (property, name, type, zone, spawn, public) VALUES
	('Mission Row PS', 'Garage A', 'garage', '{"vehicle":"car","type":"poly","vecs":[[442.008,-1012.853],[455.694,-1011.188],[456.348,-1006.205],[459.134,-1006.771],[459.710,-1012.474],[466.554,-1012.688],[466.564,-1022.206],[459.475,-1022.490],[459.410,-1027.277],[442.151,-1029.409]],"min":27,"max":30}', '[[463.27,-1019.639,27.106,90.0],[462.406,-1014.725,27.061,90.0]]', 0),
	('Mission Row PS', 'Garage B', 'garage', '{"vehicle":"car","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 0),
	('Mission Row PS', 'Pad A', 'garage', '{"vehicle":"heli","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 0),
	('Mission Row PS', 'Boss', 'boss', '{"type":"poly","vecs":[[445.782,-972.182],[453.492,-972.151],[453.610,-974.839],[445.651,-973.979]],"min":29,"max":31}', '[]', 0),
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
	('Del Perro Beach Dock', 'Dock A', 'garage', '{"vehicle":"boat","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 1),
	('Puerto Del Sol Yacht Club', 'Dock A', 'garage', '{"vehicle":"boat","type":"circle","vec":[-742.470,-1332.470,0.59],"r":2}', '[[-736.470,-1342.470,0.0,230.0]]', 1),
	('Puerto Del Sol Yacht Club', 'Pad A', 'garage', '{"vehicle":"heli","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 1),
	('Puerto Del Sol Yacht Club', 'Garage A', 'garage', '{"vehicle":"car","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 0),
	('LSIA', 'Hangar A', 'garage', '{"vehicle":"plane","type":"circle","vec":[-1280.115,-3378.164,12.940],"r":2}', '[[-1285.115,-3382.164,12.940,160.0]]', 1),
	('Devin Weston Hangar', 'Hangar A', 'garage', '{"vehicle":"plane","type":"circle","vec":[0.0,0.0,0.0],"r":2}', '[[0.0,0.0,0.0,0.0]]', 0),
	('Grapeseed Airfield', 'Hangar A', 'garage', '{"vehicle":"plane","type":"circle","vec":[2132.0,4787.0,40.0],"r":2}', '[[2125.0,4805.0,40.18,120.0]]', 1),
	('Sandy Shores Airfield', 'Hangar A', 'garage', '{"vehicle":"plane","type":"circle","vec":[2132.0,4787.0,40.0],"r":2}', '[[2125.0,4805.0,40.18,120.0]]', 1)
;
