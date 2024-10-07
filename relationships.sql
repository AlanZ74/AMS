 airline = (airlineID, revenue)

airplane = (airlineID[fk3], tail_num, locID[fk2], seat_cap, speed)
fk2: locID ->location.locID
fk3: airlineID -> airline.airlineID

airport = (airportID, locID[fk6], airportName, airportCity, airportState, airportCountry)
fk6: locID ->location.locID

jet = (airlineID, tail_num[fk4], num_engines)
fk4: airlineID, tail_num -> airplane.airlineID, airplane.tail_num

prop = (airlineID, tail_num[fk5], num_prop, skids)
fk5: airlineID, tail_num = airplane.airlineID, airplane.tail_num

leg = (legID, distance, arrives[fk7], departs[fk8])
fk7: arrives -> airport.airportID
fk8: departs -> airport.airportID

route = (routeID)

flight = (flightID, cost, follow[fk9])
fk9: follow -> route.routeID

passenger = (personID[fk10], miles, funds)
fk10: personID -> person.personID

vacation = (personID[fk11], sequence, destination)
fk11: personID -> person.personID

pilot = (personID[fk12], taxID, experience, commands[fk13])
fk12: personID -> person.personID
fk13:  commands -> flight.flightID

pilot_licenses = (license_type, taxID, personID[fk14])
fk14: taxID, personID -> pilot.taxID, pilot.personID

person = (personID, firstName, lastName, occupies[fk1])
fk1: occupies -> location.locID

location = (locID)

*NOTE: This relationship is called “paths” in the SQL statements because contains is a keyword in SQL*
contains = (legID[fk15], routeID[fk18], sequence)
fk15: legID -> leg.legID
fk18: routeID -> route.routeID

