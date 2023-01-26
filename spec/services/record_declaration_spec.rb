# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "validates the declaration for a withdrawn participant" do
  context "when a participant has been withdrawn" do
    before do
      travel_to(withdrawal_time - 1.second) do
        create(:npq_leadership_schedule, cohort: Cohort.current)
        participant_profile
      end

      travel_to(withdrawal_time) do
        WithdrawParticipant.new(
          participant_id: participant_profile.participant_identity.external_identifier,
          cpd_lead_provider:,
          reason: "other",
          course_identifier:,
        ).call
      end
    end

    context "when the declaration is made after the participant has been withdrawn" do
      let(:withdrawal_time) { declaration_date - 1.second }

      it "has a meaningful error" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:participant_id)).to eq(["The property '#/participant_id is invalid. The participant was withdrawn from this course on #{withdrawal_time.rfc3339}. You cannot post a declaration with a declaration date after the withdrawal date."])
      end
    end

    context "when the declaration is backdated before the participant has been withdrawn" do
      let(:withdrawal_time) { declaration_date + 1.second }

      it { is_expected.to be_valid }
    end
  end
end

RSpec.shared_examples "validates the course_identifier, cpd_lead_provider, participant_id" do
  context "when user is not a participant" do
    let(:induction_coordinator_profile) { create(:induction_coordinator_profile) }
    before { params[:participant_id] = induction_coordinator_profile.user_id }

    it "has meaningful error message", :aggregate_failures do
      expect(service).to be_invalid
      expect(service.errors.messages_for(:participant_id)).to eq(["The property '#/participant_id' must be a valid Participant ID"])
    end

    context "when validating evidence held" do
      let(:declaration_type) { "retained-1" }
      before do
        params[:evidence_held] = "other"
      end

      it "has meaningful error message", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:participant_id)).to eq(["The property '#/participant_id' must be a valid Participant ID"])
      end
    end
  end

  context "when lead providers don't match" do
    before { params[:cpd_lead_provider] = another_lead_provider }

    it "has a meaningful error", :aggregate_failures do
      expect(service).to be_invalid
      expect(service.errors.messages_for(:participant_id)).to eq(["The property '#/participant_id' must be a valid Participant ID"])
    end
  end

  context "when the course is invalid" do
    let(:course_identifier) { "bogus-course-identifier" }

    it "has a meaningful error", :aggregate_failures do
      expect(service).to be_invalid
      expect(service.errors.messages_for(:course_identifier)).to eq(["The property '#/course_identifier' must be an available course to '#/participant_id'"])
    end
  end

  context "when the declaration date is invalid" do
    context "When the declaration date is empty" do
      before { params[:declaration_date] = "" }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("The property '#/declaration_date' must be present")
      end
    end

    context "when declaration date format is invalid" do
      before { params[:declaration_date] = "2021-06-21 08:46:29" }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("The property '#\/declaration_date' must be a valid RCF3339 date")
      end
    end

    context "when declaration date is invalid" do
      before { params[:declaration_date] = "2023-19-01T11:21:55Z" }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("The property '#\/declaration_date' must be a valid RCF3339 date")
      end
    end

    context "when declaration time is invalid" do
      before { params[:declaration_date] = "2023-19-01T29:21:55Z" }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("The property '#\/declaration_date' must be a valid RCF3339 date")
      end
    end
  end
end

RSpec.shared_examples "validates existing declarations" do
  context "when an existing declaration already exists" do
    let!(:existing_declaration) do
      described_class.new(params).call
    end

    context "with a close declaration_date" do
      before do
        params[:declaration_date] = (cutoff_start_datetime + 1.day + 1.second).rfc3339
      end

      it "does not create close duplicates and throws an error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:base))
          .to eql(["A declaration has already been submitted that will be, or has been, paid for this event"])
      end
    end

    context "when the state submitted" do
      it "does create duplicates" do
        expect { service.call }.not_to change(ParticipantDeclaration, :count)
        expect(existing_declaration.reload).to be_submitted
      end
    end

    context "with an fundable participant" do
      let(:traits) { [:eligible_for_funding] }

      context "when the state eligible" do
        it "does not create duplicates" do
          expect { service.call }.not_to change(ParticipantDeclaration, :count)
          expect(existing_declaration.reload).to be_eligible
        end
      end

      context "when the state payable" do
        before do
          existing_declaration.make_payable!
        end

        it "does not create duplicates" do
          expect { service.call }.not_to change(ParticipantDeclaration, :count)
          expect(existing_declaration.reload).to be_payable
        end

        context "when the state paid" do
          before do
            existing_declaration.make_paid!
          end

          it "does not create duplicates" do
            expect { service.call }.not_to change(ParticipantDeclaration, :count)
            expect(existing_declaration.reload).to be_paid
          end
        end
      end
    end
  end
