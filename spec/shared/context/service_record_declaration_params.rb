# frozen_string_literal: true

RSpec.shared_context "service record declaration params" do
  let(:params) do
    {
      user_id: ect_profile.user.id,
      declaration_date: "2021-06-21T08:46:29Z",
      declaration_type: "retained-1",
      course_identifier: "ecf-induction",
      lead_provider_from_token: another_lead_provider,
      evidence_held: "other",
    }
  end
  let(:ect_params) do
    params.merge({ lead_provider_from_token: cpd_lead_provider })
  end
  let(:mentor_params) do
    ect_params.merge({ user_id: mentor_profile.user.id, course_identifier: "ecf-mentor" })
  end
  let(:npq_params) do
    params.merge({ lead_provider_from_token: cpd_lead_provider, user_id: npq_profile.user_id, course_identifier: "npq-leading-teaching", evidence_held: "yes" })
  end
  let(:induction_coordinator_params) do
    ect_params.merge({ user_id: induction_coordinator_profile.user_id })
  end
end
