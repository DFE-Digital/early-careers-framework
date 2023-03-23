# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantIdentity, type: :model do
  subject(:participant_identity) { create(:participant_identity) }

  let(:user) { participant_identity.user }
  let(:additional_identity) { create(:participant_identity, :secondary, user:, email: Faker::Internet.email) }
  let(:identity_of_duplicate_user) { create(:ect_participant_profile).participant_identity }
  let(:transferred_identity) do
    identity_of_duplicate_user.tap { |identity| identity.update!(user:) }
  end

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

    describe "#secondary" do
      it "returns all the transferred and additional identities" do
        expect(described_class.secondary).to include(additional_identity, transferred_identity)
      end
    end
  end

  describe "#original_identity?" do
    it "returns true for the first identity of the participant" do
      expect(participant_identity.original_identity?).to be true
    end
  end

  describe "#secondary_identity?" do
    it "returns true for any of the second identities" do
      expect(additional_identity.secondary_identity?).to be true
      expect(transferred_identity.secondary_identity?).to be true
    end
  end

  describe "#additional_identity?" do
    it "returns true when the identity has no participant profiles" do
      expect(additional_identity.participant_profiles).to be_empty
      expect(additional_identity.additional_identity?).to be true
    end
  end

  describe "#transferred_identity?" do
    it "returns true when the identity has participant profiles and the external_identifier does not matches the user id" do
      expect(transferred_identity.participant_profiles).not_to be_empty
      expect(transferred_identity.transferred_identity?).to be true
    end
  end
end
