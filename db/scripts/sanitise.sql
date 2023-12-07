/* create temporary look up tables for foreign key identifiers (TRNs, URNs, UK PRNs) */

SELECT
    schools.urn as original_urn,
    RIGHT(CONCAT('000000', CAST(rows.index AS VARCHAR(6))), 6) as urn,
    RIGHT(CONCAT('00000000', CAST(rows.index AS VARCHAR(8))), 8) as uk_prn
INTO schools_ref
FROM schools
    LEFT OUTER JOIN (
        SELECT entry.id as id, row_number() over () as index
        FROM schools as entry
        ORDER BY entry.created_at
    ) AS rows ON schools.id = rows.id;

SELECT
    teacher_profiles.trn as original_trn,
    RIGHT(CONCAT('0000000', CAST(rows.index AS VARCHAR(7))), 7) as trn
INTO teacher_profiles_ref
FROM teacher_profiles
    LEFT OUTER JOIN (
        SELECT entry.id as id, row_number() over () as index
        FROM teacher_profiles as entry
        ORDER BY entry.created_at
    ) AS rows ON teacher_profiles.id = rows.id;

SELECT
    local_authority_districts.code as original_code,
    RIGHT(CONCAT('E09000000', CAST(rows.index AS VARCHAR(9))), 9) as code,
    CONCAT('Local Authority District ', local_authority_districts.id) as name
    INTO local_authority_districts_ref
FROM local_authority_districts
    LEFT OUTER JOIN (
        SELECT entry.id as id, row_number() over () as index
        FROM local_authority_districts as entry
        ORDER BY entry.created_at
    ) AS rows ON local_authority_districts.id = rows.id;

/* truncate or alter tables to remove PII */

TRUNCATE TABLE additional_school_emails;

/* KEEP admin_profiles INTACT */

TRUNCATE TABLE api_request_audits;
TRUNCATE TABLE api_requests;
TRUNCATE TABLE api_tokens;

UPDATE appropriate_bodies as item
    SET name=CONCAT('Appropriate Body ', id);

/* KEEP appropriate_body_profiles INTACT */

/* reset all call off contracts to default values */
UPDATE call_off_contracts
    SET raw='{"version":"1.0.0"}',
        uplift_target=1000,
        uplift_amount=1000,
        recruitment_target=1000,
        set_up_fee=100,
        revised_target=1111,
        monthly_service_fee=150;

/* KEEP cohorts INTACT */
/* KEEP cohorts_lead_providers INTACT */
/* KEEP completion_candidates INTACT */
/* KEEP core_induction_programmes INTACT */

/* sequentially rename CPD lead providers */
UPDATE cpd_lead_providers
    SET name=CONCAT('Lead Provider ', id);

/* cascades to data_stage_school_changes, data_stage_school_links */
TRUNCATE TABLE data_stage_schools CASCADE;

/* KEEP declaration_states INTACT */

TRUNCATE TABLE deleted_duplicates;

/* KEEP delivery_partner_profiles INTACT */

/* sequentially rename delivery partners */
UPDATE delivery_partners
    SET name=CONCAT('Delivery Partner ', id);

/* KEEP district_sparsities INTACT */
/* KEEP ecf_ineligible_participants INTACT */
/* KEEP ecf_participant_eligibilities INTACT */

TRUNCATE TABLE ecf_participant_validation_data;

/* cascades to email_associations */
TRUNCATE TABLE emails CASCADE;

/* KEEP event_logs INTACT */
/* KEEP feature_selected_objects INTACT */
/* KEEP features INTACT */

/* reset all payment adjustments to default values */
UPDATE finance_adjustments
    SET amount=1000;

TRUNCATE TABLE finance_profiles;

/* KEEP friendly_id_slugs INTACT */

/* KEEP induction_coordinator_profiles INTACT */
/* KEEP induction_coordinator_profiles_schools INTACT */
/* KEEP induction_programmes INTACT */
/* KEEP induction_records INTACT */
/* KEEP lead_provider_cips INTACT */
/* KEEP lead_provider_profiles INTACT */

/* rename ECF lead providers to match their CPD name */
UPDATE lead_providers AS lp
    SET name=clp.name
    FROM cpd_lead_providers AS clp
    WHERE lp.cpd_lead_provider_id = clp.id;

/* sequentially rename local authorities */
UPDATE local_authorities
    SET name=CONCAT('Local Authority ', id);

UPDATE local_authority_districts
    SET code=local_authority_districts_ref.code,
        name=local_authority_districts_ref.name
    FROM local_authority_districts_ref
    WHERE local_authority_districts.code = local_authority_districts_ref.original_code;

/* KEEP milestones INTACT */
/* KEEP networks INTACT */

