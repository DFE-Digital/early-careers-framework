# frozen_string_literal: true

RSpec.shared_context "with Support for ECTs example profiles", shared_context: :metadata do
  let!(:cohort) { Cohort.current || create(:cohort, :current) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "Teach First") }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let(:core_induction_programme) { create(:core_induction_programme, name: lead_provider.name) }
  let(:cip_school_cohort) { create :school_cohort, induction_programme_choice: "core_induction_programme" }
  let(:cip_induction_programme) { create(:induction_programme, core_induction_programme:, training_programme: "core_induction_programme", school_cohort: cip_school_cohort) }

  let(:fip_partnership) { create :partnership, lead_provider: }
  let(:fip_school_cohort) { create :school_cohort, lead_provider:, induction_programme_choice: "full_induction_programme" }
  let(:fip_induction_programme) { create(:induction_programme, partnership: fip_partnership, training_programme: "full_induction_programme", school_cohort: fip_school_cohort) }

  let(:sit_only) do
    user = create(:user, :induction_coordinator, full_name: "SIT Only")
    user.induction_coordinator_profile
  end

  let(:cip_ect_only) do
    user = create(:user, full_name: "CIP ECT Only")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: cip_school_cohort, core_induction_programme:)
    Induction::Enrol.call(participant_profile:, induction_programme: cip_induction_programme)
    participant_profile
  end

  let(:fip_ect_only) do
    user = create(:user, full_name: "FIP ECT Only")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: fip_school_cohort)
    Induction::Enrol.call(participant_profile:, induction_programme: fip_induction_programme)
    participant_profile
  end

  let(:fip_mentor_only) do
    user = create(:user, full_name: "FIP Mentor Only")
    participant_profile = create(:mentor_participant_profile, user:, school_cohort: fip_school_cohort)
    Induction::Enrol.call(participant_profile:, induction_programme: fip_induction_programme)
    Mentors::AddToSchool.call(mentor_profile: participant_profile, school: fip_school_cohort.school)
    participant_profile
  end

  let(:cip_mentor_only) do
    user = create(:user, full_name: "CIP Mentor Only")
    participant_profile = create(:mentor_participant_profile, user:, school_cohort: cip_school_cohort, core_induction_programme:)
    Induction::Enrol.call(participant_profile:, induction_programme: cip_induction_programme)
    Mentors::AddToSchool.call(mentor_profile: participant_profile, school: cip_school_cohort.school)
    participant_profile
  end

  let(:cip_ect_reg_complete) do
    user = create(:user, full_name: "CIP ECT registration complete")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: cip_school_cohort, core_induction_programme:)
    Induction::Enrol.call(participant_profile:, induction_programme: cip_induction_programme)
    create(:ecf_participant_validation_data, participant_profile:)
    eligibility = ECFParticipantEligibility.create!(participant_profile:)
    eligibility.matched_status!
    participant_profile
  end

  let(:cip_ect_updated_a_year_ago) do
    user = create(:user, full_name: "CIP ECT updated a year ago")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: cip_school_cohort, core_induction_programme:)
    Induction::Enrol.call(participant_profile:, induction_programme: cip_induction_programme)

    participant_profile.induction_records.first.update!(updated_at: 1.year.ago)
    participant_profile.update!(updated_at: 1.year.ago)
    # has to be done last because of "touch: true" on ParticipantProfile
    user.update!(updated_at: 1.year.ago)

    participant_profile
  end

  let(:fip_ect_transferring_in) do
    user = create(:user, full_name: "FIP ECT transferring in")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: fip_school_cohort)
    Induction::Enrol.call(participant_profile:, induction_programme: fip_induction_programme, start_date: 2.months.ago)
    participant_profile.induction_records.latest.leaving!(1.month.from_now, transferring_out: false)
    participant_profile
  end

  let(:fip_ect_transferring_out) do
    user = create(:user, full_name: "FIP ECT transferring out")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: fip_school_cohort)
    Induction::Enrol.call(participant_profile:, induction_programme: fip_induction_programme, start_date: 3.months.ago)
    participant_profile.induction_records.latest.leaving!(2.months.ago, transferring_out: true)
    participant_profile
  end

  let(:fip_ect_withdrawn) do
    user = create(:user, full_name: "FIP ECT withdrawn")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: fip_school_cohort)
    Induction::Enrol.call(participant_profile:, induction_programme: fip_induction_programme, start_date: 2.weeks.ago)
    participant_profile.induction_records.latest.withdrawing!(1.week.ago)
    participant_profile.update! status: "withdrawn"
    participant_profile
  end

  let(:cip_ect_reg_for_future) do
    user = create(:user, full_name: "CIP ECT registered for future")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: cip_school_cohort, core_induction_programme:)
    Induction::Enrol.call(participant_profile:, induction_programme: cip_induction_programme, start_date: 1.year.from_now)
    participant_profile
  end

  let(:npq_only) { create(:npq_participant_profile) }

  # real cases found in production

  let(:fip_ect_then_mentor) do
    user = create(:user, full_name: "FIP ECT then Mentor")
    teacher_profile = create(:teacher_profile, user:)

    ect_identity = create(:participant_identity, user:)
    ect_profile = create(:ect_participant_profile, teacher_profile:, school_cohort: fip_school_cohort, participant_identity: ect_identity)
    Induction::Enrol.call(participant_profile: ect_profile, induction_programme: fip_induction_programme, start_date: 6.months.ago)

    mentor_identity = create(:participant_identity, :secondary, user:, email: "mentor_1@example.com")
    mentor_profile = create(:mentor_participant_profile, teacher_profile:, school_cohort: fip_school_cohort, participant_identity: mentor_identity)
    Induction::Enrol.call(participant_profile: mentor_profile, induction_programme: fip_induction_programme, start_date: 3.months.ago)
    Mentors::AddToSchool.call(mentor_profile:, school: fip_induction_programme.school)

    { ect_profile:, mentor_profile: }
  end

  # real cases found in seed data

  let(:npq_with_induction_record) do
    user = create(:user, full_name: "NPQ with induction record")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: cip_school_cohort)
    Induction::Enrol.call(participant_profile:, induction_programme: cip_induction_programme)
    participant_profile.update! type: "ParticipantProfile::NPQ"
    participant_profile
  end

  let(:ect_with_no_induction_record) do
    user = create(:user, full_name: "ECT with no induction record")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: cip_school_cohort, core_induction_programme:)
    participant_profile.update! status: "withdrawn"
    participant_profile
  end

  # search test needed
  let(:cip_ect_with_corrupt_history) do
    user = create(:user, full_name: "CIP ECT with corrupt history")
    participant_profile = create(:ect_participant_profile, user:, school_cohort: cip_school_cohort, core_induction_programme:)
    Induction::Enrol.call(participant_profile:, induction_programme: cip_induction_programme)

    induction_record = participant_profile.induction_records.latest
    Induction::ChangeInductionRecord.call(induction_record:, changes: { training_status: "withdrawn", induction_status: "withdrawn" })
    Induction::ChangeInductionRecord.call(induction_record:, changes: { training_status: "active" })

    participant_profile
  end

  # search test needed
  let(:fip_ect_with_no_identity) do
    user = create(:user, full_name: "FIP ECT with no identity")
    teacher_profile = create(:teacher_profile, user:)

    participant_identity = create(:participant_identity, user:)
    participant_profile = create(:ect_participant_profile, teacher_profile:, school_cohort: fip_school_cohort, participant_identity:)
    Induction::Enrol.call(participant_profile:, induction_programme: fip_induction_programme, start_date: 6.months.ago)

    participant_profile.induction_records.first.update! preferred_identity_id: SecureRandom.uuid
    participant_profile
  end

  # search test needed
  let(:fip_ect_with_different_identity) do
    user = create(:user, full_name: "FIP ECT with different identity")
    teacher_profile = create(:teacher_profile, user:)

    participant_identity = create(:participant_identity, user:)
    participant_profile = create(:ect_participant_profile, teacher_profile:, school_cohort: fip_school_cohort, participant_identity:)
    Induction::Enrol.call(participant_profile:, induction_programme: fip_induction_programme)

    user_2 = create(:user, full_name: "FIP ECT with different identity (other)")
    teacher_profile_2 = create(:teacher_profile, user: user_2)

    participant_identity_2 = create(:participant_identity, user: user_2)
    participant_profile_2 = create(:ect_participant_profile, teacher_profile: teacher_profile_2, school_cohort: fip_school_cohort, participant_identity: participant_identity_2)
    Induction::Enrol.call(participant_profile: participant_profile_2, induction_programme: fip_induction_programme)
    induction_record = participant_profile_2.induction_records.latest
    induction_record.withdrawing!
    Induction::ChangeInductionRecord.call(induction_record:, changes: { training_status: "active", induction_status: "active" })
    induction_record_2 = participant_profile_2.induction_records.latest
    Induction::ChangeInductionRecord.call(induction_record: induction_record_2, changes: { training_status: "active", induction_status: "active" })
    induction_record_3 = participant_profile_2.induction_records.latest

    induction_record_2.update! participant_profile_id: participant_profile.id
    induction_record_3.update! participant_profile_id: participant_profile.id
    induction_record.withdrawing!

    { correct_profile: participant_profile, wrong_profile: participant_profile_2 }
  end
end

RSpec.configure do |config|
  config.include_context "with Support for ECTs example profiles", :with_support_for_ect_examples
  config.include_context "with default schedules", :with_support_for_ect_examples
end
