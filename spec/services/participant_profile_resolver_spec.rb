# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfileResolver do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  describe "#call" do
    context "when participant has ECT profile" do
      let!(:ect_profile) { create(:ect, lead_provider:) }

      let(:user) { ect_profile.user }
      let(:participant_identity) { user.participant_identities.first }
      let(:course_identifier) { "ecf-induction" }

      it "correctly selects ect profile" do
        result = described_class.call(
          participant_identity:,
          course_identifier:,
          cpd_lead_provider:,
        )

        expect(result).to eql(ect_profile)
      end
    end

    context "when participant has Mentor profile" do
      let(:user) { create(:user) }
      let(:teacher_profile) { create(:teacher_profile, user:) }
      let(:participant_identity) { create(:participant_identity, user:, email: Faker::Internet.email) }
      let!(:mentor_profile) { create(:mentor_participant_profile, participant_identity:, teacher_profile:) }
      let(:course_identifier) { "ecf-mentor" }

      before { mentor_profile.update!(participant_identity:) }

      it "correctly selects mentor profile" do
        result = described_class.call(
          participant_identity:,
          course_identifier:,
          cpd_lead_provider:,
        )

        expect(result).to eql(mentor_profile)
      end
    end
  end
end
