# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "a participant identity resolver service" do
  context "when participant has both ECT and NPQ profiles" do
    let!(:ect_profile) { create(:ect, lead_provider:, user:) }
    let!(:participant_identity) { ect_profile.participant_identity }
    let(:another_participant_identity) { create(:participant_identity, :secondary, user:, email: Faker::Internet.email) }
    let!(:npq_application) { create(:npq_application, :accepted, participant_identity: another_participant_identity, npq_lead_provider:) }

    context "for npq course" do
      let(:course_identifier) { npq_application.npq_course.identifier }
      let(:user_id) { another_participant_identity.user_id_or_external_identifier }

      it "correctly selects npq participant identity" do
        result = subject.call

        expect(result).to eql(another_participant_identity)
      end
    end

    context "for ect course" do
      let(:user_id) { participant_identity.user_id_or_external_identifier }

      it "correctly selects ect participant identity" do
        result = subject.call

        expect(result).to eql(participant_identity)
      end
    end
  end

  context "when participant has mentor profile" do
    let(:additional_identity) { create(:participant_identity, user:, email: Faker::Internet.email) }
    let!(:participant_profile) { create(:mentor_participant_profile, participant_identity: additional_identity, teacher_profile:) }
    let(:course_identifier) { "ecf-mentor" }

    before { participant_profile.update!(participant_identity: additional_identity) }

    it "correctly selects mentor participant identity" do
      result = subject.call

      expect(result).to eql(additional_identity)
    end
  end

  context "when participant has ECT profile" do
    let(:ect_profile) { create(:ect, lead_provider:, user:) }
    let!(:participant_identity) { ect_profile.participant_identity }

    it "correctly selects ect participant identity" do
      result = subject.call

      expect(result).to eql(participant_identity)
    end
  end

  context "when participant has npq profile" do
    let(:participant_identity) { create(:participant_identity, user:, email: Faker::Internet.email) }
    let(:npq_application) { create(:npq_application, :accepted, participant_identity:, npq_lead_provider:) }
    let!(:course_identifier) { npq_application.npq_course.identifier }

    it "correctly selects npq participant identity" do
      result = subject.call

      expect(result).to eql(participant_identity)
    end
  end
end

RSpec.describe ParticipantIdentityResolver, :with_default_schedules, :with_support_for_ect_examples, with_feature_flags: { external_identifier_to_user_id_lookup: "active" } do
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, npq_lead_provider:) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:teacher_profile) { create(:teacher_profile, user:) }
  let(:course_identifier) { "ecf-induction" }

  let(:params) { { user_id:, course_identifier:, cpd_lead_provider: } }

  subject { described_class.new(**params) }

  describe "#initialize" do
    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@user_id)).to eq(user_id)
    end

    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@course_identifier)).to eq(course_identifier)
    end

    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@cpd_lead_provider)).to eq(cpd_lead_provider)
    end
  end

  describe "#call" do
    context "when feature flag is off", with_feature_flags: { external_identifier_to_user_id_lookup: "active" } do
      it_behaves_like "a participant identity resolver service"
    end

    context "when feature flag is off", with_feature_flags: { external_identifier_to_user_id_lookup: nil } do
      it_behaves_like "a participant identity resolver service"
    end
  end
end
