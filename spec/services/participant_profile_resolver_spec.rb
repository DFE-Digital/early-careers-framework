# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfileResolver do
  describe "#call" do
    context "when participant has both ECT and NPQ profiles" do
      let!(:ect_profile) { create(:ect) }
      let!(:npq_application) { create(:npq_application, :accepted, user:) }

      let(:npq_profile) { npq_application.profile }
      let(:user) { ect_profile.user }
      let(:participant_identity) { user.participant_identities.first }
      let(:course_identifier) { npq_application.npq_course.identifier }
      let(:cpd_lead_provider) { npq_application.npq_lead_provider.cpd_lead_provider }

      it "correctly selects NPQ profile" do
        result = described_class.call(
          participant_identity:,
          course_identifier:,
          cpd_lead_provider:,
        )

        expect(result).to eql(npq_profile)
      end
    end
  end
end
