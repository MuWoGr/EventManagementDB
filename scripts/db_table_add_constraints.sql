begin;

alter table users
  add constraint user_username_pk primary key(user_username),
  alter column user_password set not null;

alter table sport_type
  add constraint sport_type_id_pk primary key(sport_type_id),
  alter column sport_type_name set not null;

alter table skill
  add constraint skill_id_pk primary key(skill_id),
  alter column skill_name set not null;


alter table person
  add constraint person_id_pk primary key(person_id),
  alter column person_name set not null,
  alter column person_is_worker set not null;

--spation index on the location
create index person_geom_index
  on person using gist(person_location_geo);


alter table person_skills
  add constraint person_skills_person_fk
    foreign key (person_id)
    references person(person_id) 
    ON UPDATE CASCADE
    ON DELETE CASCADE, --When person is deleted, delete the person_skill entries
  add constraint person_skills_skill_fk
    foreign key (skill_id)
    references skill(skill_id) 
    ON UPDATE CASCADE
    ON DELETE CASCADE, --When the skill is deleted, delete referenced person_skill entries
  add constraint person_skills_pk
    primary key(person_id,skill_id);

alter table event
  add constraint event_id_pk primary key (event_id),
  alter column event_name set not null,
  alter column event_charge set not null,
  alter column event_ppv_charge set not null,
  alter column event_live set not null,
  alter column event_fsk_check set not null,
  add constraint event_organizer_person_fk
    foreign key (event_organizer)
    references person(person_id) 
    ON UPDATE CASCADE
    ON DELETE SET NULL, --When the organizer person entry gets deleted
  alter column event_is_active set not null;

--spation index on the location
create index event_geom_index
  on event using gist(event_location_geo);


alter table event_procedure
  add constraint event_procedure_pk primary key(procedure_id),
  alter column event_id set not null,
  alter column procedure_timestamp set not null,
  alter column procedure_info set not null,
  add constraint event_procedure_event_fk
    foreign key (event_id)
    references event(event_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE;

alter table event_sport_type
  add constraint event_sport_type_event_fk
    foreign key (event_id)
    references event(event_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE, --When event is deleted, delete all sport type entries for that event
  add constraint event_sport_type_sport_type_fk
    foreign key (sport_type_id)
    references sport_type(sport_type_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE, --When a sport type is deleted, delete the relation entry
  add constraint event_sport_type_pk
    primary key(event_id, sport_type_id);

alter table event_extern_person
  add constraint event_extern_person_event_fk
    foreign key (event_id)
    references event(event_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE, --When event is deleted, delete all extern person entries for that event
  add constraint event_extern_person_type_fk
    foreign key (person_id)
    references person(person_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE, --Person deletion -> all event_extern_person with that person are deleted
  add constraint event_extern_person_pk
    primary key(event_id,person_id);

alter table event_disponibility
  add constraint event_disponibility_event_fk
    foreign key (event_id)
    references event(event_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE, --Event deleted, delete all disponibility entries for that event
  add constraint event_disponibility_person_fk
    foreign key (person_id)
    references person(person_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE, --Person deleted, delete all disponibilities for that person
  add constraint event_disponibility_disponibility_fk
    foreign key (disponibility_id)
    references disponibility(disponibility_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE, --Disponibility type deleted->remove all event disponibilities with that disponibility type
  add constraint event_disponibility_pk
    primary key(event_id, person_id, disponibility_id);

alter table event_function
  add constraint event_function_id_pk primary key (event_function_id),
  alter column event_id set not null,
  alter column skill_id set not null,
  add constraint event_function_event_fk
    foreign key (event_id)
    references event(event_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE, --Event deleted, delete all event functions for that event
  add constraint event_function_person_fk
    foreign key (person_id)
    references person(person_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL, --Person deleted -> spot is open for other person
  add constraint event_function_skill_fk
    foreign key (skill_id)
    references skill(skill_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE; --Skill type deleted->delete all functions with that type


----------------------------------------------------------------------------
--Handle logic of inserting/updating event_function with person_id to see
--  if that person is available on the event_disponibility table
-- When adding person to event_function, check he is available
CREATE OR REPLACE FUNCTION event_function_check_person_disponibility() 
RETURNS trigger AS
$$
BEGIN
  --Check if we are adding a person
  IF (NEW.person_id IS NOT NULL)
  THEN
    IF EXISTS --disponibility of person for an event
      (SELECT 1 FROM event_disponibility ed
      WHERE ed.event_id = NEW.event_id 
        AND ed.person_id = NEW.person_id
        AND (ed.disponibility_id = 0 --available
        OR ed.disponibility_id = 2)) --maybe
    THEN
      RETURN NEW;
    ELSE
      RAISE EXCEPTION 'Person is not available for event';
    END IF;
  ELSE -- Inserting or updating event_function without person_id
    RETURN NEW;
  END IF;
END;
$$
LANGUAGE 'plpgsql';

--Trigger for checking person disponibility before inserting event_function
CREATE TRIGGER event_function_check_person_disponibility_trigger
  BEFORE INSERT OR UPDATE ON event_function
  FOR EACH ROW
  EXECUTE PROCEDURE event_function_check_person_disponibility();
----------------------------------------------------------------------------


----------------------------------------------------------------------------
--Handle logic of changing the status in event_disponibility of a person
--  to a unavailable status
--Removing assigned person of a event_function when their disponibility
--  for an event changes
CREATE OR REPLACE FUNCTION event_disponibility_remove_assignment_from_event_functions() 
RETURNS trigger AS
$$
BEGIN
  IF (NEW.disponibility_id = 1) --if person is not available
  THEN
    UPDATE event_function
      SET person_id = NULL
    WHERE event_id = NEW.event_id
      AND person_id = NEW.event_id;
  END IF;
  RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

--Trigger to check for updates or deletes in event_disponibilities
CREATE TRIGGER event_disponibility_remove_functions_when_unavailable
  BEFORE UPDATE ON event_disponibility
  FOR EACH ROW
  EXECUTE PROCEDURE event_disponibility_remove_assignment_from_event_functions();
----------------------------------------------------------------------------

commit;
