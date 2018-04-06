begin;

create table users (
  user_username text, --PRIMARY KEY
  user_password text --NOT NULL
);

create table disponibility (
  disponibility_id smallint PRIMARY KEY,
  disponibility_status text NOT NULL
);

insert into disponibility(disponibility_id,disponibility_status) values(0,'available');
insert into disponibility(disponibility_id,disponibility_status) values(1,'unavailable');
insert into disponibility(disponibility_id,disponibility_status) values(2,'maybe');


create table sport_type (
  sport_type_id SERIAL, --PRIMARY KEY
  sport_type_name text --NOT NULL
);

create table procedure (
  procedure_id SERIAL, --PRIMARY KEY
  procedure_timestamp timestamp, --NOT NULL
  procedure_info text --NOT NULL
);

create table skill (
  skill_id SERIAL, --PRIMARY KEY
  skill_name text --NOT NULL
);

create table person (
  person_id serial,--PRIMARY KEY
  person_name text, --NOT NULL
  person_telephone text,
  person_email text,
  person_is_worker boolean, --NOT NULL
  person_location_address text,
  person_location_geo geometry(Point, 4326)
);

create table person_skills (
  person_id integer, --NOT NULL FOREIGN KEY REFERENCES person(person_id)
  skill_id integer --NOT NULL FOREIGN KEY REFERENCES skill(skill_id)
  --PK (person_id,skill_id)
);

create table event (
  event_id serial, --PRIMARY KEY
  event_name text, --NOT NULL
  event_date_start timestamp,
  event_date_end timestamp,
  event_location_address text,
  event_location_geo geometry(Point, 4326),
  event_charge numeric(14,2) DEFAULT 0, --NOT NULL
  event_ppv_charge numeric(14,2) DEFAULT 0, --NOT NULL
  event_live boolean DEFAULT FALSE, --NOT NULL
  event_special_notes text,
  event_organizer integer, --FOREIGN KEY REFERENCES person(person_id)
  event_fsk_check numeric(2) DEFAULT 18, --NOT NULL
  event_billing_info text,
  event_is_active boolean DEFAULT FALSE--NOT NULL
);

create table event_procedure (
  event_id integer, --NOT NULL FOREIGN KEY REFERENCES event(event_id)
  procedure_id integer --NOT NULL FOREIGN KEY REFERENCES procedure(procedure_id)
);

create table event_sport_type (
  event_id integer, --NOT NULL FOREIGN KEY REFERENCES event(event_id)
  sport_type_id integer --NOT NULL FOREIGN KEY REFERENCES sport_type(sport_type_id)
);

create table event_extern_person (
  event_id integer, --NOT NULL FOREIGN KEY REFERENCES event(event_id)
  person_id integer, --NOT NULL FOREIGN KEY REFERENCES person(person_id)
  extern_role text
);

create table event_disponibility (
  event_id integer, --NOT NULL FOREIGN KEY REFERENCES event(event_id)
  person_id integer, --NOT NULL FOREIGN KEY REFERENCES person(person_id)
  disponibility_id smallint --NOT NULL FOREIGN KEY REFERENCES disponibility(disponibility_id)
);

create table event_function (
  event_function_id serial, --PRIMARY KEY
  event_id integer, --NOT NULL FOREIGN KEY REFERENCES event(event_id)
  person_id integer, --FOREIGN KEY REFERENCES person(person_id)
  skill_id integer, --NOT NULL FOREIGN KEY REFERENCES skill(skill_id)
  event_function_description text,
  person_performance_grade numeric(1),
  person_performance_info text
);

commit;
