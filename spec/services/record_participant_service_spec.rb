# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordParticipantEvent do
  let(:lead_provider) { create(:lead_provider) }
  let(:another_lead_provider) { create(:lead_provider, name: "Unknown") }
  let(:ect_profile) { create(:early_career_teacher_profile) }
  let(:params) do
    {
      raw_event: "{\"participant_id\":\"37b300a8-4e99-49f1-ae16-0235672b6708\",\"declaration_type\":\"started\",\"declaration_date\":\"2021-06-21T08:57:31Z\"}",
      participant_id: ect_profile.user_id,
      declaration_date: "2021-06-21T08:46:29Z",
      declaration_type: "started",
      lead_provider: another_lead_provider,
    }
  end
  let(:delivery_partner) { create(:delivery_partner) }
  let!(:school_cohort) { create(:school_cohort, school: ect_profile.school, cohort: ect_profile.cohort) }
  let!(:partnership) do
    create(:partnership,
           school: ect_profile.school,
           lead_provider: lead_provider,
           cohort: ect_profile.cohort,
           delivery_partner: delivery_partner)
  end

  context "when lead providers don't match" do
    it "should make recording participant event raise an error" do
      expect { described_class.call(params) }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
