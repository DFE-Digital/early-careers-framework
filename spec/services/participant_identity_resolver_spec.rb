# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantIdentityResolver, :with_support_for_ect_examples do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:user) { create(:user) }
  let(:participant_id) { user.id }
  let(:teacher_profile) { create(:teacher_profile, user:) }
  let(:course_identifier) { "ecf-induction" }

  let(:params) { { participant_id:, course_identifier:, cpd_lead_provider: } }

  subject { described_class.new(**params) }

  describe "#initialize" do
    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@participant_id)).to eq(participant_id)
    end

    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@course_identifier)).to eq(course_identifier)
    end

    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@cpd_lead_provider)).to eq(cpd_lead_provider)
    end
  end

  describe "#call" do
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

    context "when participant external identifier does not equal user id" do
      let(:ect_profile) { create(:ect, lead_provider:, user:) }
      let!(:participant_identity) { create(:participant_identity, :secondary, user:) }
      let(:participant_id) { participant_identity.external_identifier }

      it "correctly selects ect participant identity" do
        result = subject.call

        expect(result).to eql(participant_identity)
      end
    end
  end
end
