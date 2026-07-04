begin;

create table pati.app_user (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  email_hash bytea unique,
  email_ciphertext bytea,
  phone_hash bytea unique,
  phone_ciphertext bytea,
  display_name text not null,
  status text not null default 'active' check (status in ('pending','active','locked','suspended','deletion_pending','anonymized')),
  locale text not null default 'tr-TR',
  timezone text not null default 'Europe/Istanbul',
  email_verified_at timestamptz,
  phone_verified_at timestamptz,
  last_login_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (email_ciphertext is not null or phone_ciphertext is not null)
);

create table pati.user_role (
  user_id bigint not null references pati.app_user(id) on delete cascade,
  role text not null check (role in ('pet_owner','provider','operator','admin','super_admin','support','finance','veterinarian')),
  granted_by bigint references pati.app_user(id) on delete set null,
  granted_at timestamptz not null default now(),
  revoked_at timestamptz,
  primary key (user_id, role),
  check (revoked_at is null or revoked_at >= granted_at)
);

create table pati.address (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  user_id bigint not null references pati.app_user(id) on delete cascade,
  city_id bigint not null references pati.city(id) on delete restrict,
  district_id bigint references pati.district(id) on delete restrict,
  label text not null,
  address_ciphertext bytea not null,
  latitude numeric(9,6),
  longitude numeric(9,6),
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (latitude is null or latitude between -90 and 90),
  check (longitude is null or longitude between -180 and 180)
);

create unique index address_one_default_per_user_idx on pati.address(user_id) where is_default;

create table pati.pet (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  owner_user_id bigint not null references pati.app_user(id) on delete restrict,
  species_id smallint not null references pati.species(id) on delete restrict,
  breed_id bigint references pati.breed(id) on delete restrict,
  name text not null,
  sex text check (sex in ('female','male','unknown')),
  birth_date date,
  weight_kg numeric(6,2) check (weight_kg > 0 and weight_kg <= 500),
  microchip_hash bytea unique,
  avatar_object_key text,
  status text not null default 'active' check (status in ('active','missing','deceased','archived')),
  allergies_ciphertext bytea,
  medications_ciphertext bytea,
  behavior_notes_ciphertext bytea,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table pati.pet_caregiver (
  pet_id bigint not null references pati.pet(id) on delete cascade,
  user_id bigint not null references pati.app_user(id) on delete cascade,
  permission_scope text[] not null default '{}',
  invited_by bigint not null references pati.app_user(id) on delete restrict,
  accepted_at timestamptz,
  expires_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (pet_id, user_id),
  check (expires_at is null or expires_at > created_at)
);

create table pati.pet_health_record (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  pet_id bigint not null references pati.pet(id) on delete restrict,
  author_user_id bigint not null references pati.app_user(id) on delete restrict,
  provider_business_id bigint,
  record_type text not null check (record_type in ('vaccination','examination','laboratory','prescription','allergy','medication','weight','procedure','note')),
  occurred_at timestamptz not null,
  title text not null,
  payload_ciphertext bytea not null,
  document_object_key text,
  supersedes_record_id bigint references pati.pet_health_record(id) on delete restrict,
  created_at timestamptz not null default now(),
  check (supersedes_record_id is null or supersedes_record_id <> id)
);

create trigger app_user_updated_at before update on pati.app_user for each row execute function pati.set_updated_at();
create trigger address_updated_at before update on pati.address for each row execute function pati.set_updated_at();
create trigger pet_updated_at before update on pati.pet for each row execute function pati.set_updated_at();

commit;