end

RSpec.shared_examples "validates the participant milestone" do
  context "when milestone has null milestone_date" do
    before do
      Finance::Milestone.find_by(declaration_type: "started").update!(milestone_date: nil)
    end

    it "does not have errors on milestone_date" do
      expect { subject.call }.not_to raise_error
    end
  end

  context "when milestone has null milestone_date" do
    before do
      Finance::Milestone.find_by(declaration_type: "started").update!(milestone_date: nil)
    end

    it "does not have errors on milestone_date" do
      expect { subject.call }.not_to raise_error
    end
  end

  context "when declaration_type does not exist for the schedule" do
    before do
      params[:declaration_type] = "does-not-exist"
    end

    it "returns an error" do
      is_expected.to be_invalid
      expect(subject.errors.messages_for(:declaration_type)).to eq(["The property '#/declaration_type does not exist for this schedule"])
    end
  end
end

RSpec.shared_examples "creates participant declaration attempt" do
  context "when user has same ID as participant external ID" do
    it "creates the relevant participant declaration" do
      expect { subject.call }.to change(ParticipantDeclarationAttempt, :count).by(1)
    end
  end

  context "when user has different ID to participant external ID" do
    let(:participant_identity) { create(:participant_identity, :secondary) }
    let(:opts) { { participant_identity: } }

    it "creates the relevant participant declaration" do
      expect { subject.call }.to change(ParticipantDeclarationAttempt, :count).by(1)
    end
  end

  context "with incorrect participant ID" do
    let(:participant_id) { "non-existent-user" }

    it "does not create the relevant participant declaration" do
      expect { subject.call }.not_to change(ParticipantDeclarationAttempt, :count)
    end
  end
end

