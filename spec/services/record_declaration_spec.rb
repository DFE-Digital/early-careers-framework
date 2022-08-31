# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "validates the declaration_date" do
  describe "#declaration_date" do
    context "when declaration date is invalid" do
      before { params[:declaration_date] = "2021-06-21 08:46:29" }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("The property '#\/declaration_date' must be a valid RCF3339 date")
      end
    end

    context "when declaration date is in future" do
      let(:declaration_date) { (Time.zone.now + 100.years) }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to include("The property '#\/declaration_date' can not declare a future date")
      end
    end

    context "when before the milestone start" do
      let(:declaration_date) { (cutoff_start_datetime - 2.days) }

      it "has a meaningful error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date)).to eq(["The property '#/declaration_date' can not be before milestone start"])
      end
    end

    context "when at the milestone start" do
      let(:declaration_date) { (cutoff_start_datetime + 1.day) }

      it { is_expected.to be_valid }
    end

    context "when in the middle of milestone" do
      let(:declaration_date) { (cutoff_start_datetime + 2.days) }

      it { is_expected.to be_valid }
    end

    context "when at the milestone end" do
      let(:declaration_date) { cutoff_end_datetime }

      it { is_expected.to be_valid }
    end

    context "when after the milestone start" do
      let(:declaration_date) { (cutoff_end_datetime + 1.day) }

      it "has a meaningfull error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date))
          .to eq(["The property '#/declaration_date' can not be after milestone end"])
      end
    end
  end
end

RSpec.shared_examples "validates the declaration for a withdrawn participant" do
  context "when a participant has been withdrawn" do
    let(:traits) { [:withdrawn] }
    before { travel_to(withdrawal_time) { participant_profile } }

    context "when the declaration is backdated before the participant has been withdrawn" do
      let(:withdrawal_time) { declaration_date - 1.second }

      it "has a meaningful error" do
        is_expected.to be_invalid

        expect(service.errors.messages_for(:participant_id)).to eq(["The property '#/participant_id is invalid. The participant was withdrawn from this course on #{withdrawal_time.rfc3339}. You cannot post a declaration with a declaration date after the withdrawal date."])
      end
    end

    context "when the declaration date is made after the participant has been withrawn" do
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
end

RSpec.shared_examples "validates existing declarations" do
  context "when an exisiting declaration already exists" do
    let!(:existing_declaration) do
      described_class.new(params).call
    end

    context "with a close declaration_date" do
      before do
        params[:declaration_date] = (cutoff_start_datetime + 1.day + 1.second).rfc3339
      end

      it "does not create close duplicates and throws an error", :aggregate_failures do
        expect(service).to be_invalid
        expect(service.errors.messages_for(:declaration_date))
          .to eq(["A declaration with the date of #{declaration_date.in_time_zone.rfc3339} already exists."])
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
      participant_profile.schedule.milestones.find_by(declaration_type: "retained-4").destroy!
      params[:declaration_type] = "retained-4"
    end

    it "returns an error" do
      is_expected.to be_invalid
      expect(subject.errors.messages_for(:declaration_type)).to eq(["The property '#/declaration_type does not exist for this schedule"])
    end
  end
end

RSpec.describe RecordDeclaration, :with_default_schedules do
  let(:schedule)              { Finance::Schedule::ECF.find_by(schedule_identifier: "ecf-standard-september") }
  let(:declaration_date)      { schedule.milestones.find_by(declaration_type: "started").start_date }
  let(:cpd_lead_provider)     { create(:cpd_lead_provider, :with_lead_provider) }
  let(:another_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, name: "Unknown") }
  let(:declaration_type)      { "started" }
  let(:params) do
    {
      participant_id: participant_profile.user_id,
      declaration_date: declaration_date.rfc3339,
      declaration_type: ,
      course_identifier:,
      cpd_lead_provider:,
    }
  end

  let(:cutoff_start_datetime) { participant_profile.schedule.milestones.find_by(declaration_type: "started").start_date.beginning_of_day }
  let(:cutoff_end_datetime)   { participant_profile.schedule.milestones.find_by(declaration_type: "started").milestone_date.end_of_day }

  before do
    create(:ecf_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
  end

  subject(:service) do
    described_class.new(params)
  end

  context "when the participant is an ECF" do
    let(:traits)              { [] }
    let(:participant_profile) do
      create(particpant_type, *traits, lead_provider: cpd_lead_provider.lead_provider)
    end

    context "when the participant is an ECT" do
      let(:particpant_type)   { :ect }
      let(:course_identifier) { "ecf-induction" }

      it "creates a participant declaration" do
        expect { service.call }.to change { ParticipantDeclaration.count }.by(1)
      end

      it_behaves_like "validates the declaration_date"
      it_behaves_like "validates the declaration for a withdrawn participant"
      it_behaves_like "validates the course_identifier, cpd_lead_provider, participant_id"
      it_behaves_like "validates existing declarations"
      it_behaves_like "validates the participant milestone"
    end

    context "when the participant is a Mentor" do
      let(:particpant_type) { :mentor }
      let(:course_identifier) { "ecf-mentor" }

      it "creates a participant declaration" do
        expect { service.call }.to change { ParticipantDeclaration.count }.by(1)
      end

      it_behaves_like "validates the declaration_date"
      it_behaves_like "validates the declaration for a withdrawn participant"
      it_behaves_like "validates the course_identifier, cpd_lead_provider, participant_id"
      it_behaves_like "validates existing declarations"
      it_behaves_like "validates the participant milestone"
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
