# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "validates the declaration for a withdrawn participant" do
  context "when a participant has been withdrawn" do
    before do
      travel_to(withdrawal_time - 1.second) do
        %w[npq-leadership-spring npq-leadership-autumn].each do |schedule_identifier|
          create(:npq_leadership_schedule, schedule_identifier:, cohort: Cohort.current)
        end
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

        expect(service.errors.messages_for(:participant_id)).to eq(["This participant withdrew from this course on #{withdrawal_time.rfc3339}. Enter a '#/declaration_date' that's on or before the withdrawal date."])
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
      expect(service.errors.messages_for(:participant_id)).to eq(["Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again."])
    end

    context "when validating evidence held" do
      let(:declaration_type) { "retained-1" }

      it "has meaningful error message", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:participant_id)).to eq(["Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again."])
      end
    end
  end

  context "when lead providers don't match" do
    before { params[:cpd_lead_provider] = another_lead_provider }

    it "has a meaningful error", :aggregate_failures do
      expect(service).to be_invalid
      expect(service.errors.messages_for(:participant_id)).to eq(["Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again."])
    end
  end

  context "when the course is invalid" do
    let(:course_identifier) { "bogus-course-identifier" }

    it "has a meaningful error", :aggregate_failures do
      expect(service).to be_invalid
      expect(service.errors.messages_for(:course_identifier)).to eq(["The entered '#/course_identifier' is not recognised for the given participant. Check details and try again."])
    end
  end

  context "when the declaration date is invalid" do
    context "When the declaration date is empty" do
      before { params[:declaration_date] = "" }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("Enter a '#/declaration_date'.")
      end
    end

    context "when declaration date format is invalid" do
      before { params[:declaration_date] = "2021-06-21 08:46:29" }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("Enter a valid RCF3339 '#/declaration_date'.")
      end
    end

    context "when declaration date is invalid" do
      before { params[:declaration_date] = "2023-19-01T11:21:55Z" }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("Enter a valid RCF3339 '#/declaration_date'.")
      end
    end

    context "when declaration time is invalid" do
      before { params[:declaration_date] = "2023-19-01T29:21:55Z" }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("Enter a valid RCF3339 '#/declaration_date'.")
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
      expect(subject.errors.messages_for(:declaration_type)).to eq(["The property '#/declaration_type' does not exist for this schedule."])
    end
  end
end

RSpec.shared_examples "creates a participant declaration" do
  it "creates a participant declaration" do
    expect { service.call }.to change { ParticipantDeclaration.count }.by(1)
  end

  it "stores the correct data" do
    subject.call

    declaration = ParticipantDeclaration.last

    expect(declaration.declaration_type).to eq(declaration_type)
    expect(declaration.user_id).to eq(participant_profile.user_id)
    expect(declaration.course_identifier).to eq(course_identifier)
    expect(declaration.evidence_held).to eq("other")
    expect(declaration.cpd_lead_provider).to eq(cpd_lead_provider)
  end
end

RSpec.shared_examples "creates participant declaration attempt" do
  context "when user has same ID as participant external ID" do
    it "creates the relevant participant declaration" do
      expect { subject.call }.to change(ParticipantDeclarationAttempt, :count).by(1)
    end

    it "stores the correct data" do
      subject.call

      declaration_attempt = ParticipantDeclarationAttempt.last
      expect(declaration_attempt.declaration_type).to eq(declaration_type)
      expect(declaration_attempt.user_id).to eq(participant_profile.user_id)
      expect(declaration_attempt.course_identifier).to eq(course_identifier)
      expect(declaration_attempt.evidence_held).to eq("other")
      expect(declaration_attempt.cpd_lead_provider).to eq(cpd_lead_provider)
    end
  end

  context "when user has different ID to participant external ID" do
    let(:participant_identity) { create(:participant_identity, :secondary) }

    before { participant_profile.update!(participant_identity:) }

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

