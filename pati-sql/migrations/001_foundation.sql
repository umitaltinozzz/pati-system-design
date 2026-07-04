begin;

create extension if not exists pgcrypto;
create extension if not exists btree_gist;

create schema if not exists pati;
revoke all on schema pati from public;

create or replace function pati.set_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = clock_timestamp();
  return new;
end;
$$;

create table pati.city (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  country_code char(2) not null default 'TR',
  name text not null,
  slug text not null,
  timezone text not null default 'Europe/Istanbul',
  is_active boolean not null default true,
  unique (country_code, slug)
);

create table pati.district (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  city_id bigint not null references pati.city(id) on delete restrict,
  name text not null,
  slug text not null,
  is_active boolean not null default true,
  unique (city_id, slug)
);

create table pati.species (
  id smallint generated always as identity primary key,
  code text not null unique,
  name_tr text not null,
  is_active boolean not null default true
);

create table pati.breed (
  id bigint generated always as identity primary key,
  species_id smallint not null references pati.species(id) on delete restrict,
  code text not null,
  name_tr text not null,
  is_active boolean not null default true,
  unique (species_id, code)
);

create table pati.service_category (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  parent_id bigint references pati.service_category(id) on delete restrict,
  code text not null unique,
  name_tr text not null,
  slug text not null unique,
  schema_version integer not null default 1 check (schema_version > 0),
  booking_mode text not null check (booking_mode in ('slot','date_range','dispatch','request','referral')),
  requires_provider_verification boolean not null default true,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger service_category_updated_at
before update on pati.service_category
for each row execute function pati.set_updated_at();

commit;
