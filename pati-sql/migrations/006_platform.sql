begin;

create table pati.idempotency_record (
  id bigint generated always as identity primary key,
  scope text not null,
  idempotency_key text not null,
  actor_user_id bigint references pati.app_user(id) on delete restrict,
  request_hash char(64) not null,
  response_status integer,
  response_body jsonb,
  resource_type text,
  resource_public_id uuid,
  locked_until timestamptz,
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  unique (scope, idempotency_key)
);

create table pati.outbox_event (
  id bigint generated always as identity primary key,
  event_id uuid not null default gen_random_uuid() unique,
  aggregate_type text not null,
  aggregate_id bigint not null,
  event_type text not null,
  schema_version integer not null check (schema_version > 0),
  correlation_id uuid,
  causation_id uuid,
  payload jsonb not null,
  occurred_at timestamptz not null default now(),
  published_at timestamptz,
  attempt_count integer not null default 0 check (attempt_count >= 0),
  next_attempt_at timestamptz not null default now(),
  last_error text
);

create table pati.audit_event (
  id bigint generated always as identity primary key,
  event_id uuid not null default gen_random_uuid() unique,
  actor_user_id bigint references pati.app_user(id) on delete set null,
  actor_role text,
  action text not null,
  resource_type text not null,
  resource_public_id uuid,
  request_id uuid,
  ip_hash bytea,
  user_agent_hash bytea,
  before_state jsonb,
  after_state jsonb,
  reason text,
  created_at timestamptz not null default now()
);