RSpec.describe RecordDeclaration do
  let(:cpd_lead_provider)     { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:another_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider, name: "Unknown") }
  let(:declaration_type)      { "started" }
  let(:participant_id) { participant_profile.participant_identity.external_identifier }
  let(:has_passed) { false }
  let(:evidence_held) { "other" }
  let(:params) do
    {
      participant_id:,
      declaration_date: declaration_date.rfc3339,
      declaration_type:,
      course_identifier:,
      cpd_lead_provider:,
      has_passed:,
      evidence_held:,
    }
  end

  let(:cutoff_start_datetime) { participant_profile.schedule.milestones.find_by(declaration_type: "started").start_date.beginning_of_day }
  let(:cutoff_end_datetime)   { participant_profile.schedule.milestones.find_by(declaration_type: "started").milestone_date.end_of_day }

  subject(:service) do
    described_class.new(params)
  end

  let!(:cohort_2020) { create(:cohort, start_year: 2020) }
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

      describe "attributes inferred from induction records" do
        let(:relevant_induction_record) { nil }
        subject(:created_declaration) do
          service.call
          ParticipantDeclaration.last
        end

        before do
          allow(Induction::FindBy).to receive(:call).and_call_original
          allow(Induction::FindBy).to receive(:call).with(
            participant_profile:,
            lead_provider: cpd_lead_provider.lead_provider,
            date_range: ..declaration_date,
          ) { relevant_induction_record }
        end

        it { is_expected.to have_attributes(delivery_partner: nil, mentor_user_id: nil) }

        context "when the relevant induction record has a delivery_partner" do
          let(:relevant_induction_record) { participant_profile.induction_records.latest }
          let(:delivery_partner) { relevant_induction_record.induction_programme.partnership.delivery_partner }

          it { is_expected.to have_attributes(delivery_partner:) }
        end

        context "when the relevant induction record has a mentor_profile" do
          let(:mentor_user) { create(:user, full_name: "Mentor User 1") }
          let(:mentor_profile) { create(:mentor_participant_profile, user: mentor_user) }
          let(:opts) { { mentor_profile: } }
          let(:relevant_induction_record) { participant_profile.induction_records.latest }

          it { is_expected.to have_attributes(mentor_user_id: mentor_user.id) }
        end
      end

      it_behaves_like "validates the declaration for a withdrawn participant"
      it_behaves_like "validates the course_identifier, cpd_lead_provider, participant_id"
      it_behaves_like "validates existing declarations"
      it_behaves_like "validates the participant milestone"
      it_behaves_like "creates a participant declaration"
      it_behaves_like "creates participant declaration attempt"
    end

    context "when the participant is a Mentor" do
      let(:participant_type) { :mentor }
      let(:course_identifier) { "ecf-mentor" }

      it_behaves_like "validates the declaration for a withdrawn participant"
      it_behaves_like "validates the course_identifier, cpd_lead_provider, participant_id"
      it_behaves_like "validates existing declarations"
      it_behaves_like "validates the participant milestone"
      it_behaves_like "creates a participant declaration"
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
    let!(:npq_contract) { create(:npq_contract, cohort: schedule.cohort, npq_course:, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
    let!(:another_npq_cohort_contract) { create(:npq_contract, cohort: cohort_2020, npq_course:, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }

    before do
      create(:npq_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
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
    it_behaves_like "creates a participant declaration"
    it_behaves_like "creates participant declaration attempt"

    context "for next cohort" do
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

    context "when submitting completed" do
      let(:declaration_type) { "completed" }
      let(:declaration_date) { schedule.milestones.find_by(declaration_type:).start_date + 1.day }

      context "has_passed is nil" do
        let(:has_passed) { nil }

        it "returns error" do
          expect(service).to be_invalid
          expect(service.errors.messages_for(:has_passed)).to eq(["Enter 'true' or 'false' in the '#/has_passed' field to indicate whether this participant has passed or failed their course."])
        end
      end

      context "has_passed is invalid text" do
        let(:has_passed) { "no_supported" }

        it "returns error" do
          expect(service).to be_invalid
          expect(service.errors.messages_for(:has_passed)).to eq(["Enter 'true' or 'false' in the '#/has_passed' field to indicate whether this participant has passed or failed their course."])
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

      context "when CreateParticipantOutcome service class is invalid" do
        before do
          allow_any_instance_of(NPQ::CreateParticipantOutcome).to receive(:valid?).and_return(false)
        end

        it "raises an InvalidParticipantOutcomeError" do
          expect(ParticipantDeclaration::NPQ.completed.count).to be(0)
          expect { service.call }.to raise_error(Api::Errors::InvalidParticipantOutcomeError)
          expect(ParticipantDeclaration::NPQ.completed.count).to be(0)
        end
      end
    end

    context "when lead provider has no contract for the cohort and course" do
      before { npq_contract.update!(npq_course: create(:npq_specialist_course)) }

      it "has a meaningful error" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:cohort)).to include("You cannot submit a declaration for this participant as you do not have a contract for the cohort and course. Contact the DfE for assistance.")
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
    let!(:school_cohort_2020) { create(:school_cohort, cohort: cohort_2020, school: participant_profile.school) }

    before do
      induction_programme.update!(school_cohort: school_cohort_2020)
    end

    xit "raises a ParameterMissing error" do
      expect { described_class.new(params).call }.to raise_error(ActionController::ParameterMissing)
    end
  end
end
