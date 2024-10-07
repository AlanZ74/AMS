-- CS4400: Introduction to Database Systems: Tuesday, September 12, 2023
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
	if ip_airlineID not in (select airlineID from airline) then leave sp_main; end if;
    if ip_tail_num in (select tail_num from airplane where ip_airlineID = airlineID) then leave sp_main; end if;
    if ip_locationID in (select locationID from location) then leave sp_main; end if;
    if ip_seat_capacity = 0 or ip_speed = 0 then leave sp_main; end if;
    insert into location values (ip_locationID);
    insert into airplane values (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);
end //
delimiter ;



-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin
	if ip_airportID in (select airportID from airport) then leave sp_main; end if;
    if ip_locationID in (select locationID from location) then leave sp_main; end if;
    insert into location values (ip_locationID);
    insert into airport values (ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);
end //
delimiter ;


-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin
	if ip_personID in (select personID from person) then leave sp_main; end if;
    if ip_first_name is null then leave sp_main; end if;
    insert into person values (ip_personID, ip_first_name, ip_last_name, ip_locationID);
    if ip_taxID is not null then insert into pilot values (ip_personID, ip_taxID, ip_experience, null);
	else insert into passenger values (ip_personID, ip_miles, ip_funds);
	end if;
end //
delimiter ;


-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it laready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
	if ip_personID not in (select personID from pilot_licenses) then insert into pilot_licenses values (ip_personID, ip_license); leave sp_main; end if;
	if ip_license not in (select license from pilot_licenses where ip_personID = personID) then insert into pilot_licenses values (ip_personID, ip_license);
    else delete from pilot_licenses where ip_personID = personID and ip_license = license;
    end if;
end //
delimiter ;


-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin
	if ip_routeID not in (select routeID from route) then leave sp_main; end if;
    if ip_support_tail is not null then
		if ip_support_tail in (select support_tail from flight where ip_support_airline = support_airline) then leave sp_main; end if;
	end if;
    set @max_sequence = (select max(sequence) from route_path where routeID = ip_routeID);
    if ip_progress >= @max_sequence then leave sp_main; end if;
    insert into flight values (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, 'on_ground', ip_next_time, ip_cost);
end //
delimiter ;


-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin
	set @finished_leg_sequence = (select progress from flight where ip_flightID = flightID);
    set @route = (select routeID from flight where ip_flightID = flightID);
	update flight set next_time = addtime(next_time, '1:00:00'), airplane_status = 'on_ground' where ip_flightID = flightID;
    update pilot set experience = experience + 1 where ip_flightID = commanding_flight;
    set @finished_legID = (select legID from route_path where @route = routeID and @finished_leg_sequence = sequence);
    set @finished_leg_miles = (select distance from leg where @finished_legID = legID);
    set @airline = (select support_airline from flight where ip_flightID = flightID);
    set @tail_number = (select support_tail from flight where ip_flightID = flightID);
    set @location = (select locationID from airplane where @airline = airlineID and @tail_number = tail_num);
    update passenger set miles = miles + @finished_leg_miles where personID in (select personID from person where locationID = @location);
end //
delimiter ;



-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin
 declare ip_airplane_type varchar(100);
    declare ip_pilot_count integer;

    select plane_type, 
           case when plane_type = 'jet' then 2 else 1 end as pilot_count
    into ip_airplane_type, ip_pilot_count
    from airplane
    where tail_num = (select support_tail from flight where flightID = ip_flightID);

    if (select count(*) from person right outer join pilot on person.personID = pilot.personID where pilot.commanding_flight=ip_flightID and person.locationID = (select locationID from airplane where tail_num = (select support_tail from flight where flightID = ip_flightID))) < ip_pilot_count
    then
        update flight set next_time = addtime(next_time, '0:30:00') where flightID = ip_flightID;
    else
		set @ip_routeID = (select routeID from flight where flightID = ip_flightID);
        set @ip_support = (select support_tail from flight where flightID = ip_flightID);
        update flight set next_time = addtime(next_time, leg_time((select distance from leg join route_path on leg.legID=route_path.legID where routeID = @ip_routeID and sequence = progress),
                                                                (select speed from airplane where tail_num = @ip_support)))
        where flightID = ip_flightID and progress < (select max(sequence) from route_path where routeID = @ip_routeID);
    end if;

end //
delimiter ;