supports = (flightID[fk17], airlineID, tail_num[fk16], progress, flightstatus, next_time)
fk16: airlineID, tail_num -> airplace.airlineID, airplane.tail_num
fk17: flightID -> flight.flightID
unhandled constraints: 
ensuring each airport’s address is valid
ensuring nonnegative values for airline revenue, airplane speed, airplane # of seats, passenger miles, number of propellers, number of engines, leg distance, pilot experience
ensuring valid next_time, status
ensuring a plane is only in one of: prop, jet
ensuring pilot licenses are not repeated for each pilot
ensuring the right number of pilots per plane upon takeoff
ensuring at each route has at least one leg
ensuring each person is classified as either a pilot or a passenger
ensuring each pilot only commands one flight
ensuring that a pair of (arrival, departure) airports has a valid route 
ensuring all IDs’ format (i.e. person_#, ###-###-#### for taxID, etc)




-- CS4400: Introduction to Database Systems: Monday, September 11, 2023
-- Simple Airline Management System Course Project Database TEMPLATE (v0)
/* This is a standard preamble for most of our scripts. The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_tracking';
drop database if exists flight_tracking;
create database if not exists flight_tracking;
use flight_tracking;
-- Please enter your team number and names here: Team 62 - Patrick Weng, Alan Zheng, Melissa Leng, Yujin Hwang
-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and
foreign key
declarations, and data INSERTion statements here. You may sequence them in any
order that
works for you. When executed, your statements must create a functional database
that contains
all of the data, and supports as many of the constraints as reasonably possible. */

drop table if exists location;
create table location (
	locID char(50) not null,
    primary key (locID)
);

INSERT INTO location(locID) VALUES
('port_1'),
('port_2'),
('port_3'),
('port_10'),
('port_12'),
('port_14'),
('port_15'),
('port_16'),
('port_17'),
('port_20'),
('port_4'),
('port_11'),
('port_23'),
('port_7'),
('port_6'),
('port_13'),
('port_21'),
('port_18'),
('port_22'),
('plane_1'),
('plane_5'),
('plane_8'),
('plane_13'),
('plane_20'),
('plane_6'),
('plane_18'),
('plane_7');

drop table if exists person;
create table person (
	personID char(50) not null,
	firstName char(100) not null,
	lastName char(100),
	occupies char(50) not null,
	constraint fk1 foreign key (occupies) references location (locID),
	primary key (personID)
);

INSERT INTO person VALUES
('p1', 'Jeanne', 'Nelson', 'port_1'),
('p10', 'Lawrence', 'Morgan', 'port_3'),
('p11', 'Sandra', 'Cruz', 'port_3'),
('p12', 'Dan', 'Ball', 'port_3'),
('p13', 'Bryant', 'Figueroa', 'port_3'),
('p14', 'Dana', 'Perry', 'port_3'),
('p15', 'Matt', 'Hunt', 'port_10'),
('p16', 'Edna', 'Brown', 'port_10'),
('p17', 'Ruby', 'Burgess', 'port_10'),
('p18', 'Esther', 'Pittman', 'port_10'),
('p19', 'Doug', 'Fowler', 'port_17'),
('p2', 'Roxanne', 'Byrd', 'port_1'),
('p20', 'Thomas', 'Olson', 'port_17'),
('p21', 'Mona', 'Harrison', 'plane_1'),
('p22', 'Arlene', 'Massey', 'plane_1'),
('p23', 'Judith', 'Patrick', 'plane_1'),
('p24', 'Reginald', 'Rhodes', 'plane_5'),
('p25', 'Vincent', 'Garcia', 'plane_5'),
('p26', 'Cheryl', 'Moore', 'plane_5'),
('p27', 'Michael', 'Rivera', 'plane_8'),
('p28', 'Luther', 'Matthews', 'plane_8'),
('p29', 'Moses', 'Parks', 'plane_13'),
('p3', 'Tanya', 'Nguyen', 'port_1'),
('p30', 'Ora', 'Steele', 'plane_13'),
('p31', 'Antonio', 'Flores', 'plane_13'),
('p32', 'Glenn', 'Ross', 'plane_13'),
('p33', 'Irma', 'Thomas', 'plane_20'),
('p34', 'Ann', 'Maldonado', 'plane_20'),
('p35', 'Jeffrey', 'Cruz', 'port_12'),
('p36', 'Sonya', 'Price', 'port_12'),
('p37', 'Tracy', 'Hale', 'port_12'),
('p38', 'Albert', 'Simmons', 'port_14'),
('p39', 'Karen', 'Terry', 'port_15'),
('p4', 'Kendra', 'Jacobs', 'port_1'),
('p40', 'Glen', 'Kelley', 'port_20'),
('p41', 'Brooke', 'Little', 'port_3'),
('p42', 'Daryl', 'Nguyen', 'port_4'),
('p43', 'Judy', 'Willis', 'port_14'),
('p44', 'Marco', 'Klein', 'port_15'),
('p45', 'Angelica', 'Hampton', 'port_16'),
('p5', 'Jeff', 'Burton', 'port_1'),
('p6', 'Randal', 'Parks', 'port_1'),
('p7', 'Sonya', 'Owens', 'port_2'),
('p8', 'Bennie', 'Palmer', 'port_2'),
('p9', 'Marlene', 'Warner', 'port_3');

drop table if exists airline;
create table airline (
	airlineID char(50) not null,
	revenue integer not null,
	primary key(airlineID)
);

INSERT INTO airline VALUES 
('Delta', 53000),
('United', 48000),
('British Airways', 24000),
('Lufthansa', 35000),
('Air_France', 29000),
('KLM', 29000),
('Ryanair', 10000),
('Japan Airlines', 9000),
('China Southern Airlines', 14000),
('Korean Air Lines', 10000),
('American', 52000);

drop table if exists airplane;
create table airplane (
	locID char(50),
	tail_num char(50) not null,
	seat_cap integer not null,
	speed integer not null,
	airlineID char(50) not null,
	constraint fk2 foreign key (locID) references location (locID),
	constraint fk3 foreign key (airlineID) references airline (airlineID),
	primary key(airlineID, tail_num),
    unique key (locID)
);

INSERT INTO airplane VALUES 
('plane_1','n106js',4,800,'Delta'),
(NULL,'n110jn',5,800,'Delta'),
(NULL,'n127js',4,600,'Delta'),
(NULL,'n330ss',4,800,'United'),
('plane_5','n380sd',5,400,'United'),
('plane_6','n616lt',7,600,'British Airways'),
('plane_7','n517ly',4,600,'British Airways'),
('plane_8','n620la',4,800,'Lufthansa'),
(NULL,'n401fj',4,300,'Lufthansa'),
(NULL,'n653fk',6,600,'Lufthansa'),
(NULL,'n118fm',4,400,'Air_France'),
(NULL,'n815pw',3,400,'Air_France'),
('plane_13','n161fk',4,600,'KLM'),
(NULL,'n337as',5,400,'KLM'),
(NULL,'n256ap',4,300,'KLM'),
(NULL,'n156sq',8,600,'Ryanair'),
(NULL,'n451fi',5,600,'Ryanair'),
('plane_18','n341eb',4,400,'Ryanair'),
(NULL,'n353kz',4,400,'Ryanair'),
('plane_20','n305fv',6,400,'Japan Airlines'),
(NULL,'n443wu',4,800,'Japan Airlines'),
(NULL,'n454gq',3,400,'China Southern Airlines'),
(NULL,'n249yk',4,400,'China Southern Airlines'),
(NULL,'n180co',5,600,'Korean Air Lines'),
(NULL,'n448cs',4,400,'American'),
(NULL,'n225sb',8,800,'American'),
(NULL,'n553qn',5,800,'American');

drop table if exists jet;
create table jet (
tail_num char(50) not null,
numengines integer not null,
airlineID char(50) not null,
constraint fk4 foreign key (airlineID, tail_num) references airplane (airlineID, tail_num),
primary key (airlineID , tail_num)
);

INSERT INTO jet VALUES
('n106js',2,'Delta'),
('n110jn',2,'Delta'),
('n127js',4,'Delta'),
('n330ss',2,'United'),
('n380sd',2,'United'),
('n616lt',2,'British Airways'),
('n517ly',2,'British Airways'),
('n620la',4,'Lufthansa'),
('n653fk',2,'Lufthansa'),
('n815pw',2,'Air_France'),
('n161fk',4,'KLM'),
('n337as',2,'KLM'),
('n156sq',2,'Ryanair'),
('n451fi',4,'Ryanair'),
('n305fv',2,'Japan Airlines'),
('n443wu',4,'Japan Airlines'),
('n180co',2,'Korean Air Lines'),
('n225sb',2,'American'),
('n553qn',2,'American');

drop table if exists prop;
create table prop (
	tail_num char(50) not null,
	numprop integer not null,
	skids boolean not null,
	airlineID char(50) not null,
	constraint fk5 foreign key (airlineID, tail_num) references airplane (airlineID, tail_num),
	primary key (airlineID, tail_num)
);

INSERT INTO prop VALUES
('n118fm', 2, 0, 'Air_France'),
('n256ap', 2, 0, 'KLM'),
('n341eb', 2, 1, 'Ryanair'),
('n353kz', 2, 1, 'Ryanair'),
('n249yk', 2, 0, 'China Southern Airlines'),
('n448cs', 2, 1, 'American');

drop table if exists airport;
create table airport (
	locID char(50),
	airportID char(50) not null,
	airportName char(100) not null,
	airportCity char(100) not null,
	airportState char(100) not null,
	airportCountry char(100) not null,
	constraint fk6 foreign key (locID) references location (locID),
	primary key(airportID),
    unique key(airportName),
    unique key (locID)
);

INSERT INTO airport VALUES
('port_1','ATL','Atlanta Hartsfield_Jackson International','Atlanta','Georgia','USA'),
('port_2','DXB','Dubai International','Dubai','Al Garhoud','UAE'),
('port_3','HND','Tokyo International Haneda','Ota City','Tokyo','JPN'),
('port_4','LHR','London Heathrow','London','England','GBR'),
(null,'IST','Istanbul International','Arnavutkoy','Istanbul ','TUR'),
('port_6','DFW','Dallas_Fort Worth International','Dallas','Texas','USA'),
('port_7','CAN','Guangzhou International','Guangzhou','Guangdong','CHN'),
(null,'DEN','Denver International','Denver','Colorado','USA'),
(null,'LAX','Los Angeles International','Los Angeles','California','USA'),
('port_10','ORD','O_Hare International','Chicago','Illinois','USA'),
('port_11','AMS','Amsterdam Schipol International','Amsterdam','Haarlemmermeer','NLD'),
('port_12','CDG','Paris Charles de Gaulle','Roissy_en_France','Paris','FRA'),
('port_13','FRA','Frankfurt International','Frankfurt','Frankfurt_Rhine_Main','DEU'),
('port_14','MAD','Madrid Adolfo Suarez_Barajas','Madrid','Barajas','ESP'),
('port_15','BCN','Barcelona International','Barcelona','Catalonia','ESP'),
('port_16','FCO','Rome Fiumicino','Fiumicino','Lazio','ITA'),
('port_17','LGW','London Gatwick','London','England','GBR'),
('port_18','MUC','Munich International','Munich','Bavaria','DEU'),
(null,'MDW','Chicago Midway International','Chicago','Illinois','USA'),
('port_20','IAH','George Bush Intercontinental','Houston','Texas','USA'),
('port_21','HOU','William P_Hobby International','Houston','Texas','USA'),
('port_22','NRT','Narita International','Narita','Chiba','JPN'),
('port_23','BER','Berlin Brandenburg Willy Brandt International','Berlin','Schonefeld','DEU');

drop table if exists leg;
create table leg (
	legID char(50) not null,
	distance integer not null,
	arrives char(50) not null,
	departs char(50) not null,
	constraint fk7 foreign key (arrives) references airport (airportID),
	constraint fk8 foreign key (departs) references airport (airportID),
	primary key (legID)
);

INSERT INTO leg VALUES
('leg_1',400,'AMS','BER'),
('leg_2',3900,'ATL','AMS'),
('leg_3',3700,'ATL','LHR'),
('leg_4',600,'ATL','ORD'),
('leg_5',500,'BCN','CDG'),
('leg_6',300,'BCN','MAD'),
('leg_7',4700,'BER','CAN'),
('leg_8',600,'BER','LGW'),
('leg_9',300,'BER','MUC'),
('leg_10',1600,'CAN','HND'),
('leg_11',500,'CDG','BCN'),
('leg_12',600,'CDG','FCO'),
('leg_13',200,'CDG','LHR'),
('leg_14',400,'CDG','MUC'),
('leg_15',200,'DFW','IAH'),
('leg_16',800,'FCO','MAD'),
('leg_17',300,'FRA','BER'),
('leg_18',100,'HND','NRT'),
('leg_19',300,'HOU','DFW'),
('leg_20',100,'IAH','HOU'),
('leg_21',600,'LGW','BER'),
('leg_22',600,'LHR','BER'),
('leg_23',500,'LHR','MUC'),
('leg_24',300,'MAD','BCN'),
('leg_25',600,'MAD','CDG'),
('leg_26',800,'MAD','FCO'),
('leg_27',300,'MUC','BER'),
('leg_28',400,'MUC','CDG'),
('leg_29',400,'MUC','FCO'),
('leg_30',200,'MUC','FRA'),
('leg_31',3700,'ORD','CDG');



drop table if exists route;
create table route (
	routeID char(50) not null,
	primary key (routeID)
);

INSERT INTO route VALUES
('americas_hub_exchange'),
('americas_one'),
('americas_three'),
('americas_two'),
('euro_north'),
('euro_south'),
('big_europe_loop'),
('pacific_rim_tour'),
('south_euro_loop'),
('texas_local'),
('germany_local');

drop table if exists flight;
create table flight (
	flightID char(50) not null,
	cost integer not null,
	follow char(50) not null,
	constraint fk9 foreign key (follow) references route (routeID),
	primary key (flightID)
);

INSERT INTO flight VALUES
('dl_10',200,'americas_one'),
('un_38',200,'americas_three'),
('ba_61',200,'americas_two'),
('lf_20',300,'euro_north'),
('km_16',400,'euro_south'),
('ba_51',100,'big_europe_loop'),
('ja_35',300,'pacific_rim_tour'),
('ry_34',100,'germany_local');

drop table if exists passenger;
create table passenger (
	personID char(50) not null,
	miles integer not null,
	funds integer not null,
	constraint fk10 foreign key (personID) references person (personID),
	primary key (personID)
);

INSERT INTO passenger VALUES
('p21',771,700),
('p22',374,200),
('p23',414,400),
('p24',292,500),
('p25',390,300),
('p26',302,600),
('p27',470,400),
('p28',208,400),
('p29',292,700),
('p30',686,500),
('p31',547,400),
('p32',257,500),
('p33',564,600),
('p34',211,200),
('p35',233,500),
('p36',293,400),
('p37',552,700),
('p38',812,700),
('p39',541,400),
('p40',441,700),
('p41',875,300),
('p42',691,500),
('p43',572,300),
('p44',572,500),
('p45',663,500);

drop table if exists vacation;
create table vacation (
	personID char(50) not null,
	destination char(100),
	sequence integer not null,
	constraint fk11 foreign key (personID) references person (personID),
	primary key (personID, sequence)
);
INSERT INTO vacation VALUES
('p21', 'AMS', 1),
('p22', 'AMS', 1),
('p23', 'BER', 1),
('p24', 'MUC', 1),
('p24', 'MUC', 2),
('p25', 'MUC', 1),
('p26', 'MUC', 1),
('p27', 'BER', 1),
('p28', 'LGW', 1),
('p29', 'FCO', 1),
('p29', 'LHR', 2),
('p30', 'FCO', 1),
('p30', 'MAD', 2),
('p31', 'FCO', 1),
('p32', 'FCO', 1),
('p33', 'CAN', 1),
('p34', 'HND', 1),
('p35', 'LGW', 1),
('p36', 'FCO', 1),
('p37', 'FCO', 1),
('p37', 'LGW', 2),
('p37', 'CDG', 3),
('p38', 'MUC', 1),
('p39', 'MUC', 1),
('p40', 'HND', 1);

drop table if exists pilot;
create table pilot (
	personID char(50) not null,
	taxID char(50) not null,
	experience integer not null,
	commands char(50),
	constraint fk12 foreign key (personID) references person (personID),
	constraint fk13 foreign key (commands) references flight (flightID),
	primary key (personID, taxID)
);

INSERT INTO pilot VALUES
('p1','330-12-6907',31,'dl_10'),
('p10','769-60-1266',15,'lf_20'),
('p11','369-22-9505',22,'km_16'),
('p12','680-92-5329',24,'ry_34'),
('p13','513-40-4168',24,'km_16'),
('p14','454-71-7847',13,'km_16'),
('p15','153-47-8101',30,'ja_35'),
('p16','598-47-5172',28,'ja_35'),
('p17','865-71-6800',36,NULL),
('p18','250-86-2784',23,NULL),
('p19','386-39-7881',2,NULL),
('p2','842-88-1257',9,'dl_10'),
('p20','522-44-3098',28,NULL),
('p3','750-24-7616',11,'un_38'),
('p4','776-21-8098',24,'un_38'),
('p5','933-93-2165',27,'ba_61'),
('p6','707-84-4555',38,'ba_61'),
('p7','450-25-5617',13,'lf_20'),
('p8','701-38-2179',12,'ry_34'),
('p9','936-44-6941',13,'lf_20');

drop table if exists pilot_licenses;
create table pilot_licenses (
	personID char(50) not null,
	taxID char(50) not null,
	license_type char(50) not null,
	constraint fk14 foreign key (personID, taxID) references pilot (personID, taxID),
	primary key (taxID, license_type)
);

INSERT INTO pilot_licenses VALUES
('p1','330-12-6907','jets'),
('p10','769-60-1266','jets'),
('p11','369-22-9505','jets'),
('p11','369-22-9505','props'),
('p12','680-92-5329','props'),
('p13','513-40-4168','jets'),
('p14','454-71-7847','jets'),
('p15','153-47-8101','jets'),
('p15','153-47-8101','props'),
('p15','153-47-8101','testing'),
('p16','598-47-5172','jets'),
('p17','865-71-6800','jets'),
('p17','865-71-6800','props'),
('p18','250-86-2784','jets'),
('p19','386-39-7881','jets'),
('p2','842-88-1257','jets'),
('p2','842-88-1257','props'),
('p20','522-44-3098','jets'),
('p3','750-24-7616','jets'),
('p4','776-21-8098','jets'),
('p4','776-21-8098','props'),
('p5','933-93-2165','jets'),
('p6','707-84-4555','jets'),
('p6','707-84-4555','props'),
('p7','450-25-5617','jets'),
('p8','701-38-2179','props'),
('p9','936-44-6941','jets'),
('p9','936-44-6941','props'),
('p9','936-44-6941','testing');

drop table if exists paths;
create table paths (
routeID char(50) not null,
legID char(50) not null,
sequence integer not null,
constraint fk15 foreign key (legID) references leg (legID),
constraint fk18 foreign key (routeID) references route (routeID),
primary key (legID, routeID, sequence)
);
INSERT INTO paths VALUES
('americas_hub_exchange','leg_4', 1),
('americas_one','leg_2', 1),
('americas_one','leg_1', 2),
('americas_three','leg_31', 1),
('americas_three','leg_14', 2),
('americas_two','leg_3', 1),
('americas_two','leg_22', 2),
('big_europe_loop','leg_23', 1),
('big_europe_loop','leg_29', 2),
('big_europe_loop','leg_16', 3),
('big_europe_loop','leg_25', 4),
('big_europe_loop','leg_13', 5),
('euro_north','leg_16',1),
('euro_north','leg_24', 2),
('euro_north','leg_5', 3),
('euro_north','leg_14', 4),
('euro_north','leg_27', 5),
('euro_north','leg_8', 6),
('euro_south','leg_21', 1),
('euro_south','leg_9', 2),
('euro_south','leg_28', 3),
('euro_south','leg_11', 4),
('euro_south','leg_6', 5),
('euro_south','leg_26', 6),
('germany_local','leg_9',1),
('germany_local','leg_30',2),
('germany_local','leg_17', 3),
('pacific_rim_tour','leg_7',1),
('pacific_rim_tour','leg_10',2),
('pacific_rim_tour','leg_18',3),
('south_euro_loop','leg_16',1),
('south_euro_loop','leg_24',2),
('south_euro_loop','leg_5',3),
('south_euro_loop','leg_12',4),
('texas_local','leg_15',1),
('texas_local','leg_20',2),
('texas_local','leg_19',3);

drop table if exists supports;
create table supports (
	airlineID char(50) not null,
	flightID char(50) not null,
	progress integer not null,
	flightstatus char(50) not null,
	next_time char(50) not null, 
	tail_num char(50) not null,
	constraint fk16 foreign key (airlineID, tail_num) references airplane (airlineID, tail_num),
	constraint fk17 foreign key (flightID) references flight (flightID),
	primary key (airlineID, flightID, tail_num)
);

INSERT INTO supports VALUES
('Delta','dl_10',1,'in_flight','08:00:00','n106js'),
('United','un_38',2,'in_flight','14:30:00','n380sd'),
('British Airways','ba_61',0,'on_ground','09:30:00','n616lt'),
('Lufthansa','lf_20',3,'in_flight','11:00:00','n620la'),
('KLM','km_16',6,'in_flight','14:00:00','n161fk'),
('British Airways','ba_51',0,'on_ground','11:30:00','n517ly'),
('Japan Airlines','ja_35',1,'in_flight','09:30:00','n305fv'),
('Ryanair','ry_34',0,'on_ground','15:00:00','n341eb');


