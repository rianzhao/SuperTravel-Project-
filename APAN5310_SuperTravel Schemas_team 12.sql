CREATE TABLE users (
	user_id			integer PRIMARY KEY,
	first_name 	varchar(50) NOT NULL,
	last_name   varchar(50) NOT NULL
);

CREATE TABLE airlines (
	airline_id		varchar(5) PRIMARY KEY,
	airline_name 	varchar(50) NOT NULL
);

CREATE TABLE address (
	address_id		integer PRIMARY KEY,
	street 	varchar(300),
	city	varchar(30),
	state	varchar(20),
	zip_code integer,
	country varchar(50)
);

CREATE TABLE hotels (
	hotel_id	varchar(50) PRIMARY KEY,
	name 		varchar(100) NOT NULL,
	address		varchar(50),
    city		varchar(20),
    province	varchar(3),
    country		varchar(20)
);



CREATE TABLE payments(
	payment_id 	integer,
	card_number	bigint,
	card_type	varchar(50),
	exp_date	date,
	name_on_card	varchar(50),
	PRIMARY KEY(payment_id)
);

CREATE TABLE airports (
	airport_id	varchar(3) PRIMARY KEY,
	name 		varchar(100) NOT NULL
    );

CREATE TABLE profiles(
	user_id		integer,
	address_id	integer,
	payment_id 	integer,
	gender		varchar(10),
	birth		date,
	preference	text,
	PRIMARY KEY(user_id,payment_id),
	FOREIGN KEY (user_id) REFERENCES users(user_id),
	FOREIGN KEY (address_id) REFERENCES address(address_id),
	FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
);

CREATE TABLE emails (
	user_id 	integer,
	email		varchar(100),
	PRIMARY KEY(user_id,email),
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE phones (
	user_id 	integer,
	phone		varchar(20),
	PRIMARY KEY(user_id,phone),
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE flights (
	flight_id 	varchar(50),
	airline_id	varchar(5),
	departure_airport	varchar(3),	
	arrival_airport		varchar(3),
	departure_time 		timestamp,
	arrival_time 		timestamp,
	PRIMARY KEY(flight_id, departure_time,arrival_time),
	FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
	FOREIGN KEY (departure_airport) REFERENCES airports(airport_id),
	FOREIGN KEY (arrival_airport) REFERENCES airports(airport_id)
);

CREATE TABLE hotel_booking (
	hotel_booking_id	varchar(15),
    hotel_id			varchar(50),
	check_in_date 		date,
	check_out_date 		date,
	total_price			numeric(11,2),
	PRIMARY KEY(hotel_booking_id),
    FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
);

CREATE TABLE reviews (
	hotel_booking_id varchar(15),
	hotel_id	varchar(50),
    user_id	   integer,
	check_out_date 	date,
	rating 		numeric(2,1),
	reviews 	text,
	PRIMARY KEY(user_id,hotel_id,check_out_date),
	FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id),
	FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (hotel_booking_id) REFERENCES hotel_booking(hotel_booking_id)
);

CREATE TABLE flight_booking (
	flight_booking_id	varchar(15),
	number_ticket		integer,
	total_cost			numeric(8,2),
	PRIMARY KEY(flight_booking_id)
);

CREATE TABLE flight_information (
	flight_booking_id	varchar(20),
	flight_id			varchar(50),
    departure_time		timestamp,
    arrival_time 		timestamp,
	seat				varchar(5),
	cabin				varchar(10),
	check_bag			integer,
    carry_on			integer,
    extra_total			numeric(8,2),
    number_of_stop		integer,
	PRIMARY KEY(flight_booking_id),
	FOREIGN KEY (flight_booking_id) REFERENCES flight_booking(flight_booking_id),
    FOREIGN KEY (flight_id, departure_time, arrival_time) REFERENCES flights(flight_id, departure_time, arrival_time)
);


CREATE TABLE flight_timestamp (
	flight_id			varchar(30),
	departure_time		timestamp,
	actual_departure_time		timestamp,
	arrival_time		timestamp,
	actual_arrival_time			timestamp,
	PRIMARY KEY(flight_id,departure_time, arrival_time),
    FOREIGN KEY (flight_id, departure_time, arrival_time) REFERENCES flights(flight_id, departure_time, arrival_time)
);

CREATE TABLE rental_company (
	rental_company_id			integer,
	name						varchar(50),
    address						varchar(50),
    city						varchar(50),
    state						varchar(2),
    country						varchar(20),
	PRIMARY KEY(rental_company_id)
);

CREATE TABLE car (
	car_id						integer PRIMARY KEY,
	rental_company_id			integer,
	make						varchar(30),
    model						varchar(30),
    year						integer,
    occupancy					integer,
    car_type					varchar(30),
    FOREIGN KEY (rental_company_id) REFERENCES rental_company(rental_company_id)
);

CREATE TABLE car_rental_booking (
	car_rental_id				varchar(15) PRIMARY KEY,
	rental_company_id			integer,
	car_id						integer,
    start_date				    date,
    end_date					date,
    total_price					numeric(8,2),
    FOREIGN KEY (rental_company_id) REFERENCES rental_company(rental_company_id),
    FOREIGN KEY (car_id) REFERENCES car(car_id)
);

CREATE TABLE user_booking (
	booking_id			varchar(15) PRIMARY KEY,
	user_id				integer NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE OR REPLACE FUNCTION review_trigger_function()
 		RETURNS trigger AS
 		$$
 			BEGIN
 				IF (
 					SELECT
 						COUNT(DISTINCT hb.hotel_booking_id)
 					FROM
 						hotel_booking hb
 					WHERE
 						hb.hotel_booking_id = NEW.hotel_booking_id
 						AND
 						hb.hotel_id = NEW.hotel_id
						AND hb.check_out_date <= CURRENT_DATE
 				) = 0
 				THEN RAISE EXCEPTION 'guest cannot post a review';
 				END IF;
 				RETURN NEW;
 			END;
 		$$
LANGUAGE plpgsql; 
 
CREATE TRIGGER review_trigger
BEFORE INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION review_trigger_function();