-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
declare currentAirport char(3);
if not exists (select * from flight where flightID = ip_flightID) then
        leave sp_main;
    end if;

    select departure into currentAirport from leg where legID = (
        select legID from route_path where routeID = (select routeID from flight where flightID = ip_flightID) and sequence = 1
    );

    update passenger
    set funds = funds - (
            select cost from flight where flightID = ip_flightID
        )
    where personID in (
        select personID from passenger_vacations where airportID = currentAirport
    );

    update flight
    set progress = progress + 1
    where flightID = ip_flightID;

end //
delimiter ;

-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
 declare ip_origin_airport varchar(3);
	set @ip_airport = 
    (select arrival
    from leg
    where legID = (select legID from route_path where routeID = (select routeID from flight where flightID = ip_flightID) and sequence = (select progress from flight where flightID = ip_flightID)));
    set @portID = (select locationID from airport where airportID = @ip_airport);
    set @airline = (select support_airline from flight where ip_flightID = flightID);
    set @tail_number = (select support_tail from flight where ip_flightID = flightID);
    set @location = (select locationID from airplane where @airline = airlineID and @tail_number = tail_num);
	update person set locationID = @portID where locationID = @location and personID in (select personID from passenger) and personID in (select personID from passenger_vacations where airportID = @ip_airport);
end //
delimiter ;


-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin

set @pilotcommands = (select commanding_flight from pilot where personID = ip_personID);
if @pilotcommands is not NULL
	then leave sp_main; end if;

set @pilotlicense = (select license from pilot_licenses where personID = ip_personID);
set @airplanetype = (select plane_type from airplane where tail_num = @tailnumber);
if @pilotlicense != @airplanetype
	then leave sp_main; end if;

set @tailnumber = (select support_tail from flight where flightID = ip_flightID);
set @airlineID = (select support_airline from flight where flightID = ip_flightID);
set @flightlocation = (select locationID from airplane where tail_num = @tailnumber and airlineID = @airlineID);

update person set locationID = @flightlocation where personID = ip_personID;
    
update pilot set commanding_flight = ip_flightID where personID = ip_personID;


end //
delimiter ;

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin

set @currerntleg = (select progress from flight where flightID = ip_flightID);
set @routeID = (select routeID from flight where flightID = ip_flightID);
set @lastleg = (select max(sequence) from route_path where routeID = @routeID);
set @flightstatus = (select airplane_status from flight where flightID = ip_flightID);

set @tailnumber = (select support_tail from flight where flightID = ip_flightID);
set @airlineID = (select support_airline from flight where flightID = ip_flightID);
set @flightlocation = (select locationID from airplane where tail_num = @tailnumber and airlineID = @airlineID);
set @passengersonboard = (select count(*) from person where locationID = @flightlocation and personID not in (select personID from pilot where commanding_flight = ip_flightID));

set @legID = (select legID from route_path where sequence = @lastleg and routeID = @routeID);
set @lastlegarrival = (select arrival from leg where legID = @legID);
set @lastleglocation = (select locationID from airport where airportID = @lastlegarrival);

if @lastleg != @currentleg or @flightstatus != 'on_ground' or @passengersonboard != 0
	then leave sp_main; end if;

update person set locationID = @lastleglocation where personID in (select personID from (select personID from pilot where commanding_flight = ip_flightID) as pid);
update pilot set commanding_flight = NULL where personID in (select personID from (select personID from pilot where commanding_flight = ip_flightID) as pid);
end //
delimiter ;


-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin

set @currerntleg = (select progress from flight where flightID = ip_flightID);
set @routeID = (select routeID from flight where flightID = ip_flightID);
set @firstleg = (select min(sequence) from route_path where routeID = @routeID);
set @lastleg = (select max(sequence) from route_path where routeID = @routeID);
set @flightstatus = (select airplane_status from flight where flightID = ip_flightID);

set @tailnumber = (select support_tail from flight where flightID = ip_flightID);
set @airlineID = (select support_airline from flight where flightID = ip_flightID);
set @flightlocation = (select locationID from airplane where tail_num = @tailnumber and airlineID = @airlineID);
set @passengersonboard = (select count(*) from person where locationID = @flightlocation);

if @lastleg != @currentleg or @firstlegf != @currentleg or @flightstatus != 'on_ground' or @passengersonboard != 0
	then leave sp_main; end if;

delete from flight where flightID = ip_flightID;

end //
delimiter ;


-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin

set @nexttime = (select min(next_time) from flight);
set @numsametimeflights = (select count(*) from flight where next_time = @nexttime);
if @numsametimeflights > 1
	then set @numslandingflights = (select count(*) from flight where next_time = @nexttime and airplane_status = 'in_flight');
    if @numslandingflights > 1
		then set @nextflight = (select min(flightID) from flight where next_time = @nexttime and airplane_status = 'in_flight');
	else set @nextflight = (select flightID from flight where next_time = @nexttime and airplane_status = 'in_flight'); 
    end if;
