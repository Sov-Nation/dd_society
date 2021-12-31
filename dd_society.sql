DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
	`name` VARCHAR(100) NOT NULL,
	`label` VARCHAR(100) NOT NULL,
	`colour` TINYINT NOT NULL DEFAULT 0,
	`account` INT NOT NULL DEFAULT 0,
	`employees` TEXT NOT NULL DEFAULT '[]',

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
	('lspd', 'captain', 'Captain', 150),
	('lspd', 'chief', 'Chief', 0),
	('sasp', 'grunt', 'Grunt', 25),
	('sasp', 'officer', 'Officer', 50),
	('sasp', 'lieutenant', 'Lieutenant', 75),
	('sasp', 'captain', 'Captain', 150),
	('sasp', 'chief', 'Chief', 0),
	('pbpd', 'grunt', 'Grunt', 25),
	('pbpd', 'officer', 'Officer', 50),
	('pbpd', 'lieutenant', 'Lieutenant', 75),
	('pbpd', 'captain', 'Captain', 150),
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

DROP TABLE IF EXISTS `dd_moneywash`;
CREATE TABLE `dd_moneywash` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`property` VARCHAR(100) NOT NULL,
	`amount` INT NOT NULL,
	`timestamp` INT NOT NULL,

	PRIMARY KEY (`id`)
);
