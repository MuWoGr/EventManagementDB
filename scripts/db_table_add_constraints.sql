begin;

alter table users
  add constraint user_username_pk primary key(user_username),
  alter column user_password set not null;

alter table sport_type
  add constraint sport_type_id_pk primary key(sport_type_id),
  alter column sport_type_name set not null;

alter table procedure
  add constraint procedure_id_pk primary key(procedure_id),
  alter column procedure_timestamp set not null,
  alter column procedure_info set not null;

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
  alter column person_id set not null,
  alter column skill_id set not null,
  add constraint person_skills_person_fk
    foreign key (person_id)
    references person(person_id),
  add constraint person_skills_skill_fk
    foreign key (skill_id)
    references skill(skill_id);

alter table event
  add constraint event_id_pk primary key (event_id),
  alter column event_name set not null,
  alter column event_charge set not null,
  alter column event_ppv_charge set not null,
  alter column event_live set not null,
  alter column event_fsk_check set not null,
  add constraint event_organizer_person_fk
    foreign key (event_organizer)
    references person(person_id),
  alter column event_is_active set not null;

--spation index on the location
create index event_geom_index
  on event using gist(event_location_geo);


alter table event_procedure
  alter column event_id set not null,
  alter column procedure_id set not null,
  add constraint event_procedure_event_fk
    foreign key (event_id)
    references event(event_id),
  add constraint event_procedure_procedure_fk
    foreign key (procedure_id)
    references procedure(procedure_id);

alter table event_sport_type
  alter column event_id set not null,
  alter column sport_type_id set not null,
  add constraint event_sport_type_event_fk
    foreign key (event_id)
    references event(event_id),
  add constraint event_sport_type_sport_type_fk
    foreign key (sport_type_id)
    references sport_type(sport_type_id);

alter table event_extern_person
  alter column event_id set not null,
  alter column person_id set not null,
  add constraint event_extern_person_event_fk
    foreign key (event_id)
    references event(event_id),
  add constraint event_extern_person_type_fk
    foreign key (person_id)
    references person(person_id);

alter table event_disponibility
  alter column event_id set not null,
  alter column person_id set not null,
  alter column disponibility_id set not null,
  add constraint event_disponibility_event_fk
    foreign key (event_id)
    references event(event_id),
  add constraint event_disponibility_person_fk
    foreign key (person_id)
    references person(person_id),
  add constraint event_disponibility_disponibility_fk
    foreign key (disponibility_id)
    references disponibility(disponibility_id);

alter table event_function
  alter column event_id set not null,
  alter column person_id set not null,
  alter column skill_id set not null,
  add constraint event_function_event_fk
    foreign key (event_id)
    references event(event_id),
  add constraint event_function_person_fk
    foreign key (person_id)
    references person(person_id),
  add constraint event_function_skill_fk
    foreign key (skill_id)
    references skill(skill_id);


commit;
