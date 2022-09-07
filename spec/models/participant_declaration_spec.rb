# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, :with_default_schedules, type: :model do
  let(:user) { create(:user) }
  subject { described_class.new(user:) }

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider) }
    it { is_expected.to belong_to(:participant_profile) }
    it { is_expected.to have_many(:declaration_states) }
  end

  describe "state transitions" do
    let(:cpd_lead_provider)       { create(:cpd_lead_provider, :with_lead_provider) }
    let!(:statement)              { create(:ecf_statement, :output_fee, deadline_date: 2.days.from_now, cpd_lead_provider:) }
    let(:milestone)               { Finance::Schedule::ECF.default_for(cohort: Cohort.current).milestones.find_by(declaration_type: "started") }
    let(:participant_declaration) do
      travel_to milestone.milestone_date do
        create(:ect_participant_declaration, state, cpd_lead_provider:)
      end
    end

    context "when submitted" do
      let(:state) { :submitted }

      it "has an initial state of submitted" do
        expect(participant_declaration).to be_submitted
      end

      it "will move from submitted to eligible" do
        expect(participant_declaration.make_eligible!).to be true
        expect(participant_declaration).to be_eligible
      end

      it "can be voided" do
        expect(participant_declaration.make_voided!).to be true
        expect(participant_declaration).to be_voided
      end

      it "cannot be directly be made payable or paid" do
        expect(participant_declaration.make_paid!).to be_falsey
        expect(participant_declaration.make_payable!).to be_falsey
      end

      it "can be ineligible" do
        expect(participant_declaration.make_ineligible!).to be true
        expect(participant_declaration).to be_ineligible
      end
    end

    context "when eligible" do
      let(:state) { :eligible }

      before do
        create(:ecf_statement, :output_fee, :next_output_fee, cpd_lead_provider:)
      end

      it "has an state of eligible" do
        expect(participant_declaration).to be_eligible
      end

      it "can be voided" do
        expect(participant_declaration.make_voided!).to be_truthy
        expect(participant_declaration).to be_voided
      end

      it "can move from eligible to payable" do
        expect(participant_declaration.make_payable!).to be_truthy
        expect(participant_declaration).to be_payable
      end

      it "cannot be directly be made paid" do
        expect(participant_declaration.make_paid!).to be_falsey
      end

      it "cannot be made ineligible" do
        expect(participant_declaration.make_ineligible!).to be_falsey
      end
    end

    context "when payable" do
      let(:state) { :payable }

      it "has an state of payable" do
        expect(participant_declaration).to be_payable
      end

      it "will not move to eligible or submitted" do
        expect(participant_declaration.make_submitted!).to be_falsey
        expect(participant_declaration.make_eligible!).to be_falsey
      end

      it "can be voided" do
        expect(participant_declaration.make_voided!).to be_truthy
      end

      it "can move from payable to paid" do
        expect(participant_declaration.make_paid!).to be_truthy
        expect(participant_declaration.paid?).to be_truthy
      end

      it "cannot be made ineligible" do
        expect(participant_declaration.make_ineligible!).to be_falsey
      end
    end

    context "when paid" do
      let(:state) { :paid }

      it "has an state of paid" do
        expect(participant_declaration).to be_paid
      end

      it "will not move to eligible, payable or submitted" do
        expect(participant_declaration.make_submitted!).to be_falsey
        expect(participant_declaration.make_eligible!).to be_falsey
        expect(participant_declaration.make_payable!).to be_falsey
      end

      it "cannot be voided" do # TODO: This should trigger clawbacks, but that's a later thing.
        expect(participant_declaration.make_voided!).to be_falsey
      end

      it "cannot be made ineligible" do
        expect(participant_declaration.make_ineligible!).to be_falsey
      end
    end
  end

  describe "uplift scope" do
    let(:call_off_contract) { create(:call_off_contract) }

    context "when one profile" do
      context "for mentor was created" do
        let(:mentor_participant_declaration) do
          create(:mentor_participant_declaration,
                 profile_traits: [:sparsity_uplift],
                 cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
        end

        it "includes declaration with mentor profile" do
          expect(ParticipantDeclaration.uplift).to include(mentor_participant_declaration)
        end
      end

      context "for early career teacher was created" do
        let(:ect_participant_declaration) do
          create(:ect_participant_declaration,
                 profile_traits: [:sparsity_uplift],
                 cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
        end

        it "includes declaration with mentor profile" do
          expect(ParticipantDeclaration.uplift).to include(ect_participant_declaration)
        end
      end
    end
  end

  describe "declaration state" do
    let!(:participant_declaration) { create(:ect_participant_declaration) }

    it "mirrors the most recent declaration_state" do
      participant_declaration.make_eligible!

      expect(participant_declaration.declaration_states.order(created_at: :desc).first).to be_eligible
      expect(participant_declaration).to be_eligible
    end
  end

  describe "voided!" do
    let!(:participant_declaration) { create(:ect_participant_declaration, :submitted) }
    let!(:eligibility) { ECFParticipantEligibility.create!(participant_profile: participant_declaration.participant_profile) }

    context "when declaration was payable" do
      before do
        participant_declaration.make_eligible!
      end

      it "voids the declaration" do
        expect(participant_declaration).to be_eligible
        participant_declaration.make_voided!
        expect(participant_declaration.eligible?).to be_falsey
        expect(participant_declaration.voided?).to be_truthy
      end
    end

    context "when declaration was not eligible" do
      before do
        eligibility.manual_check_status!
      end

      it "voids the declaration and keeps it not-eligible" do
        participant_declaration.voided!
        expect(participant_declaration.eligible?).to be_falsy
        expect(participant_declaration.voided?).to be_truthy
      end
    end
  end

  describe "#duplication_declarations", :with_default_schedules do
    let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider)       { cpd_lead_provider.lead_provider }
    let(:participant_profile) { create(:ect, :eligible_for_funding, lead_provider:, user:) }

    before {  create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:) }

    context "when a teacher profile exists with the same TRN" do
      let(:deduplicate) { false }
      let(:other_user)  { create(:user) }
      let(:other_participant_profile_same_trn) do
        create(:ect, :eligible_for_funding, school_cohort: participant_profile.school_cohort, trn: participant_profile.teacher_profile.trn, deduplicate:, user: other_user)
      end

      context "when declarations have been made for a teacher profile with the same trn" do
        subject(:record_started_declaration) do
          create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)
        end

        context "when declarations have been made for the same CPD lead provider" do
          context "when declarations have been made for the same course" do
            let!(:other_participant_declaration) do
              create(:ect_participant_declaration,
                     participant_profile: other_participant_profile_same_trn,
                     cpd_lead_provider:)
            end

            it "returns those declarations" do
              record_started_declaration

              expect(
                participant_profile
                  .participant_declarations
                  .first
                  .duplicate_declarations,
              ).to eq([other_participant_declaration])
            end
          end

          context "when declarations have been made for a different course" do
            let(:mentor_participant_profile) { create(:mentor, school_cohort: participant_profile.school_cohort, trn: participant_profile.teacher_profile.trn, lead_provider:) }
            before do
              create(:mentor_participant_declaration, participant_profile: mentor_participant_profile, cpd_lead_provider:)
            end

            it "does not return those declarations" do
              record_started_declaration

              expect(ParticipantDeclaration.where(cpd_lead_provider:).count).to eq(2)

              expect(
                participant_profile
                  .participant_declarations
                  .first
                  .duplicate_declarations,
              ).to be_empty
            end
          end
        end
      end

      context "when no declaration have been made for a teacher profile with the same trn" do
        subject(:record_started_declaration) do
          create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)
        end

        it "does not return those declarations" do
          record_started_declaration

          expect(
            participant_profile
              .participant_declarations
              .first
              .duplicate_declarations,
          ).to be_empty
        end
      end
    end
  end

  describe "#voidable?" do
    [
      { state: "submitted", voidable: true },
      { state: "eligible", voidable: true },
      { state: "payable", voidable: true },
      { state: "paid", voidable: false },
      { state: "voided", voidable: false },
      { state: "ineligible", voidable: true },
      { state: "awaiting_clawback", voidable: false },
      { state: "clawed_back", voidable: false },
    ].each do |hash|
      context "when declaration is #{hash[:state]}" do
        subject { described_class.new(state: hash[:state]) }

        it "#{hash[:voidable] ? 'can' : 'cannot'} be voided" do
          expect(subject.voidable?).to eql(hash[:voidable])
        end
      end
    end
  end

  describe "unique index" do
    let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_lead_provider) }
    let(:participant_profile) { create(:ect) }
    let(:nowish)              { Time.zone.now }
    let(:state)               { "submitted" }
    let(:attributes)          do
      {
        cpd_lead_provider:,
        participant_profile:,
        user: participant_profile.participant_identity.user,
        declaration_date: nowish,
        declaration_type: "started",
        course_identifier: "ect-induction",
        state:,
      }
    end

    before { described_class.create!(attributes) }

    it "raises an not unique error" do
      expect { described_class.create!(attributes) }.to raise_error ActiveRecord::RecordNotUnique
    end

    context "when the declaration state id voided" do
      let(:state) { :voided }

      it "raises an not unique error" do
        expect { described_class.create!(attributes) }.not_to raise_error
      end
    end

    context "when the declaration state id voided" do
      let(:state) { :ineligible }

      it "raises an not unique error" do
        expect { described_class.create!(attributes) }.not_to raise_error
      end
    end
  end
end
