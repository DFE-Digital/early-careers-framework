# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppropriateBodies::ParticipantsFilter do
  let(:appropriate_body_user) { create(:user, :appropriate_body) }
  let(:appropriate_body) { appropriate_body_user.appropriate_bodies.first }

  let(:participant_profile1) { create(:ect_participant_profile) }
  let(:induction_programme1) { create(:induction_programme, :fip) }
  let!(:induction_record1) { create(:induction_record, participant_profile: participant_profile1, appropriate_body:, induction_programme: induction_programme1) }

  let(:participant_profile2) { create(:ect_participant_profile, training_status: "deferred") }
  let(:induction_programme2) { create(:induction_programme, :cip) }
  let!(:induction_record2) { create(:induction_record, participant_profile: participant_profile2, appropriate_body:, induction_programme: induction_programme2, training_status: "deferred") }

  let(:collection) { AppropriateBodies::InductionRecordsQuery.new(appropriate_body:).induction_records }
  let(:params) { {} }

  subject { described_class.new(collection:, params:) }

  context "No filter" do
    it "returns correct participants" do
      expect(subject.scope.count).to eql(2)
      expect(subject.scope.to_a).to match_array([induction_record1, induction_record2])
    end
  end

  context "Search filter" do
    context "by full name" do
      let(:params) { { query: participant_profile2.user.full_name } }

      it "returns correct participants" do
        expect(subject.scope.count).to eql(1)
        expect(subject.scope.to_a).to match_array([induction_record2])
      end
    end

    context "by school name" do
      let(:params) { { query: induction_record1.school.name } }

      it "returns correct participants" do
        expect(subject.scope.count).to eql(1)
        expect(subject.scope.to_a).to match_array([induction_record1])
      end
    end

    context "by school URN" do
      let(:params) { { query: induction_record2.school.urn } }

      it "returns correct participants" do
        expect(subject.scope.count).to eql(1)
        expect(subject.scope.to_a).to match_array([induction_record2])
      end
    end

    context "by TRN" do
      let(:params) { { query: participant_profile1.teacher_profile.trn } }

      it "returns correct participants" do
        expect(subject.scope.count).to eql(1)
        expect(subject.scope.to_a).to match_array([induction_record1])
      end
    end
  end

  context "Status filter" do
    context "Filter by training_or_eligible_for_training" do
      let(:params) { { status: "training_or_eligible_for_training" } }

      it "returns correct participants" do
        expect(subject.scope.count).to eql(1)
        expect(subject.scope.to_a).to match_array([induction_record2])
      end
    end

    context "Filter by dfe_checking_eligibility" do
      let(:params) { { status: "dfe_checking_eligibility" } }

      it "returns correct participants" do
        expect(subject.scope.count).to eql(1)
        expect(subject.scope.to_a).to match_array([induction_record1])
      end
    end

    context "Filter by contacted_for_information" do
      let(:params) { { status: "contacted_for_information" } }

      it "should return empty" do
        expect(subject.scope.count).to eql(0)
      end
    end
  end
end
