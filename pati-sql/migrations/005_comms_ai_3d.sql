begin;

create table pati.consent_record (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  subject_user_id bigint not null references pati.app_user(id) on delete restrict,
  channel text not null check (channel in ('email','sms','push','whatsapp','phone','ai_health','ai_training','location','insurance_referral')),
  purpose text not null,
  status text not null check (status in ('granted','denied','withdrawn','expired')),
  policy_version text not null,
  source text not null check (source in ('app','web','call','provider','admin','import')),
  proof jsonb not null default '{}',
  granted_at timestamptz,
  withdrawn_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create table pati.communication_log (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  user_id bigint references pati.app_user(id) on delete restrict,
  business_id bigint references pati.business(id) on delete restrict,
  consent_record_id bigint references pati.consent_record(id) on delete restrict,
  channel text not null check (channel in ('email','sms','push','whatsapp','phone')),
  purpose text not null,
  provider_message_id text,
  template_key text,
  status text not null check (status in ('queued','sent','delivered','failed','cancelled','answered','no_answer')),
  metadata jsonb not null default '{}',
  sent_at timestamptz,
  delivered_at timestamptz,
  created_at timestamptz not null default now(),
  check (user_id is not null or business_id is not null)
);

create table pati.notification (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  user_id bigint not null references pati.app_user(id) on delete cascade,
  event_type text not null,
  title text not null,
  body text not null,
  action_url text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table pati.ai_job (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  user_id bigint not null references pati.app_user(id) on delete restrict,
  pet_id bigint references pati.pet(id) on delete restrict,
  consent_record_id bigint references pati.consent_record(id) on delete restrict,
  job_type text not null check (job_type in ('health_assessment','image_quality','segmentation','3d_reconstruction','texture','rigging','mascot','recommendation')),
  status text not null check (status in ('queued','running','review_required','completed','failed','cancelled')),
  model_name text not null,
  model_version text not null,
  policy_version text not null,
  input_object_key text,
  output_object_key text,
  input_hash char(64),
  error_code text,
  started_at timestamptz,
  completed_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create table pati.ai_health_assessment (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  ai_job_id bigint not null unique references pati.ai_job(id) on delete restrict,
  pet_id bigint not null references pati.pet(id) on delete restrict,
  symptoms_ciphertext bytea not null,
  risk_level text not null check (risk_level in ('low','medium','high','emergency','unknown')),
  result_ciphertext bytea not null,
  cited_source_ids text[] not null default '{}',
  human_review_status text not null default 'not_required' check (human_review_status in ('not_required','pending','approved','corrected','rejected')),
  reviewed_by bigint references pati.app_user(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table pati.pet_3d_asset (
  id bigint generated always as identity primary key,
  public_id uuid not null default gen_random_uuid() unique,
  pet_id bigint not null references pati.pet(id) on delete restrict,
  ai_job_id bigint not null references pati.ai_job(id) on delete restrict,
  version integer not null check (version > 0),
  status text not null check (status in ('draft','review','approved','rejected','archived')),
  style text not null check (style in ('realistic','soft_3d','game','mascot')),
  master_object_key text not null,
  lod_manifest jsonb not null,
  rig_manifest jsonb,
  quality_metrics jsonb not null,
  provenance jsonb not null,
  approved_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  unique (pet_id, version)
);

commit;

