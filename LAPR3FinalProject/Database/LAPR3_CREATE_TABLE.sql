--create table
DROP TABLE config;
DROP TABLE path_places;
DROP TABLE rental;
DROP TABLE scooter;
DROP TABLE bicycle;
DROP TABLE vehicle;
DROP TABLE user_app;
DROP TABLE scooter_type;
DROP TABLE park_capacity;
DROP TABLE vehicle_type;
DROP TABLE park;
DROP TABLE point_interest;
DROP TABLE invoice;
DROP TABLE invoice_line;
DROP TABLE receipt;

--config table
CREATE TABLE config(
    initial_date    DATE    CONSTRAINT      pk_config_initial_date   PRIMARY KEY,
    admininstrator_username VARCHAR(20),
    administrator_pwd   VARCHAR(18),
    initial_cost_registration   NUMBER(5,2)
);

CREATE TABLE point_interest(
    id_point INTEGER     GENERATED BY DEFAULT ON NULL AS IDENTITY
                         CONSTRAINT pk_point_interest_id_point_interest  PRIMARY KEY,
    poi_description    VARCHAR(50)     CONSTRAINT nn_point_interest_poi_description NOT NULL,
    latitude    NUMERIC(11, 8)     CONSTRAINT ck_point_interest_latitude CHECK (latitude BETWEEN -90 AND 90),
    longitude  NUMERIC(11, 8)    CONSTRAINT ck_point_interest_longitude CHECK (longitude BETWEEN -180 AND 180),
    elevation  NUMERIC(11, 8)
);
--park table
CREATE TABLE park(
    id_park     INTEGER     CONSTRAINT pk_park_id_park  PRIMARY KEY,
    ref_park    VARCHAR(20) CONSTRAINT nn_park_ref_park  NOT NULL
                            CONSTRAINT uk_park_ref_park     UNIQUE,
    park_state  NUMBER(1)   CONSTRAINT nn_park_park_state   NOT NULL 
                            CONSTRAINT ck_park_park_state   CHECK  (park_state in (0,1)),
    park_input_voltage  NUMERIC(5,2)     CONSTRAINT ck_park_park_input_voltage CHECK (park_input_voltage > 0) ,
    park_input_current  NUMERIC(5,2)     CONSTRAINT ck_park_park_input_current CHECK (park_input_current > 0)
    
);

--table path_places
CREATE TABLE path_places(
    id_point_from   INTEGER,
    id_point_to     INTEGER,
    kinetic_coefficient NUMERIC(4,3)    CONSTRAINT ck_path_places_kinetic_coefficient CHECK(kinetic_coefficient > 0),
    wind_direction  NUMERIC(5,2)    CONSTRAINT ck_path_places_wind_direction    CHECK(wind_direction BETWEEN 0 AND 360),
    wind_speed  NUMERIC(4,1)    CONSTRAINT ck_path_places_wind_speed    CHECK(wind_speed > 0),
    
    CONSTRAINT pk_path_places_id_point_from_id_point_to     PRIMARY KEY(id_point_from, id_point_to)
);

--vehicle_type table
CREATE TABLE vehicle_type(
    id_vehicle_type     INTEGER    CONSTRAINT pk_vehicle_type_id_vehicle_type      PRIMARY KEY,
    vehicle_type_description       VARCHAR(20)      CONSTRAINT nn_vehicle_type_vehicle_type_description     NOT NULL
                                                    CONSTRAINT ck_vehicle_type_vehicle_type_description    
                                                        CHECK(REGEXP_LIKE(vehicle_type_description, 'scooter|bicycle', 'i'))
                                                    CONSTRAINT uk_vehicle_type_vehicle_type_description UNIQUE
);

--vehicle table
CREATE TABLE vehicle(
    id_vehicle      INTEGER      GENERATED BY DEFAULT ON NULL AS IDENTITY
                    CONSTRAINT pk_vehicle_id_vehicle     PRIMARY KEY,
    id_park INTEGER,
    id_vehicle_type INTEGER,
    vehicle_description     VARCHAR(7)      CONSTRAINT uk_vehicle_vehicle_description   UNIQUE
                                            CONSTRAINT nn_vehicle_vehicle_description   NOT NULL,
    vehicle_state       NUMBER(1)   CONSTRAINT nn_vehicle_vehicle_state   NOT NULL  
                           CONSTRAINT ck_vehicle_vehicle_state   CHECK  (vehicle_state in (0,1)),
    weight      NUMBER(5,2)     CONSTRAINT ck_vehicle_weight    CHECK(weight >0),
    aerodynamic_coefficient     NUMBER(5,2)     CONSTRAINT ck_vehicle_aerodynamic_coefficient    CHECK(aerodynamic_coefficient >0),
    frontal_area        NUMBER(5,2)     CONSTRAINT ck_vehicle_frotal_area    CHECK(frontal_area >0)
);

