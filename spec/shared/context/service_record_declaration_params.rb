# frozen_string_literal: true

RSpec.shared_context "service record declaration params" do
  let(:ect_declaration_date) { ect_profile.schedule.milestones.first.start_date + 1.day }
  let(:params) do
    {
      user_id: ect_profile.user.id,
      declaration_date: ect_declaration_date.rfc3339,
      declaration_type: "retained-1",
      course_identifier: "ecf-induction",
      lead_provider_from_token: another_lead_provider,
      evidence_held: "other",
    }
  end
  let(:ect_params) do
    params.merge({ lead_provider_from_token: cpd_lead_provider })
  end

  let(:mentor_declaration_date) { mentor_profile.schedule.milestones.first.start_date + 1.day }
  let(:mentor_params) do
    ect_params.merge({ user_id: mentor_profile.user.id, course_identifier: "ecf-mentor", declaration_date: mentor_declaration_date.rfc3339 })
  end

  let(:npq_declaration_date) { npq_profile.schedule.milestones.first.start_date + 1.day }
  let(:npq_params) do
    params.merge({
      lead_provider_from_token: cpd_lead_provider,
      user_id: npq_profile.user.id,
      course_identifier: npq_profile.validation_data.npq_course.identifier,
      evidence_held: "yes",
      declaration_date: npq_declaration_date.rfc3339,
    })
  end

  let(:induction_coordinator_params) do
    ect_params.merge({ user_id: induction_coordinator_profile.user_id })
  end
end
