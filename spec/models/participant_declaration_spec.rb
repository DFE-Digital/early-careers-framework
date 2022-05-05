# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, type: :model do
  let(:user) { create(:user) }
  subject { described_class.new(user: user) }

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider) }
    it { is_expected.to belong_to(:participant_profile) }
    it { is_expected.to have_many(:declaration_states) }
  end

  describe "state transitions" do
    context "when submitted" do
      let!(:participant_declaration) { create(:ect_participant_declaration, :submitted) }

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
      let(:participant_declaration) { create(:ect_participant_declaration, :eligible) }

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
      let(:participant_declaration) { create(:ect_participant_declaration, :payable) }

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
      let(:participant_declaration) { create(:ect_participant_declaration, :paid) }

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
                 :sparsity_uplift,
                 cpd_lead_provider: call_off_contract.lead_provider.cpd_lead_provider)
        end

        it "includes declaration with mentor profile" do
          expect(ParticipantDeclaration.uplift).to include(mentor_participant_declaration)
        end
      end

      context "for early career teacher was created" do
        let(:ect_participant_declaration) do
          create(:ect_participant_declaration,
                 :sparsity_uplift,
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
    let(:validation_data) do
      {
        trn: "1234567",
        full_name: primary_user.full_name,
        date_of_birth: Date.new(1993, 11, 16),
        nino: "QQ123456A",
      }
    end

    let(:dqt_response) do
      {
        trn: "1234567",
        qts: true,
        active_alert: false,
        previous_participation: false,
        previous_induction: false,
      }
    end

    let(:cohort)            { Cohort.find_by(start_year: "2021") }
    let(:school)            { create(:school) }
    let(:school_cohort)     { create(:school_cohort, school: school, cohort: cohort) }

    let(:participant_profile) do
      EarlyCareerTeachers::Create.new(
        full_name: user.full_name,
        email: user.email,
        school_cohort: school_cohort,
        mentor_profile_id: nil,
        year_2020: false,
      ).call.tap do |pp|
        StoreValidationResult.new(
          participant_profile: pp,
          validation_data: validation_data,
          dqt_response: dqt_response,
          deduplicate: false,
        ).call
      end
    end

    context "when a teacher profile exists with the same TRN" do
      let(:mentor_user) { create(:user) }
      let(:primary_user) { create(:user) }
      let(:primary_participant_profile) do
        EarlyCareerTeachers::Create.new(
          full_name: primary_user.full_name,
          email: primary_user.email,
          school_cohort: school_cohort,
          mentor_profile_id: nil,
          year_2020: false,
        ).call.tap do |pp|
          StoreValidationResult.new(
            participant_profile: pp,
            validation_data: validation_data,
            dqt_response: dqt_response,
            deduplicate: false,
          ).call
        end
      end

      let(:mentor_participant_profile) do
        Mentors::Create.new(
          full_name: primary_user.full_name,
          email: primary_user.email,
          school_cohort: school_cohort,
          mentor_profile_id: nil,
          year_2020: false,
        ).call.tap do |pp|
          StoreValidationResult.new(
            participant_profile: pp,
            validation_data: validation_data,
            dqt_response: dqt_response,
            deduplicate: false,
          ).call
        end
      end
      let(:course_identifier) { "ecf-induction" }
      let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:declaration_date)  { (Finance::Schedule::ECF.default.milestones.first.milestone_date - 1.day).rfc3339 }
      let(:declaration_type)  { "started" }

      let(:induction_programme) { create(:induction_programme, partnership: partnership) }

      before do
        Induction::Enrol.call(participant_profile: participant_profile, induction_programme: induction_programme)
        Induction::Enrol.call(participant_profile: primary_participant_profile, induction_programme: induction_programme)
        create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider: cpd_lead_provider)
      end

      let!(:partnership) { create(:partnership, lead_provider: cpd_lead_provider.lead_provider, cohort: cohort, school: school) }

      context "when declarations have been made for a teacher profile with the same trn" do
        subject(:record_started_declaration) do
          RecordDeclarations::Started::EarlyCareerTeacher.call(
            params: {
              participant_id: participant_profile.user_id,
              course_identifier: course_identifier,
              cpd_lead_provider: cpd_lead_provider,
              declaration_date: declaration_date,
              declaration_type: declaration_type,
            },
          )
        end

        context "when declarations have been made for the same CPD lead provider" do
          context "when declarations have been made for the same course" do
            before do
              RecordDeclarations::Started::EarlyCareerTeacher.call(
                params: {
                  participant_id: primary_participant_profile.user_id,
                  course_identifier: "ecf-induction",
                  cpd_lead_provider: cpd_lead_provider,
                  declaration_date: declaration_date,
                  declaration_type: declaration_type,
                },
              )
              participant_profile.reload
              primary_participant_profile.reload
            end

            it "returns those declarations" do
              expected_duplicate = primary_participant_profile
                                     .reload
                                     .participant_declarations
                                     .first

              record_started_declaration

              expect(
                participant_profile
                  .participant_declarations
                  .first
                  .duplicate_declarations,
              ).to eq([expected_duplicate])
            end

            context "when declarations with an original participant declaration already exists" do
              let(:another_duplicate_user) { create(:user) }
              let(:another_duplicate_participant_profile) do
                EarlyCareerTeachers::Create.new(
                  full_name: another_duplicate_user.full_name,
                  email: another_duplicate_user.email,
                  school_cohort: school_cohort,
                  mentor_profile_id: nil,
                  year_2020: false,
                ).call.tap do |pp|
                  StoreValidationResult.new(
                    participant_profile: pp,
                    validation_data: validation_data,
                    dqt_response: dqt_response,
                    deduplicate: false,
                  ).call
                end
              end

              before do
                Induction::Enrol.call(participant_profile: another_duplicate_participant_profile, induction_programme: induction_programme)
                create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider: cpd_lead_provider)
                RecordDeclarations::Started::EarlyCareerTeacher.call(
                  params: {
                    participant_id: another_duplicate_participant_profile.user_id,
                    course_identifier: course_identifier,
                    cpd_lead_provider: cpd_lead_provider,
                    declaration_date: declaration_date,
                    declaration_type: declaration_type,
                  },
                )
              end

              it "returns the original declaration" do
                expected_duplicate = primary_participant_profile
                                       .reload
                                       .participant_declarations
                                       .first

                record_started_declaration

                expect(ParticipantDeclaration.count).to eq(3)

                expect(
                  participant_profile
                    .participant_declarations
                    .first
                    .duplicate_declarations,
                ).to eq([expected_duplicate])
              end
            end
          end

          context "when declarations have been made for a different course" do
            before do
              Induction::Enrol.call(participant_profile: mentor_participant_profile, induction_programme: induction_programme)
              create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now)

              RecordDeclarations::Started::Mentor.call(
                params: {
                  participant_id: mentor_participant_profile.user_id,
                  course_identifier: "ecf-mentor",
                  cpd_lead_provider: cpd_lead_provider,
                  declaration_date: declaration_date,
                  declaration_type: declaration_type,
                },
              )
              participant_profile.reload
              primary_participant_profile.reload
            end

            it "does not return those declarations" do
              record_started_declaration

              expect(ParticipantDeclaration.where(cpd_lead_provider: cpd_lead_provider).count).to eq(2)
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
          RecordDeclarations::Started::EarlyCareerTeacher.call(
            params: {
              participant_id: participant_profile.user_id,
              course_identifier: course_identifier,
              cpd_lead_provider: cpd_lead_provider,
              declaration_date: declaration_date,
              declaration_type: declaration_type,
            },
          )
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
end