--bicycle table
CREATE TABLE bicycle(
    id_bicycle  INTEGER CONSTRAINT pk_bicycle_id_bicycle  PRIMARY KEY,
    wheel_size  INTEGER
);

--scooter_type table
CREATE TABLE scooter_type(
    id_scooter_type     INTEGER    CONSTRAINT pk_scooter_type_id_scooter_type  PRIMARY KEY,
    scooter_type_description    VARCHAR(20)     CONSTRAINT ck_scooter_type_scooter_type_description    
                                                        CHECK(REGEXP_LIKE(scooter_type_description, 'city|off road', 'i'))
                                CONSTRAINT uk_scooter_type_scooter_type_description UNIQUE
);

--scooter table
CREATE TABLE scooter(
    id_scooter      INTEGER CONSTRAINT pk_scooter_id_scooter  PRIMARY KEY,
    id_scooter_type     INTEGER,
    max_batery_capacity     NUMBER(5,2)     CONSTRAINT ck_scooter_max_batery_capacity    CHECK(max_batery_capacity >0),
    actual_batery_capacity      NUMBER(5,2)     CONSTRAINT ck_scooter_actual_batery_capacity    CHECK(actual_batery_capacity >= 0),
    motor   NUMBER(7,2) CONSTRAINT ck_scooter_motor    CHECK(motor >= 0)
);

--park_capacity table
CREATE TABLE park_capacity(
    id_vehicle_type INTEGER ,
    id_park INTEGER,
    capacity_vehicle   INTEGER     CONSTRAINT ck_park_capacity_capacity_vehicle    CHECK(capacity_vehicle >0),
    availability_vehicle   INTEGER  CONSTRAINT ck_park_capacity_availability_vehicle    CHECK(availability_vehicle >= 0),
    
    CONSTRAINT ck_park_capacity_capacity_vehicle_availability_vehicle   CHECK (capacity_vehicle >= availability_vehicle),
    
    CONSTRAINT pk_park_capacity_id_vehicle_type_id_park  PRIMARY KEY (id_vehicle_type, id_park)
);

--user table
CREATE TABLE user_app(
    id_user INTEGER     GENERATED BY DEFAULT ON NULL AS IDENTITY
                        CONSTRAINT pk_user_app_id_user  PRIMARY KEY,
    email   VARCHAR(40)     CONSTRAINT nn_user_app_email    NOT NULL
                            CONSTRAINT uk_user_app_email    UNIQUE,
    username    VARCHAR(20)     CONSTRAINT uk_user_app_username     UNIQUE,
    credit_card     VARCHAR(16)     CONSTRAINT uk_user_app_credit_card  UNIQUE,
    cycling_average_speed   NUMBER(5,2)     CONSTRAINT ck_user_app_cycling_average_speed    CHECK(cycling_average_speed >0),
    height      INTEGER     CONSTRAINT ck_user_app_height    CHECK(height >0),
    weight      NUMBER(5,2)     CONSTRAINT ck_user_app_weight    CHECK (weight >0),
    gender      CHAR(1)     CONSTRAINT ck_user_app_gender    CHECK(REGEXP_LIKE(gender, 'F|M', 'i')),
    pwd         VARCHAR(32),
    points     INTEGER     DEFAULT(0)  CONSTRAINT ck_user_app_user_points   CHECK(points >= 0)
);

--rental table
CREATE TABLE rental(
    id_rental       INTEGER    GENERATED BY DEFAULT ON NULL AS IDENTITY
                    CONSTRAINT pk_rental_id_rental      PRIMARY KEY,
    id_park_picking INTEGER,
    id_park_delivery    INTEGER,
    id_vehicle      INTEGER,
    id_user         INTEGER,
    rental_cost     NUMBER(5,2)     CONSTRAINT ck_rental_rental_cost    CHECK (rental_cost>=0),
    rental_begin_date_hour     DATE    DEFAULT (SYSDATE),
    rental_end_date_hour      DATE    DEFAULT (SYSDATE),
    rental_duration     INTEGER     CONSTRAINT ck_rental_rental_duration    CHECK (rental_duration>0),
    earned_points INTEGER    DEFAULT(0) CONSTRAINT ck_rental_earned_points    CHECK (earned_points>=0)
);

