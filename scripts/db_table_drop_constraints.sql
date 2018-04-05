drop trigger if exists event_disponibility_remove_functions_when_unavailable on event_disponibility;
drop function if exists event_disponibility_remove_assignment_from_event_functions;


drop trigger if exists event_function_check_person_disponibility_trigger on event_function;
drop function if exists event_function_check_person_disponibility;

alter table event_function
  alter column event_id drop not null,
  alter column skill_id drop not null,
  drop constraint event_function_event_fk cascade,
  drop constraint event_function_person_fk cascade,
  drop constraint event_function_skill_fk cascade;

alter table event_disponibility
  alter column event_id drop not null,
  alter column person_id drop not null,
  alter column disponibility_id drop not null,
  drop constraint event_disponibility_unique_event_person_pair cascade,
  drop constraint event_disponibility_event_fk cascade,
  drop constraint event_disponibility_person_fk cascade,
  drop constraint event_disponibility_disponibility_fk cascade;

alter table event_extern_person
  alter column event_id drop not null,
  alter column person_id drop not null,
  drop constraint event_extern_person_event_fk cascade,
  drop constraint event_extern_person_type_fk cascade;

alter table event_sport_type
  alter column event_id drop not null,
  alter column sport_type_id drop not null,
  drop constraint event_sport_type_event_fk cascade,
  drop constraint event_sport_type_sport_type_fk cascade;

drop trigger if exists event_procedure_deletion_trigger on event_procedure;
drop function if exists delete_related_event_procedures;

alter table event_procedure
  alter column event_id drop not null,
  alter column procedure_id drop not null,
  drop constraint event_procedure_event_fk cascade,
  drop constraint event_procedure_procedure_fk cascade;

drop index event_geom_index;

alter table event
  drop constraint event_id_pk cascade,
  alter column event_name drop not null,
  alter column event_charge drop not null,
  alter column event_ppv_charge drop not null,
  alter column event_live drop not null,
  alter column event_fsk_check drop not null,
  drop constraint event_organizer_person_fk cascade,
  alter column event_is_active drop not null;

alter table person_skills
  alter column person_id drop not null,
  alter column skill_id drop not null,
  drop constraint person_skills_person_fk cascade,
  drop constraint person_skills_skill_fk cascade;

drop index person_geom_index;

alter table person
  drop constraint person_id_pk cascade,
  alter column person_name drop not null,
  alter column person_is_worker drop not null;


alter table skill
  drop constraint skill_id_pk cascade,
  alter column skill_name drop not null;

alter table procedure
  drop constraint procedure_id_pk cascade,
  alter column procedure_timestamp drop not null,
  alter column procedure_info drop not null;

alter table sport_type
  drop constraint sport_type_id_pk cascade,
  alter column sport_type_name drop not null;

alter table users
  drop constraint user_username_pk cascade,
  alter column user_password drop not null;
