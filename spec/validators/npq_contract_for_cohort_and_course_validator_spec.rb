# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQContractForCohortAndCourseValidator do
  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      validates :cohort, npq_contract_for_cohort_and_course: true

      attr_reader :cohort, :cpd_lead_provider, :course_identifier

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      def initialize(cohort:, cpd_lead_provider:, course_identifier:)
        @cohort = cohort
        @cpd_lead_provider = cpd_lead_provider
        @course_identifier = course_identifier
      end
    end
  end

  describe "#validate" do
    subject { klass.new(**params) }

    let(:params) { { cohort:, cpd_lead_provider:, course_identifier: } }

    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
    let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
    let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
    let(:participant_profile) { create(:npq_participant_profile, npq_course:) }
    let(:cohort) { participant_profile.npq_application.cohort }
    let!(:npq_contract) { create(:npq_contract, :npq_senior_leadership, cohort:, npq_lead_provider:) }

    context "NPQ course" do
      let(:course_identifier) { npq_course.identifier }

      it "is valid" do
        expect(subject).to be_valid
      end

      context "when lead provider has no contract for the cohort and course" do
        before { npq_contract.update!(npq_course: create(:npq_specialist_course)) }

        it "is invalid" do
          expect(subject).to be_invalid
        end

        it "has a meaningfull error", :aggregate_failures do
          expect(subject).to be_invalid
          expect(subject.errors.messages_for(:cohort))
            .to eq(["You cannot change a participant to this cohort as you do not have a contract for the cohort and course. Contact the DfE for assistance."])
        end
      end
    end

    context "non NPQ course" do
      let(:course_identifier) { "ecf-induction" }

      it "returns no errors" do
        expect(subject).to be_valid
        expect(subject.errors).to be_empty
      end
    end
  end
end
