# frozen_string_literal: true

RSpec.shared_context "lead provider profiles and courses" do
  # lead providers setup
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:another_lead_provider) { create(:cpd_lead_provider, name: "Unknown") }

  # ECF setup
  let(:ect_profile) { create(:early_career_teacher_profile) }
  let(:mentor_profile) { create(:mentor_profile) }
  let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }
  let(:delivery_partner) { create(:delivery_partner) }
  let!(:school_cohort) { create(:school_cohort, school: ect_profile.school, cohort: ect_profile.cohort) }
  let!(:partnership) do
    create(:partnership,
           school: ect_profile.school,
           lead_provider: cpd_lead_provider.lead_provider,
           cohort: ect_profile.cohort,
           delivery_partner: delivery_partner)
  end

  # NPQ setup
  let(:npq_user) { create(:user) }
  let(:npq_teacher_profile) { create(:teacher_profile, user: npq_user) }
  let(:npq_participant_profile) { create(:participant_profile, :npq, teacher_profile: npq_teacher_profile) }

  let(:npq_lead_provider) { create(:npq_lead_provider, cpd_lead_provider: cpd_lead_provider) }
  let(:npq_course) { create(:npq_course, identifier: "npq-leading-teaching") }

  let(:npq_profile) do
    create(:npq_validation_data,
           npq_lead_provider: npq_lead_provider,
           npq_course: npq_course,
           profile: npq_participant_profile,
           user: npq_user)
  end
end
