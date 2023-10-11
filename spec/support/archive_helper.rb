# frozen_string_literal: true

module ArchiveHelper
  def build_archived_ect(name: Faker::Name.name, id: SecureRandom.uuid, alt_id: SecureRandom.uuid, profile_id: SecureRandom.uuid,
                         trn: "00#{Faker::Number.unique.rand_in_range(10_000, 99_999)}")
    email = "#{name.parameterize}@example.com"
    email2 = "#{name.parameterize}9@gmail.com"
    ext_id = id
    ext_id2 = alt_id

    Archive::Relic.create!(object_type: "User",
                           object_id: id,
                           display_name: name,
                           reason: "unvalidated/undeclared ECTs 2021 or 2022",
                           data: {
                             "id" => id,
                             "meta" => {
                               "id" => id,
                               "trn" => trn,
                               "email" => email,
                               "roles" => %w[early_career_teacher teacher],
                               "full_name" => name,
                               "profiles" => [profile_id],
                               "identities" => [[ext_id, email], [ext_id2, email2]],
                             },
                             "type" => "user",
                             "attributes" => {
                               "email" => email,
                               "full_name" => name,
                               "teacher_profile" => {
                                 "id" => "486429d1-b6ba-4313-8628-cd86670f3d92",
                                 "type" => "teacher_profile",
                                 "attributes" => {
                                   "trn" => trn,
                                   "school_id" => "153ad0f7-cc8d-4b68-942f-f21a021ad0bf",
                                 },
                               },
                               "npq_applications" => [],
                               "induction_records" => [
                                 {
                                   "id" => SecureRandom.uuid,
                                   "type" => "induction_record",
                                   "attributes" => {
                                     "cohort" =>2022,
                                     "end_date" =>nil,
                                     "schedule" => "ECF Standard September",
                                     "created_at" => "2023-09-19T13:54:34.188Z",
                                     "school_urn" => "000017",
                                     "start_date" => "2023-03-19T13:54:34.184Z",
                                     "schedule_id" => "6e349482-9c8d-42cd-9d2b-edb46e1b9e31",
                                     "school_name" => "Cohortless School 22-23-FIP",
                                     "lead_provider" => "Rutherford-Veum",
                                     "core_materials" =>nil,
                                     "school_transfer" =>false,
                                     "training_status" => "active",
                                     "appropriate_body" =>nil,
                                     "delivery_partner" => "Bahringer Inc",
                                     "induction_status" => "active",
                                     "mentor_profile_id" =>nil,
                                     "training_programme" => "full_induction_programme",
                                     "appropriate_body_id" =>nil,
                                     "preferred_identity_id" => "abfb5d40-0cea-44f8-9ffb-29a7e158b16e",
                                     "induction_programme_id" => "e191df00-89a5-47af-b6d3-6423fd7f08c2",
                                     "participant_profile_id" => profile_id,
                                   },
                                 },
                               ],
                               "participant_profiles" => [
                                 {
                                   "id" => profile_id,
                                   "meta" => {
                                     "id" => id,
                                     "trn" => trn,
                                     "email" => email,
                                     "roles" => %w[early_career_teacher teacher],
                                     "full_name" => name,
                                     "profiles" => [profile_id],
                                     "identities" => [[ext_id, email], [ext_id2, email2]],
                                   },
                                   "type" => "participant_profile",
                                   "attributes" => {
                                     "type" => "ParticipantProfile::ECT",
                                     "notes" =>nil,
                                     "status" => "active",
                                     "created_at" => "2023-04-02T15:27:40.876Z",
                                     "schedule_id" => "6e349482-9c8d-42cd-9d2b-edb46e1b9e31",
                                     "sparsity_uplift" =>false,
                                     "training_status" => "active",
                                     "school_cohort_id" => "03a82616-20d5-46a4-b4e2-8506a1249357",
                                     "profile_duplicity" => "single",
                                     "teacher_profile_id" => "486429d1-b6ba-4313-8628-cd86670f3d92",
                                     "induction_record_ids" => [{ "id" => "6f7cf212-71a2-4691-9e5d-34122c63eb8e" }],
                                     "induction_start_date" => "2022-10-01",
                                     "pupil_premium_uplift" =>false,
                                     "participant_identity_id" => "abfb5d40-0cea-44f8-9ffb-29a7e158b16e",
                                     "induction_completion_date" =>nil,
                                   },
                                 },
                               ],
                               "participant_identities" => [
                                 {
                                   "id" => "abfb5d40-0cea-44f8-9ffb-29a7e158b16e",
                                   "type" => "participant_identity",
                                   "attributes" => {
                                     "email" => email,
                                     "origin" => "ecf",
                                     "created_at" => "2023-09-19T13:54:34.174Z",
                                     "external_identifier" => ext_id,
                                     "participant_profiles" => [
                                       {
                                         "id" => profile_id, "type" => "ParticipantProfile::ECT"
                                       },
                                     ],
                                   },
                                 },
                                 {
                                   "id" => "fca9d4b9-4bae-4ce2-ba01-eb3fdc2da315",
                                   "type" => "participant_identity",
                                   "attributes" => {
                                     "email" => email2,
                                     "origin" => "ecf",
                                     "created_at" => "2023-09-19T13:54:34.174Z",
                                     "external_identifier" => ext_id2,
                                     "participant_profiles" => [],
                                   },
                                 },
                               ],
                               "participant_declarations" => [],
                               "participant_profile_states" => [],
                             },
                           })
  end
end