RSpec.describe RecordDeclaration, :with_default_schedules do
  let(:cpd_lead_provider)     { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:another_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider, name: "Unknown") }
  let(:declaration_type)      { "started" }
  let(:participant_id) { participant_profile.participant_identity.external_identifier }
  let(:has_passed) { false }
  let(:params) do
    {
      participant_id:,
      declaration_date: declaration_date.rfc3339,
      declaration_type:,
      course_identifier:,
      cpd_lead_provider:,
      has_passed:,
    }
  end

  let(:cutoff_start_datetime) { participant_profile.schedule.milestones.find_by(declaration_type: "started").start_date.beginning_of_day }
  let(:cutoff_end_datetime)   { participant_profile.schedule.milestones.find_by(declaration_type: "started").milestone_date.end_of_day }

  subject(:service) do
    described_class.new(params)
  end

  let!(:current_cohort) { Cohort.current || create(:cohort, :current) }
  let!(:previous_cohort) { Cohort.current.previous || create(:cohort, start_year: Cohort.current.start_year - 1) }

  context "when the participant is an ECF" do
    let(:schedule)              { Finance::Schedule::ECF.find_by(schedule_identifier: "ecf-standard-september", cohort: current_cohort) }
    let(:declaration_date)      { schedule.milestones.find_by(declaration_type: "started").start_date }
    let(:traits)                { [] }
    let(:opts)                  { {} }
    let(:participant_profile) do
      create(participant_type, *traits, **opts, lead_provider: cpd_lead_provider.lead_provider)
    end

    before do
      Finance::Schedule::ECF.default_for(cohort: current_cohort)  || create(:ecf_schedule, cohort: current_cohort)
      Finance::Schedule::ECF.default_for(cohort: previous_cohort) || create(:ecf_schedule, cohort: previous_cohort)
      create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
    end

    context "when the participant is an ECT" do
      let(:participant_type) { :ect }
      let(:course_identifier) { "ecf-induction" }
      let(:delivery_partner) { participant_profile.induction_records[0].induction_programme.partnership.delivery_partner }

      it "creates a participant declaration" do
        expect { service.call }.to change { ParticipantDeclaration.count }.by(1)
      end

      it "stores the known delivery partner" do
        service.call

        declaration = ParticipantDeclaration.last

        expect(declaration.delivery_partner).to eql(delivery_partner)
      end

      it_behaves_like "validates the declaration for a withdrawn participant"
      it_behaves_like "validates the course_identifier, cpd_lead_provider, participant_id"
      it_behaves_like "validates existing declarations"
      it_behaves_like "validates the participant milestone"
      it_behaves_like "creates participant declaration attempt"
    end

    context "when the participant is a Mentor" do
      let(:participant_type) { :mentor }
      let(:course_identifier) { "ecf-mentor" }

      it "creates a participant declaration" do
        expect { service.call }.to change { ParticipantDeclaration.count }.by(1)
      end

      it_behaves_like "validates the declaration for a withdrawn participant"
      it_behaves_like "validates the course_identifier, cpd_lead_provider, participant_id"
      it_behaves_like "validates existing declarations"
      it_behaves_like "validates the participant milestone"

      it_behaves_like "creates participant declaration attempt"
    end
  end

  context "when the participant is an NPQ" do
    let(:schedule) { NPQCourse.schedule_for(npq_course:, cohort: current_cohort) }
    let(:declaration_date) { schedule.milestones.find_by(declaration_type:).start_date }
    let(:npq_course) { create(:npq_leadership_course) }
    let(:traits) { [] }
    let(:participant_profile) do
      create(:npq_participant_profile, *traits, npq_lead_provider: cpd_lead_provider.npq_lead_provider, npq_course:)
    end
    let(:course_identifier) { npq_course.identifier }

    before do
      create(:npq_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
    end

    it "creates a participant declaration" do
      expect { service.call }.to change { ParticipantDeclaration.count }.by(1)
    end

    context "when submitting a retained-1" do
      let(:declaration_type) { "retained-1" }

      it "creates a declaration, no need to pass evidence_held" do
        expect(service).to be_valid
      end
    end

    it_behaves_like "validates the declaration for a withdrawn participant"
    it_behaves_like "validates the course_identifier, cpd_lead_provider, participant_id"
    it_behaves_like "validates existing declarations"
    it_behaves_like "validates the participant milestone"
    it_behaves_like "creates participant declaration attempt"

    context "for next cohort", :with_default_schedules do
      let!(:schedule) { create(:npq_specialist_schedule, cohort:) }
      let!(:statement) { create(:npq_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:, cohort:) }

      let(:cohort) { Cohort.next || create(:cohort, :next) }
      let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
      let(:participant_profile) { create(:npq_participant_profile, :eligible_for_funding, npq_lead_provider:, npq_course:, schedule:) }
      let(:declaration_date) { schedule.milestones.find_by(declaration_type: "started").start_date }

      it "creates declaration to next cohort statement" do
        expect { service.call }.to change { ParticipantDeclaration.count }.by(1)

        declaration = ParticipantDeclaration.last

        expect(declaration).to be_eligible
        expect(declaration.statements).to include(statement)
      end
    end

    context "when submitting completed", with_feature_flags: { participant_outcomes_feature: "active" } do
      let(:declaration_type) { "completed" }
      let(:declaration_date) { schedule.milestones.find_by(declaration_type:).start_date + 1.day }

      context "has_passed is nil" do
        let(:has_passed) { nil }

        it "returns error" do
          expect(service).to be_invalid
          expect(service.errors.messages_for(:has_passed)).to eq(["The attribute '#/has_passed' must be included as part of 'completed' declaration submissions. Values can be 'true' or 'false' to indicate whether the participant has passed or failed their course"])
        end
      end

      context "has_passed is invalid text" do
        let(:has_passed) { "no_supported" }

        it "returns error" do
          expect(service).to be_invalid
          expect(service.errors.messages_for(:has_passed)).to eq(["The attribute '#/has_passed' can only include 'true' or 'false' values to indicate whether the participant has passed or failed their course"])
        end
      end

      context "has_passed is true" do
        let(:has_passed) { true }

        it "creates participant outcome" do
          travel_to declaration_date do
            expect(service).to be_valid
            participant_declaration = service.call
            expect(participant_declaration.outcomes.count).to be(1)

            outcome = participant_declaration.outcomes.first
            expect(outcome.completion_date).to eql(participant_declaration.declaration_date.to_date)
            expect(outcome).to be_passed
          end
        end
      end

      context "has_passed is 'true'" do
        let(:has_passed) { "true" }

        it "creates participant outcome" do
          travel_to declaration_date do
            expect(service).to be_valid
            participant_declaration = service.call
            expect(participant_declaration.outcomes.count).to be(1)

            outcome = participant_declaration.outcomes.first
            expect(outcome.completion_date).to eql(participant_declaration.declaration_date.to_date)
            expect(outcome).to be_passed
          end
        end
      end

      context "has_passed is false" do
        let(:has_passed) { false }

        it "does not create participant outcome" do
          travel_to declaration_date do
            expect(service).to be_valid
            participant_declaration = service.call
            expect(participant_declaration.outcomes.count).to be(1)

            outcome = participant_declaration.outcomes.first
            expect(outcome.completion_date).to eql(participant_declaration.declaration_date.to_date)
            expect(outcome).to be_failed
          end
        end
      end

      context "has_passed is 'false'" do
        let(:has_passed) { "false" }

        it "does not create participant outcome" do
          travel_to declaration_date do
            expect(service).to be_valid
            participant_declaration = service.call
            expect(participant_declaration.outcomes.count).to be(1)

            outcome = participant_declaration.outcomes.first
            expect(outcome.completion_date).to eql(participant_declaration.declaration_date.to_date)
            expect(outcome).to be_failed
          end
        end
      end

      context "ehco course identifier" do
        let!(:npq_ehco_schedule) { create(:npq_ehco_schedule) }
        let(:npq_course) { create(:npq_ehco_course) }
        let(:has_passed) { nil }

        it "does not create participant outcome" do
          travel_to declaration_date do
            expect(ParticipantOutcome::NPQ.count).to be(0)
            expect(service).to be_valid
            service.call
            expect(ParticipantOutcome::NPQ.count).to be(0)
          end
        end
      end

      context "aso course identifier" do
        let!(:npq_aso_schedule) { create(:npq_aso_schedule) }
        let(:npq_course) { create(:npq_aso_course) }
        let(:has_passed) { nil }

        it "does not create participant outcome" do
          travel_to declaration_date do
            expect(ParticipantOutcome::NPQ.count).to be(0)
            expect(service).to be_valid
            service.call
            expect(ParticipantOutcome::NPQ.count).to be(0)
          end
        end
      end
    end
  end

  context "when re-posting after a clawback" do
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:participant_profile) { create(:ect, :eligible_for_funding, lead_provider:) }
    let(:schedule) { Finance::Schedule::ECF.find_by(schedule_identifier: "ecf-standard-september", cohort: current_cohort) }
    let(:declaration_date) { schedule.milestones.find_by(declaration_type: "started").start_date }
    let(:course_identifier) { "ecf-induction" }

    before do
      create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
    end

    it "creates the second declaration" do
      participant_declaration = described_class.new(params).call

      statement = participant_declaration.statements[0]

      service = ParticipantDeclarations::MarkAsPayable.new(statement)
      service.call(participant_declaration)

      service = ParticipantDeclarations::MarkAsPaid.new(statement)
      service.call(participant_declaration)

      Finance::ClawbackDeclaration.new(participant_declaration).call

      params[:declaration_date] = (declaration_date + 1.second).rfc3339

      expect { subject.call }.to change(ParticipantDeclaration, :count).by(1)
    end
  end

  context "when user is for 2020 cohort" do
    let!(:cohort_2020) { create(:cohort, start_year: 2020) }
    let!(:school_cohort_2020) { create(:school_cohort, cohort: cohort_2020, school: participant_profile.school) }

    before do
      induction_programme.update!(school_cohort: school_cohort_2020)
    end

    xit "raises a ParameterMissing error" do
      expect { described_class.new(params).call }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
