# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "checks for mentor completion event" do
  it "calls the ParticipantDeclarations::HandleMentorCompletion service" do
    expect_any_instance_of(ParticipantDeclarations::HandleMentorCompletion).to receive(:call)
    subject.call
  end
end

RSpec.shared_examples "validates the next output fee statement is available" do
  context "when there are no available output fee statements" do
    before { Finance::Statement.update!(output_fee: false) }

    context "when the declarations is submitted" do
      it { is_expected.to be_valid }
    end

    context "when the declaration is eligible" do
      it "returns an error" do
        create(:ecf_participant_eligibility, :eligible, participant_profile:)

        expect(service).to be_invalid

        cohort = participant_profile.schedule.cohort.start_year
        expect(service.errors.messages_for(:cohort)).to include(/You cannot submit or void declarations for the #{cohort}/)
      end
    end

    context "when there is an existing billable declaration" do
      before do
        existing_declaration = described_class.new(params).call
        existing_declaration.update!(state: :paid)
      end

      it "returns an error" do
        expect(service).to be_invalid

        cohort = participant_profile.schedule.cohort.start_year
        expect(service.errors.messages_for(:cohort)).to include(/You cannot submit or void declarations for the #{cohort}/)
      end
    end
  end
end

RSpec.shared_examples "validates the declaration for a withdrawn participant" do
  context "when a participant has been withdrawn" do
    before do
      travel_to(withdrawal_time - 1.second) do
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
    expect(declaration.cohort).to eq(schedule.cohort)
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
  let(:cpd_lead_provider)     { create(:cpd_lead_provider, :with_lead_provider) }
  let(:another_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "Unknown") }
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

      it_behaves_like "validates the next output fee statement is available"
      it_behaves_like "validates the declaration for a withdrawn participant"
      it_behaves_like "validates the course_identifier, cpd_lead_provider, participant_id"
      it_behaves_like "validates existing declarations"
      it_behaves_like "validates the participant milestone"
      it_behaves_like "creates a participant declaration"
      it_behaves_like "creates participant declaration attempt"
      it_behaves_like "checks for mentor completion event"
    end

    context "when the participant is a Mentor" do
      let(:participant_type) { :mentor }
      let(:course_identifier) { "ecf-mentor" }

      it_behaves_like "validates the next output fee statement is available"
      it_behaves_like "validates the declaration for a withdrawn participant"
      it_behaves_like "validates the course_identifier, cpd_lead_provider, participant_id"
      it_behaves_like "validates existing declarations"
      it_behaves_like "validates the participant milestone"
      it_behaves_like "creates a participant declaration"
      it_behaves_like "creates participant declaration attempt"
      it_behaves_like "checks for mentor completion event"
    end

    context "when recording an NPQ declaration" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
      let(:participant_profile) do
        create(:npq_participant_profile, npq_lead_provider: cpd_lead_provider.npq_lead_provider)
      end
      let(:course_identifier) { participant_profile.npq_course.identifier }

      # TODO: remove this in the end of separation cleanup as RecordDeclaration is being used everywhere in specs
      before { FeatureFlag.activate(:disable_npq) }

      it "returns error" do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:course_identifier)).to eq(["NPQ Courses are no longer supported"])
      end
    end
  end

  context "when re-posting after a clawback" do
    let(:lead_provider) { cpd_lead_provider.lead_provider }
    let(:participant_profile) { create(:ect, :eligible_for_funding, lead_provider:) }
    let(:schedule) { Finance::Schedule::ECF.find_by(schedule_identifier: "ecf-standard-september", cohort: current_cohort) }
    let(:declaration_date) { participant_profile.schedule.milestones.find_by(declaration_type: "started").start_date }
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