TRUNCATE TABLE npq_application_eligibility_imports;
TRUNCATE TABLE npq_application_exports;

/* need to rewrite these IDs */
UPDATE npq_applications
    SET school_ukprn=schools_ref.uk_prn,
        school_urn=schools_ref.urn,
        teacher_reference_number=teacher_profiles_ref.trn,
        date_of_birth=NULL,
        nino=NULL
    FROM schools_ref, teacher_profiles_ref
    WHERE npq_applications.school_urn = schools_ref.original_urn
        AND npq_applications.teacher_reference_number = teacher_profiles_ref.original_trn;

/* reset all NPQ contracts to default values */
UPDATE npq_contracts
    SET per_participant=800,
        monthly_service_fee=NULL,
        targeted_delivery_funding_per_participant=100;

/* KEEP npq_courses INTACT */

/* rename NPQ lead providers to match their CPD name */
UPDATE npq_lead_providers AS lp
    SET name=clp.name
    FROM cpd_lead_providers AS clp
    WHERE lp.cpd_lead_provider_id = clp.id;

UPDATE participant_bands
    SET per_participant=800;

TRUNCATE TABLE participant_declaration_attempts;

/* KEEP participant_declarations INTACT */
/* KEEP participant_id_changes INTACT */

/* rename NPQ lead providers to match their CPD name */
UPDATE participant_identities as item
    SET email=CONCAT('participant-identity-', id, '@example.com');

TRUNCATE TABLE participant_outcome_api_requests;

/* KEEP participant_outcomes INTACT */
/* KEEP participant_profile_schedules INTACT */
/* KEEP participant_profile_states INTACT */

/* need to rewrite these IDs */
UPDATE participant_profiles
    SET school_ukprn=schools_ref.uk_prn,
        school_urn=schools_ref.urn,
        notes=''
    FROM schools_ref
    WHERE schools_ref.original_urn = participant_profiles.school_urn;

TRUNCATE TABLE partnership_csv_uploads;

/* cascades to nomination_emails */
TRUNCATE TABLE partnership_notification_emails CASCADE;

/* KEEP partnerships INTACT */
/* KEEP privacy_policies INTACT */
/* KEEP privacy_policy_acceptances INTACT */

TRUNCATE TABLE profile_validation_decisions;

/* KEEP provider_relationships INTACT */
/* KEEP pupil_premiums INTACT */
/* KEEP schedule_milestones INTACT */
/* KEEP schedules INTACT */
/* KEEP schema_migrations INTACT */
/* KEEP school_cohorts INTACT */

UPDATE school_links
    SET link_urn=schools_ref.urn
    FROM schools_ref
    WHERE schools_ref.original_urn = school_links.link_urn;

/* KEEP school_local_authorities INTACT */
/* KEEP school_local_authority_districts INTACT */
/* KEEP school_mentors INTACT */

UPDATE schools
    SET name=CONCAT('School ', id),
        urn=schools_ref.urn,
        address_line1=CONCAT(id, ' School Lane'),
        address_line2=CONCAT('School Town ', id),
        address_line3=CONCAT('School County ', id),
        postcode='AA01 AAA',
        domains=array[]::varchar[],
        ukprn=schools_ref.uk_prn,
        school_website=CONCAT('school-', id, '.school'),
        secondary_contact_email=CONCAT('school-', id, '-primary@example.com'),
        primary_contact_email=CONCAT('school-', id, '-secondary@example.com'),
        administrative_district_name=local_authority_districts_ref.name,
        administrative_district_code=local_authority_districts_ref.code,
        slug=CONCAT(schools_ref.urn, '-', CONCAT('school-', id))
    FROM schools_ref, local_authority_districts_ref
    WHERE schools_ref.original_urn = schools.urn
        AND local_authority_districts_ref.original_code = schools.administrative_district_code;

TRUNCATE TABLE sessions;

/* KEEP statement_line_items INTACT */

UPDATE statements
    SET original_value=0,
        reconcile_amount=0;

TRUNCATE TABLE sync_dqt_induction_start_date_errors;

UPDATE teacher_profiles
    SET trn=teacher_profiles_ref.trn
    FROM teacher_profiles_ref
    WHERE teacher_profiles_ref.original_trn = teacher_profiles.trn;

UPDATE users as item
    SET full_name=CONCAT('User ', id),
        email=CONCAT('user-', id, '@example.com'),
        current_sign_in_ip='127.0.0.1',
        last_sign_in_ip='127.0.0.1',
        get_an_identity_id=gen_random_uuid();

TRUNCATE TABLE versions;

DROP TABLE schools_ref;
DROP TABLE teacher_profiles_ref;
