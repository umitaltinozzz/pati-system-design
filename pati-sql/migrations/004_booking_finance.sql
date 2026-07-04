begin;

create table pati.quote (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  owner_user_id bigint not null references pati.app_user(id) on delete restrict,
  pet_id bigint not null references pati.pet(id) on delete restrict,
  service_id bigint not null references pati.service(id) on delete restrict,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  subtotal numeric(14,2) not null check (subtotal >= 0),
  discount numeric(14,2) not null default 0 check (discount >= 0),
  tax numeric(14,2) not null default 0 check (tax >= 0),
  total numeric(14,2) not null check (total >= 0),
  currency char(3) not null default 'TRY',
  price_breakdown jsonb not null,
  policy_version integer not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  check (ends_at > starts_at),
  check (total = subtotal - discount + tax),
  check (expires_at > created_at)
);

create table pati.reservation (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  quote_id bigint not null unique references pati.quote(id) on delete restrict,
  owner_user_id bigint not null references pati.app_user(id) on delete restrict,
  pet_id bigint not null references pati.pet(id) on delete restrict,
  business_id bigint not null references pati.business(id) on delete restrict,
  service_id bigint not null references pati.service(id) on delete restrict,
  address_id bigint references pati.address(id) on delete restrict,
  status text not null check (status in ('created','payment_pending','provider_pending','accepted','rejected','cancelled','service_started','provider_completed','user_confirmation','disputed','completed','expired')),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  total_amount numeric(14,2) not null check (total_amount >= 0),
  currency char(3) not null default 'TRY',
  notes_ciphertext bytea,
  accepted_at timestamptz,
  service_started_at timestamptz,
  provider_completed_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  cancellation_reason text,
  version integer not null default 1 check (version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table pati.reservation_resource (
  reservation_id bigint not null references pati.reservation(id) on delete cascade,
  resource_id bigint not null references pati.provider_resource(id) on delete restrict,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  primary key (reservation_id, resource_id),
  check (ends_at > starts_at),
  exclude using gist (resource_id with =, tstzrange(starts_at, ends_at, '[)') with &&)
    where (resource_id is not null)
);

create table pati.reservation_status_history (
  id bigint generated always as identity primary key,
  reservation_id bigint not null references pati.reservation(id) on delete restrict,
  from_status text,
  to_status text not null,
  actor_user_id bigint references pati.app_user(id) on delete set null,
  reason_code text,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create table pati.payment (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  reservation_id bigint not null references pati.reservation(id) on delete restrict,
  provider text not null,
  provider_payment_id text,
  status text not null check (status in ('created','authorized','captured','partially_refunded','refunded','voided','failed','disputed')),
  authorized_amount numeric(14,2) not null default 0 check (authorized_amount >= 0),
  captured_amount numeric(14,2) not null default 0 check (captured_amount >= 0),
  refunded_amount numeric(14,2) not null default 0 check (refunded_amount >= 0),
  currency char(3) not null default 'TRY',
  failure_code text,
  authorized_at timestamptz,
  captured_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_payment_id),
  check (captured_amount <= authorized_amount),
  check (refunded_amount <= captured_amount)
);

create table pati.ledger_entry (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  payment_id bigint not null references pati.payment(id) on delete restrict,
  reservation_id bigint not null references pati.reservation(id) on delete restrict,
  entry_group uuid not null,
  account text not null check (account in ('customer_receivable','provider_payable','platform_revenue','tax_payable','payment_clearing','refund_payable')),
  direction text not null check (direction in ('debit','credit')),
  amount numeric(14,2) not null check (amount > 0),
  currency char(3) not null default 'TRY',
  event_type text not null,
  reverses_entry_id bigint references pati.ledger_entry(id) on delete restrict,
  created_at timestamptz not null default now()
);

create table pati.payout_account (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  business_id bigint not null references pati.business(id) on delete restrict,
  iban_hash bytea not null,
  iban_ciphertext bytea not null,
  account_holder_ciphertext bytea not null,
  status text not null check (status in ('pending','active','cooldown','suspended','rejected')),
  verified_at timestamptz,
  cooldown_until timestamptz,
  created_at timestamptz not null default now(),
  unique (business_id, iban_hash)
);

create table pati.payout (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  business_id bigint not null references pati.business(id) on delete restrict,
  payout_account_id bigint not null references pati.payout_account(id) on delete restrict,
  provider_payout_id text,
  status text not null check (status in ('pending','processing','paid','failed','cancelled')),
  gross_amount numeric(14,2) not null check (gross_amount >= 0),
  deduction_amount numeric(14,2) not null default 0 check (deduction_amount >= 0),
  net_amount numeric(14,2) not null check (net_amount >= 0),
  currency char(3) not null default 'TRY',
  scheduled_for timestamptz not null,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  check (net_amount = gross_amount - deduction_amount)
);

create table pati.review (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  reservation_id bigint not null unique references pati.reservation(id) on delete restrict,
  author_user_id bigint not null references pati.app_user(id) on delete restrict,
  business_id bigint not null references pati.business(id) on delete restrict,
  rating smallint not null check (rating between 1 and 5),
  comment text,
  moderation_status text not null default 'pending' check (moderation_status in ('pending','published','hidden','rejected')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table pati.dispute (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  reservation_id bigint not null references pati.reservation(id) on delete restrict,
  opened_by_user_id bigint not null references pati.app_user(id) on delete restrict,
  assigned_to_user_id bigint references pati.app_user(id) on delete set null,
  reason_code text not null,
  status text not null check (status in ('open','awaiting_user','awaiting_provider','under_review','resolved','rejected','appealed')),
  resolution text check (resolution in ('full_refund','partial_refund','provider_payout','no_action','account_action')),
  resolution_note text,
  due_at timestamptz not null,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table pati.dispute_evidence (
  id bigint generated always as identity primary key,
  dispute_id bigint not null references pati.dispute(id) on delete restrict,
  submitted_by_user_id bigint not null references pati.app_user(id) on delete restrict,
  evidence_type text not null check (evidence_type in ('text','image','document','location','message_snapshot','service_event')),
  object_key text,
  payload_ciphertext bytea,
  checksum_sha256 char(64),
  created_at timestamptz not null default now(),
  check (object_key is not null or payload_ciphertext is not null)
);

create trigger reservation_updated_at before update on pati.reservation for each row execute function pati.set_updated_at();
create trigger payment_updated_at before update on pati.payment for each row execute function pati.set_updated_at();
create trigger review_updated_at before update on pati.review for each row execute function pati.set_updated_at();
create trigger dispute_updated_at before update on pati.dispute for each row execute function pati.set_updated_at();

commit;
