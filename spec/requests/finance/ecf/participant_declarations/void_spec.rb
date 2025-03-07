# frozen_string_literal: true

require "rails_helper"

RSpec.shared_context "participant profile, declaration and access checks" do
  context "when the participant profile does not exist" do
    let(:participant_profile) { OpenStruct.new(id: SecureRandom.uuid) }

    it { is_expected.to be_not_found }
  end

  context "when the declaration does not exist" do
    let(:declaration) { OpenStruct.new(id: SecureRandom.uuid, participant_profile: create(:ect_participant_profile)) }

    it { is_expected.to be_not_found }
  end

  context "when the declaration does not belong to the participant profile" do
    let(:participant_profile) { create(:ect_participant_profile) }

    it { is_expected.to be_not_found }
  end

  context "when not signed in" do
    let(:user) { nil }

    it { is_expected.to redirect_to(new_user_session_path) }
  end
end

RSpec.describe "Voiding declarations", exceptions_app: true do
  let(:user) { create(:user, :finance) }
  let(:declaration) { create(:ect_participant_declaration, :eligible) }
  let(:participant_profile) { declaration.participant_profile }

  subject { response }

  before { sign_in(user) if user }

  describe "#new" do
    before { get new_void_finance_participant_profile_ecf_participant_declarations_path(participant_profile.id, declaration.id) }

    it { is_expected.to be_successful }

    include_context "participant profile, declaration and access checks"
  end

  describe "#create" do
    before { post create_void_finance_participant_profile_ecf_participant_declarations_path(participant_profile.id, declaration.id) }

    it { is_expected.to redirect_to(finance_participant_path(participant_profile.user)) }

    it "sets the voided_at and voided_by_user of the declaration" do
      expect(declaration.reload).to have_attributes(
        voided_at: be_within(5.seconds).of(Time.zone.now),
        voided_by_user: user,
      )
    end

    it "shows a success message" do
      follow_redirect!

      expect(response.body).to include(I18n.t("finance.void_declaration.success.heading"))
    end

    context "when the declaration cannot be voided" do
      let(:declaration) { create(:ect_participant_declaration, :voided) }

      it "does not update the declaration" do
        expect(declaration.attributes).to eq(declaration.reload.attributes)
      end

      it "shows an error message" do
        follow_redirect!

        expect(response.body).to include(I18n.t("finance.void_declaration.failure.content"))
      end
    end

    include_context "participant profile, declaration and access checks"
  end
end
