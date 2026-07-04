begin;

create table pati.business (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  owner_user_id bigint not null references pati.app_user(id) on delete restrict,
  legal_name text not null,
  display_name text not null,
  tax_number_hash bytea unique,
  phone_hash bytea,
  phone_ciphertext bytea,
  email_ciphertext bytea,
  city_id bigint not null references pati.city(id) on delete restrict,
  district_id bigint references pati.district(id) on delete restrict,
  address_ciphertext bytea not null,
  latitude numeric(9,6) not null check (latitude between -90 and 90),
  longitude numeric(9,6) not null check (longitude between -180 and 180),
  status text not null default 'candidate' check (status in ('candidate','pending_review','active','passive','suspended','rejected')),
  verification_status text not null default 'unverified' check (verification_status in ('unverified','documents_pending','call_pending','review_pending','verified','expired','rejected')),
  rating_average numeric(3,2) not null default 0 check (rating_average between 0 and 5),
  review_count integer not null default 0 check (review_count >= 0),
  description text,
  verified_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table pati.business_member (
  business_id bigint not null references pati.business(id) on delete cascade,
  user_id bigint not null references pati.app_user(id) on delete cascade,
  role text not null check (role in ('owner','manager','staff','veterinarian','walker','driver','groomer','trainer')),
  status text not null default 'invited' check (status in ('invited','active','suspended','revoked')),
  created_at timestamptz not null default now(),
  primary key (business_id, user_id)
);

create table pati.provider_document (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  business_id bigint not null references pati.business(id) on delete cascade,
  document_type text not null,
  object_key text not null,
  checksum_sha256 char(64) not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected','expired')),
  issued_at date,
  expires_at date,
  reviewed_by bigint references pati.app_user(id) on delete set null,
  reviewed_at timestamptz,
  rejection_reason text,
  created_at timestamptz not null default now(),
  check (expires_at is null or issued_at is null or expires_at >= issued_at)
);

create table pati.service (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  business_id bigint not null references pati.business(id) on delete cascade,
  category_id bigint not null references pati.service_category(id) on delete restrict,
  name text not null,
  description text,
  duration_minutes integer check (duration_minutes between 5 and 10080),
  min_price numeric(14,2) not null check (min_price >= 0),
  max_price numeric(14,2) not null check (max_price >= min_price),
  currency char(3) not null default 'TRY',
  service_area_km numeric(6,2) check (service_area_km >= 0),
  capacity integer not null default 1 check (capacity > 0),
  cancellation_policy jsonb not null default '{}',
  eligibility_rules jsonb not null default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, name)
);

create table pati.provider_resource (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  business_id bigint not null references pati.business(id) on delete cascade,
  member_user_id bigint references pati.app_user(id) on delete restrict,
  resource_type text not null check (resource_type in ('staff','room','cage','station','vehicle')),
  name text not null,
  capacity integer not null default 1 check (capacity > 0),
  attributes jsonb not null default '{}',
  is_active boolean not null default true
);

create table pati.service_resource (
  service_id bigint not null references pati.service(id) on delete cascade,
  resource_id bigint not null references pati.provider_resource(id) on delete cascade,
  quantity integer not null default 1 check (quantity > 0),
  primary key (service_id, resource_id)
);

create table pati.availability_rule (
  id bigint generated always as identity primary key,
  service_id bigint not null references pati.service(id) on delete cascade,
  resource_id bigint references pati.provider_resource(id) on delete cascade,
  weekday smallint not null check (weekday between 0 and 6),
  local_start time not null,
  local_end time not null,
  valid_from date not null,
  valid_until date,
  slot_minutes integer not null check (slot_minutes between 5 and 1440),
  check (local_end > local_start),
  check (valid_until is null or valid_until >= valid_from)
);

create table pati.availability_exception (
  id bigint generated always as identity primary key,
  service_id bigint not null references pati.service(id) on delete cascade,
  resource_id bigint references pati.provider_resource(id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  exception_type text not null check (exception_type in ('blocked','extra_capacity','maintenance','leave')),
  capacity_delta integer not null default 0,
  reason text,
  check (ends_at > starts_at)
);

alter table pati.pet_health_record
  add constraint pet_health_record_provider_business_fk
  foreign key (provider_business_id) references pati.business(id) on delete restrict;

create trigger business_updated_at before update on pati.business for each row execute function pati.set_updated_at();
create trigger service_updated_at before update on pati.service for each row execute function pati.set_updated_at();

commit;