else set @nextflight = (select flightID from flight where next_time = @nexttime); 
end if;

set @airplanestatus = (select airplane_status from flight where flightID = @nextflight);
if @airplanestatus = 'in_flight'
	then call flight_landing(@nextflight);
    call passengers_disembark(@nextflight);

    end if;
    
set @currentleg = (select progress from flight where flightID = @nextflight);
set @routeID = (select routeID from flight where flightID = @nextflight);
set @lastleg = (select max(sequence) from route_path where routeID = @routeID);

if @airplanestatus = 'on_ground' and @currentleg != @lastleg
	then call passenger_board(@nextflight);
    call flight_takeoff(@nextflight);
    end if;

if @airplanestatus = 'on_ground' and @currentleg = @lastleg
	then call recycle_crew(@nextflight);
    call retire_flight(@nextflight);
    end if;
    
end //
delimiter ;

-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
select leg.departure, leg.arrival, count(flightID), group_concat(flightID), min(next_time), max(next_time), group_concat(locationID) as airplane_list
from route_path right outer join flight on route_path.routeID=flight.routeID and route_path.sequence=flight.progress
left outer join leg on leg.legID=route_path.legID left outer join airplane on flight.support_airline=airplane.airlineID and flight.support_tail=airplane.tail_num
where airplane_status like 'in_flight'
group by leg.departure, leg.arrival
order by airplane_list;


-- [15] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
(select leg.arrival as departing_from, count(flightID), group_concat(flightID), min(next_time), max(next_time), group_concat(locationID) as airplane_list
from route_path right outer join flight on route_path.routeID=flight.routeID and route_path.sequence=flight.progress
left outer join leg on leg.legID=route_path.legID left outer join airplane on flight.support_airline=airplane.airlineID and flight.support_tail=airplane.tail_num
where airplane_status like 'on_ground' and flight.progress not like 0
group by leg.arrival) union (select leg.departure as departing_from, count(flightID), group_concat(flightID), min(next_time), max(next_time), group_concat(locationID) as airplane_list
from route_path right outer join flight on route_path.routeID=flight.routeID and route_path.sequence=(flight.progress + 1)
left outer join leg on leg.legID=route_path.legID left outer join airplane on flight.support_airline=airplane.airlineID and flight.support_tail=airplane.tail_num
where airplane_status like 'on_ground' and flight.progress like 0
group by leg.departure)
order by airplane_list;


-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
select leg.departure, leg.arrival, count(distinct flightID), group_concat(distinct person.locationID) as airplane_list, group_concat(distinct flightID), min(next_time), max(next_time), count(taxID), count(person.personID) - count(taxID), count(person.personID), group_concat(distinct person.personID) as person_list
from route_path right outer join flight on route_path.routeID=flight.routeID and route_path.sequence=flight.progress
left outer join leg on leg.legID=route_path.legID left outer join airplane on flight.support_airline=airplane.airlineID and flight.support_tail=airplane.tail_num
left outer join person on airplane.locationID=person.locationID left outer join pilot on pilot.personID=person.personID
where airplane_status like 'in_flight'
group by leg.departure, leg.arrival
order by airplane_list;


-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select airport.airportID, airport.locationID, airport_name, city, state, country, count(taxID), count(person.personID) - count(taxID), count(person.personID), group_concat(person.personID) as person_list
from airport left outer join person on airport.locationID=person.locationID left outer join pilot on pilot.personID=person.personID
group by airportID
having count(person.personID) !=0
order by person_list;


-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select a.route, num_legs, leg_sequence, route_length, num_flights, flight_list, airport_sequence
from (select route_path.routeID as route, count(distinct route_path.legID) as num_legs, group_concat(distinct route_path.legID order by sequence) as leg_sequence, sum(distance) as route_length, group_concat(concat(departure, '->', arrival)) as airport_sequence
from route_path left outer join leg on route_path.legID=leg.legID
group by routeID) as a left outer join (select route_path.routeID as route, count(distinct flightID) as num_flights, group_concat(distinct flightID) as flight_list
from route_path left outer join flight on route_path.routeID=flight.routeID group by route_path.routeID) as b on a.route=b.route
order by a.route;


-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
select city, state, country, count(airportID), group_concat(airportID), group_concat(airport_name)
from airport
group by city, state, country
having count(airportID) > 1;

