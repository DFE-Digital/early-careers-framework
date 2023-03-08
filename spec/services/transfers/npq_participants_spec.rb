# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transfers::NPQParticipants, :with_default_schedules do
  let!(:new_cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:new_npq_lead_provider_id) { new_cpd_lead_provider.npq_lead_provider.id }

  let(:cpd_lead_provider)      { create(:cpd_lead_provider, :with_npq_lead_provider, :with_lead_provider) }
  let(:npq_lead_provider)      { cpd_lead_provider.npq_lead_provider }
  let(:current_npq_lead_provider_id) { cpd_lead_provider.npq_lead_provider.id }
  let!(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:) }

  let(:external_identifier) { participant_profile.participant_identity.external_identifier }
  let(:npq_application) { participant_profile.npq_application }
  let(:course_identifier) { participant_profile.npq_application.npq_course.identifier }

  subject do
    described_class.new(
      external_identifier:,
      current_npq_lead_provider_id:,
      new_npq_lead_provider_id:,
      course_identifier:,
    )
  end

  describe "#call" do
    it "transfers the participant application to the new NPQ lead provider" do
      expect { subject.call }.to change { npq_application.reload.npq_lead_provider_id }.from(npq_lead_provider.id).to(new_npq_lead_provider_id)
    end

    context "when NPQ lead provider does not exist" do
      let(:new_npq_lead_provider_id) { "does-not-exist" }
      it "does not update the NPQ lead provider on the participant application" do
        expect { subject.call }
          .to raise_error(ActiveRecord::RecordNotFound)
          .and not_change { npq_application.reload.npq_lead_provider_id }
      end
    end

    context "when participant does not exist" do
      let(:external_identifier) { "does-not-exist" }
      it "does not update the NPQ lead provider on the participant application" do
        expect { subject.call }
          .to raise_error(ActiveRecord::RecordNotFound)
          .and not_change { npq_application.reload.npq_lead_provider_id }
      end
    end

    context "when participant does not have an active NPQ profile" do
      let!(:participant_profile) { create(:npq_participant_profile, :withdrawn_record, npq_lead_provider:) }
      it "does not update the NPQ lead provider on the participant application" do
        expect { subject.call }
          .to raise_error(ActiveRecord::RecordNotFound)
          .and not_change { npq_application.reload.npq_lead_provider_id }
      end
    end

    context "when course_identifier is different than one attached to the profile" do
      let(:course_identifier) { "some-other-identifier" }
      it "does not update the NPQ lead provider on the participant application" do
        expect { subject.call }
          .to raise_error(ActiveRecord::RecordNotFound)
          .and not_change { npq_application.reload.npq_lead_provider_id }
      end
    end
  end
end
