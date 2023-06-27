# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration::NPQ, type: :model do
  context "when declarations for a particular course are made" do
    before do
      create_list(:npq_participant_declaration, 20)
    end

    describe "associations" do
      subject(:declaration) { create(:npq_participant_declaration) }

      describe "outcomes" do
        it {
          is_expected.to have_many(:outcomes)
            .class_name("ParticipantOutcome::NPQ")
            .with_foreign_key("participant_declaration_id")
        }
      end
    end

    it "returns all records when not scoped" do
      expect(described_class.all.count).to eq(20)
    end

    it "can retrieve by npq courses attached" do
      expect(NPQCourse.identifiers.uniq.map { |course_identifier| described_class.for_course(course_identifier).count }.inject(:+)).to eq(20)
    end
  end

  describe "scopes" do
    describe "#valid_to_have_outcome_for_lead_provider_and_course" do
      let!(:participant_declaration) { create(:npq_participant_declaration, :eligible) }

      before { participant_declaration.update!(declaration_type: "completed") }

      it "returns only valid declarations" do
        expect(described_class.valid_to_have_outcome_for_lead_provider_and_course(participant_declaration.cpd_lead_provider, participant_declaration.course_identifier)).to match([participant_declaration])
      end
    end
  end

  describe "instance methods" do
    describe "#qualification_type" do
      let(:identifier) { "npq-senior-leadership" }
      let(:npq_course) { create(:npq_course, identifier:) }
      let(:participant_declaration) { create(:npq_participant_declaration, npq_course:) }

      it "returns the formatted qualification type" do
        expect(participant_declaration.qualification_type).to eq("NPQSL")
      end
    end
  end

  describe "#uplift_paid?" do
    let(:declaration_state) { "paid" }
    let(:course_identifier) { "npq-leading-teaching" }
    let(:npq_course) { create(:npq_course, identifier: course_identifier) }
    let!(:participant_declaration) do
      create(
        :npq_participant_declaration,
        profile_traits: [:targeted_delivery_funding_eligibility],
        declaration_type: "started",
        npq_course:,
        state: declaration_state,
      )
    end

    %w[
      npq-leading-teaching
      npq-leading-behaviour-culture
      npq-leading-teaching-development
      npq-senior-leadership
      npq-headship
      npq-executive-leadership
      npq-early-years-leadership
      npq-leading-literacy
    ].each do |course|
      %w[paid awaiting_clawback clawed_back].each do |state|
        context "started - #{course} - #{state}" do
          let(:declaration_state) { state }
          let(:course_identifier) { course }

          it "should be true" do
            expect(participant_declaration.uplift_paid?).to eql(true)
          end
        end
      end
    end

    %w[npq-additional-support-offer npq-early-headship-coaching-offer].each do |course|
      context "started - #{course} - paid" do
        let(:course_identifier) { course }

        it "should be false" do
          expect(subject.uplift_paid?).to eql(false)
        end
      end
    end

    context "targeted_delivery_funding_eligibility is false" do
      let!(:participant_declaration) do
        create(
          :npq_participant_declaration,
          profile_traits: [],
          declaration_type: "started",
          npq_course:,
          state: declaration_state,
        )
      end

      it "should be false" do
        expect(subject.uplift_paid?).to eql(false)
      end
    end
  end
end