--invoice_table
CREATE  TABLE invoice(
    id_invoice           INTEGER    GENERATED BY DEFAULT ON NULL AS IDENTITY    
                         CONSTRAINT pk_invoice_id_invoice              PRIMARY KEY,       
    id_user              INTEGER,
    total_cost           NUMBER(6,2),
    issue_date           DATE       DEFAULT(TRUNC(SYSDATE)),
    state_invoice        NUMBER(1)
);

--invoice_line table
CREATE TABLE invoice_line(
    id_rental            INTEGER    CONSTRAINT pk_invoice_line_id_rental PRIMARY KEY,   
    id_invoice           INTEGER,   
    id_vehicle           INTEGER,
    rental_duration      INTEGER,
    rental_cost          NUMBER(6,2),
    rental_end_date_hour      DATE,
    earned_points  INTEGER DEFAULT(0) CONSTRAINT ck_invoice_line_earned_points CHECK(earned_points>=0)
);

--receipt table
CREATE TABLE receipt (
    id_receipt           INTEGER    GENERATED BY DEFAULT ON NULL AS IDENTITY
                         CONSTRAINT pk_receipt_id_receipt            PRIMARY KEY,                            
    id_invoice           INTEGER,    
    id_user              INTEGER,
    total_cost           NUMBER(10,2),
    receipt_date         DATE       DEFAULT(SYSDATE)            
);
    
--foreign key constraints
--park table
ALTER TABLE park ADD CONSTRAINT fk_park_id_park FOREIGN KEY (id_park) REFERENCES point_interest(id_point);

--path_places table
ALTER TABLE path_places ADD CONSTRAINT fk_path_places_id_point_from FOREIGN KEY(id_point_from) REFERENCES point_interest(id_point);
ALTER TABLE path_places ADD CONSTRAINT fk_path_places_id_point_to FOREIGN KEY(id_point_to) REFERENCES point_interest(id_point);

--vehicle table
ALTER TABLE vehicle ADD CONSTRAINT fk_vehicle_id_park   FOREIGN KEY (id_park) REFERENCES park(id_park);
ALTER TABLE vehicle ADD CONSTRAINT fk_vehicle_id_vehicle_type FOREIGN KEY(id_vehicle_type) REFERENCES vehicle_type(id_vehicle_type);

--bicycle table
ALTER TABLE bicycle ADD CONSTRAINT fk_bicycle_id_bicycle    FOREIGN KEY (id_bicycle) REFERENCES vehicle(id_vehicle);

--scooter table
ALTER TABLE scooter ADD CONSTRAINT fk_scooter_id_scooter    FOREIGN KEY (id_scooter)    REFERENCES vehicle(id_vehicle);
ALTER TABLE scooter ADD CONSTRAINT fk_scooter_id_scooter_type   FOREIGN KEY (id_scooter_type)   REFERENCES scooter_type(id_scooter_type);

--park_capacity table
ALTER TABLE park_capacity ADD CONSTRAINT fk_park_capacity_id_vehicle_type   FOREIGN KEY (id_vehicle_type) REFERENCES vehicle_type(id_vehicle_type);
ALTER TABLE park_capacity ADD CONSTRAINT fk_park_capacity_id_park   FOREIGN KEY (id_park) REFERENCES park(id_park);

--rental table
ALTER TABLE rental ADD CONSTRAINT fk_rental_id_park_picking FOREIGN KEY (id_park_picking) REFERENCES park(id_park);
ALTER TABLE rental ADD CONSTRAINT fk_rental_id_park_delivery FOREIGN KEY (id_park_delivery) REFERENCES park(id_park);
ALTER TABLE rental ADD CONSTRAINT fk_rental_id_vehicle  FOREIGN KEY (id_vehicle)    REFERENCES vehicle(id_vehicle);
ALTER TABLE rental ADD CONSTRAINT fk_rental_id_user   FOREIGN KEY (id_user)     REFERENCES user_app(id_user);

--invoice
ALTER TABLE invoice              ADD CONSTRAINT fk_invoice_id_user                        FOREIGN KEY (id_user)                  REFERENCES user_app(id_user);

--invoice_lines
ALTER TABLE invoice_line        ADD CONSTRAINT fk_invoice_line_id_rental                FOREIGN KEY (id_rental)                REFERENCES rental(id_rental);
ALTER TABLE invoice_line        ADD CONSTRAINT fk_invoice_line_id_invoice               FOREIGN KEY (id_invoice)               REFERENCES invoice(id_invoice);

--receipt
ALTER TABLE receipt              ADD CONSTRAINT fk_receipt_id_invoice                     FOREIGN KEY (id_invoice)               REFERENCES invoice(id_invoice);
ALTER TABLE receipt              ADD CONSTRAINT fk_receipt_id_user                        FOREIGN KEY (id_user)                  REFERENCES user_app(id_user);

COMMIT;