-- Foreign-key lookup indexes. PostgreSQL does not create these automatically.
create index district_city_id_idx on pati.district(city_id);
create index breed_species_id_idx on pati.breed(species_id);
create index service_category_parent_id_idx on pati.service_category(parent_id);
create index user_role_granted_by_idx on pati.user_role(granted_by);
create index address_user_id_idx on pati.address(user_id);
create index address_city_district_idx on pati.address(city_id, district_id);
create index pet_owner_user_id_idx on pati.pet(owner_user_id) where deleted_at is null;
create index pet_species_breed_idx on pati.pet(species_id, breed_id) where deleted_at is null;
create index pet_caregiver_user_id_idx on pati.pet_caregiver(user_id) where revoked_at is null;
create index pet_health_record_pet_occurred_idx on pati.pet_health_record(pet_id, occurred_at desc);
create index pet_health_record_author_idx on pati.pet_health_record(author_user_id);
create index pet_health_record_business_idx on pati.pet_health_record(provider_business_id) where provider_business_id is not null;
create index business_owner_idx on pati.business(owner_user_id) where deleted_at is null;
create index business_geo_status_idx on pati.business(status, city_id, district_id) where deleted_at is null;
create index business_member_user_idx on pati.business_member(user_id) where status = 'active';
create index provider_document_business_status_idx on pati.provider_document(business_id, status, expires_at);
create index service_business_active_idx on pati.service(business_id, is_active);
create index service_category_price_idx on pati.service(category_id, min_price) where is_active;
create index provider_resource_business_idx on pati.provider_resource(business_id) where is_active;
create index provider_resource_member_idx on pati.provider_resource(member_user_id) where member_user_id is not null;
create index service_resource_resource_idx on pati.service_resource(resource_id);
create index availability_rule_service_idx on pati.availability_rule(service_id, weekday, valid_from);
create index availability_rule_resource_idx on pati.availability_rule(resource_id) where resource_id is not null;
create index availability_exception_service_time_idx on pati.availability_exception(service_id, starts_at, ends_at);
create index availability_exception_resource_time_idx on pati.availability_exception(resource_id, starts_at, ends_at) where resource_id is not null;
create index quote_owner_created_idx on pati.quote(owner_user_id, created_at desc);
create index quote_service_time_idx on pati.quote(service_id, starts_at, ends_at);
create index reservation_owner_status_time_idx on pati.reservation(owner_user_id, status, starts_at desc);
create index reservation_business_status_time_idx on pati.reservation(business_id, status, starts_at);
create index reservation_pet_time_idx on pati.reservation(pet_id, starts_at desc);
create index reservation_service_time_idx on pati.reservation(service_id, starts_at);
create index reservation_resource_resource_idx on pati.reservation_resource(resource_id, starts_at);
create index reservation_history_reservation_idx on pati.reservation_status_history(reservation_id, created_at);
create index reservation_history_actor_idx on pati.reservation_status_history(actor_user_id) where actor_user_id is not null;
create index payment_reservation_idx on pati.payment(reservation_id, created_at desc);
create index payment_status_created_idx on pati.payment(status, created_at) where status in ('created','authorized','failed','disputed');
create index ledger_payment_idx on pati.ledger_entry(payment_id);
create index ledger_reservation_idx on pati.ledger_entry(reservation_id);
create index ledger_group_idx on pati.ledger_entry(entry_group);
create index ledger_account_created_idx on pati.ledger_entry(account, created_at);
create index payout_account_business_idx on pati.payout_account(business_id, status);
create index payout_business_status_idx on pati.payout(business_id, status, scheduled_for);
create index review_business_published_idx on pati.review(business_id, published_at desc) where moderation_status = 'published';
create index review_author_idx on pati.review(author_user_id);
create index dispute_reservation_idx on pati.dispute(reservation_id);
create index dispute_queue_idx on pati.dispute(status, due_at) where status not in ('resolved','rejected');
create index dispute_assignee_idx on pati.dispute(assigned_to_user_id, status) where assigned_to_user_id is not null;
create index dispute_evidence_dispute_idx on pati.dispute_evidence(dispute_id, created_at);
create index dispute_evidence_submitter_idx on pati.dispute_evidence(submitted_by_user_id);
create index consent_user_channel_purpose_idx on pati.consent_record(subject_user_id, channel, purpose, created_at desc);
create index communication_user_created_idx on pati.communication_log(user_id, created_at desc) where user_id is not null;
create index communication_business_created_idx on pati.communication_log(business_id, created_at desc) where business_id is not null;
create index communication_consent_idx on pati.communication_log(consent_record_id) where consent_record_id is not null;
create index notification_user_unread_idx on pati.notification(user_id, created_at desc) where read_at is null;
create index ai_job_user_created_idx on pati.ai_job(user_id, created_at desc);
create index ai_job_pet_created_idx on pati.ai_job(pet_id, created_at desc) where pet_id is not null;
create index ai_job_queue_idx on pati.ai_job(status, job_type, created_at) where status in ('queued','running','review_required');
create index ai_job_consent_idx on pati.ai_job(consent_record_id) where consent_record_id is not null;
create index ai_health_pet_created_idx on pati.ai_health_assessment(pet_id, created_at desc);
create index ai_health_reviewer_idx on pati.ai_health_assessment(reviewed_by) where reviewed_by is not null;
create index pet_3d_asset_pet_approved_idx on pati.pet_3d_asset(pet_id, version desc) where status = 'approved' and deleted_at is null;
create index pet_3d_asset_job_idx on pati.pet_3d_asset(ai_job_id);
create index idempotency_expiry_idx on pati.idempotency_record(expires_at);
create index idempotency_actor_idx on pati.idempotency_record(actor_user_id) where actor_user_id is not null;
create index outbox_pending_idx on pati.outbox_event(next_attempt_at, id) where published_at is null;
create index audit_resource_idx on pati.audit_event(resource_type, resource_public_id, created_at desc);
create index audit_actor_idx on pati.audit_event(actor_user_id, created_at desc) where actor_user_id is not null;

create or replace function pati.prevent_mutation()
returns trigger language plpgsql set search_path = '' as $$
begin
  raise exception '% is append-only', tg_table_name using errcode = '55000';
end;
$$;

create trigger ledger_entry_append_only before update or delete on pati.ledger_entry
for each row execute function pati.prevent_mutation();
create trigger audit_event_append_only before update or delete on pati.audit_event
for each row execute function pati.prevent_mutation();
create trigger reservation_history_append_only before update or delete on pati.reservation_status_history
for each row execute function pati.prevent_mutation();

commit;

