# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantIdentity, type: :model do
  subject(:participant_identity) { create(:participant_identity) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:participant_profiles) }
  it { is_expected.to have_many(:npq_applications) }
  it {
    is_expected.to define_enum_for(:origin).with_values(
      ecf: "ecf",
      npq: "npq",
    ).with_suffix.backed_by_column_of_type(:string)
  }

  describe "changes" do
    before do
      participant_identity.user.update!(created_at: 2.weeks.ago, updated_at: 1.week.ago)
    end

    it "updates the updated_at on the user" do
      participant_identity.touch
      expect(participant_identity.user.reload.updated_at).to be_within(1.second).of participant_identity.updated_at
    end
  end

  describe "scopes" do
    describe "#email_matches" do
      it "adds a wildcarded condition on email" do
        # we don't need to worry about case sensitivity here because the email
        # address column is citext
        expect(described_class.email_matches("xyz").to_sql).to include("participant_identities.email like '%xyz%'")
      end
    end
  end
end
