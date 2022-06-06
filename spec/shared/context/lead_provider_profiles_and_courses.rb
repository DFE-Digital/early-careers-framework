# frozen_string_literal: true

RSpec.shared_context "lead provider profiles and courses" do
  include_context "with default schedules"

  # lead providers setup
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:another_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "Unknown") }
  let!(:default_schedule) { Finance::Schedule::ECF.default }

  # ECF setup
  let(:ecf_lead_provider) { cpd_lead_provider.lead_provider }
  let!(:ect_profile) { create(:ect_participant_profile, schedule: default_schedule) }
  let!(:mentor_profile) { create(:mentor_participant_profile, school_cohort: ect_profile.school_cohort, schedule: default_schedule) }
  let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }
  let(:delivery_partner) { create(:delivery_partner) }
  let!(:school_cohort) { create(:school_cohort, school: ect_profile.school, cohort: ect_profile.cohort) }

  let(:induction_programme) { create(:induction_programme, :fip, partnership:) }

  let!(:induction_record) do
    Induction::Enrol.call(participant_profile: profile, induction_programme:)
  end

  let!(:mentor_induction_record) do
    Induction::Enrol.call(participant_profile: mentor_profile, induction_programme:)
  end

  let!(:partnership) do
    create(:partnership,
           school: ect_profile.school,
           lead_provider: cpd_lead_provider.lead_provider,
           cohort: ect_profile.cohort,
           delivery_partner:)
  end

  let(:induction_programme) { create(:induction_programme, partnership:, school_cohort:) }

  let!(:induction_record) do
    Induction::Enrol.call(participant_profile: ect_profile, induction_programme:)
  end

  # NPQ setup
  let(:npq_lead_provider) { create(:npq_lead_provider, cpd_lead_provider:) }
  let(:npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }
  let!(:npq_profile) do
    npq_application = create(
      :npq_application,
      npq_lead_provider:,
      npq_course:,
    )
    create(
      :npq_participant_profile,
      npq_application:,
      user: npq_application.user,
      teacher_profile: npq_application.user.teacher_profile,
      schedule: create(:npq_specialist_schedule),
    )
  end
end
