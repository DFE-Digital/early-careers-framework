# frozen_string_literal: true

RSpec.describe Finance::NPQ::ChangeLeadProviderForm, :with_default_schedules, type: :model do
  subject(:form) { described_class.new(params) }

  describe "NPQ" do
    let!(:lead_provider) { create(:npq_lead_provider) }
    let(:participant_profile) { create(:npq_participant_profile) }
    let(:params) { { participant_profile:, lead_provider_id: lead_provider.id } }
    let(:cohort) { participant_profile.npq_application.cohort }
    let!(:npq_leadership_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
    let!(:npq_contract) { create(:npq_contract, :npq_senior_leadership, cohort:, npq_lead_provider: lead_provider) }

    it { is_expected.to validate_inclusion_of(:lead_provider_id).in_array([lead_provider.id]) }

    describe ".save" do
      context "valid params" do
        it "should change lead provider" do
          expect(form.save).to be true
          expect(participant_profile.npq_application.reload.npq_lead_provider).to eql(lead_provider)
        end
      end

      context "invalid params" do
        let(:params) { { participant_profile:, lead_provider_id: nil } }

        it "should not change lead provider" do
          old_lead_provider = participant_profile.npq_application.npq_lead_provider
          expect(form.save).to be false
          expect(participant_profile.npq_application.reload.npq_lead_provider).to eql(old_lead_provider)
          expect(participant_profile.npq_application.reload.npq_lead_provider).not_to eql(lead_provider)
        end
      end
    end
  end
end
