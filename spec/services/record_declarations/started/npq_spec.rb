# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Started::NPQ do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_application) { create(:npq_application, npq_lead_provider:) }
  let(:profile) { create(:npq_participant_profile, npq_application:) }
  let(:user) { profile.user }
  let(:npq_course) { profile.npq_course }
  let(:declaration_date) { profile.schedule.milestones.where(declaration_type: "started").first.start_date + 10.days }
  let(:declaration_date_string) { declaration_date.rfc3339 }

  before do
    create(:npq_statement, :output_fee, deadline_date: 6.weeks.from_now, cpd_lead_provider:)
  end

  subject do
    described_class.new(
      params: {
        participant_id: user.id,
        course_identifier: npq_course.identifier,
        cpd_lead_provider:,
        declaration_date: declaration_date_string,
        declaration_type: "started",
      },
    )
  end

  it "creates a participant declaration" do
    expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)
  end

  it "does not creates exact duplicates" do
    expect {
      described_class.new(
        params: {
          participant_id: user.id,
          course_identifier: npq_course.identifier,
          cpd_lead_provider:,
          declaration_date: (profile.schedule.milestones.where(declaration_type: "started").first.start_date + 10.days).rfc3339,
          declaration_type: "started",
        },
      ).call
    }.to change { ParticipantDeclaration.count }.by(1)

    expect {
      described_class.new(
        params: {
          participant_id: user.id,
          course_identifier: npq_course.identifier,
          cpd_lead_provider:,
          declaration_date: (profile.schedule.milestones.where(declaration_type: "started").first.start_date + 10.days).rfc3339,
          declaration_type: "started",
        },
      ).call
    }.to raise_error(ActionController::ParameterMissing)
     .and not_change { ParticipantDeclaration.count }
  end

  it "does not create close duplicates and throws an error" do
    expect {
      subject.call

      described_class.new(
        params: {
          participant_id: user.id,
          course_identifier: npq_course.identifier,
          cpd_lead_provider:,
          declaration_date: (profile.schedule.milestones.where(declaration_type: "started").first.start_date + 11.days).rfc3339,
          declaration_type: "started",
        },
      ).call
    }.to raise_error(ActionController::ParameterMissing)
  end

  context "when lead providers don't match" do
    let(:another_cpd_lead_provider) { create(:cpd_lead_provider) }

    subject do
      described_class.new(
        params: {
          participant_id: user.id,
          course_identifier: npq_course.identifier,
          cpd_lead_provider: another_cpd_lead_provider,
          declaration_date: (profile.schedule.milestones.where(declaration_type: "started").first.start_date + 10.days).rfc3339,
          declaration_type: "started",
        },
      )
    end

    it "raises a ParameterMissing error" do
      expect { subject.call }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when user is not a participant" do
    let(:user) { OpenStruct.new(id: SecureRandom.uuid) }

    it "does not create a declaration record and raises ParameterMissing for an invalid user_id" do
      expect { subject.call }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "when declaration date is invalid" do
    let(:declaration_date_string) { "2021-06-21 08:46:29" }

    it "raises ParameterMissing error" do
      expected_msg = /The property '#\/declaration_date' must be a valid RCF3339 date/
      expect { subject.call }.to raise_error(ActionController::ParameterMissing, expected_msg)
    end
  end

  context "when declaration date is in future" do
    let(:declaration_date) { Time.zone.now + 100.years }

    it "raised ParameterMissing error" do
      expected_msg = /The property '#\/declaration_date' can not declare a future date/
      expect { subject.call }.to raise_error(ActionController::ParameterMissing, expected_msg)
    end
  end

  context "when declaration date is in the past" do
    let(:declaration_date) { Time.zone.now - 1.day }

    it "does not raise ParameterMissing error" do
      expect { subject.call }.to_not raise_error
    end
  end

  context "when declaration date is today" do
    let(:declaration_date) { Time.zone.now }

    it "does not raise ParameterMissing error" do
      expect { subject.call }.to_not raise_error
    end
  end

  context "when before the milestone start" do
    let(:declaration_date) { profile.schedule.milestones.where(declaration_type: "started").first.start_date - 10.days }

    it "raises ParameterMissing error" do
      expect { subject.call }.to raise_error(ActionController::ParameterMissing)
    end
  end

  context "user profile is in a withdrawn state, but was active on declaration date" do
    let(:profile) { create(:npq_participant_profile, npq_application:, training_status: "withdrawn") }

    before do
      ParticipantProfileState.create!(participant_profile: profile, state: "active", cpd_lead_provider:, created_at: declaration_date - 2.days)
    end

    it "succeeds" do
      expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)
    end
  end

  context "profile is in a deferred state, but was active on declaration date" do
    let(:profile) { create(:npq_participant_profile, npq_application:, training_status: "deferred") }

    before do
      ParticipantProfileState.create!(participant_profile: profile, state: "active", created_at: declaration_date - 2.days)
    end

    it "succeeds" do
      expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)
    end
  end

  context "when including evidence_held" do
    subject do
      described_class.new(
        params: {
          participant_id: user.id,
          course_identifier: npq_course.identifier,
          cpd_lead_provider:,
          declaration_date: declaration_date_string,
          declaration_type: "started",
          evidence_held: "self-study-material-completed",
        },
      )
    end

    it "ignores the extra parameter" do
      expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)
      expect(ParticipantDeclaration.order(created_at: :desc).first.evidence_held).to be_nil
    end
  end

  context "when declaring for a participant in 2022" do
    let(:cohort) { create(:cohort, start_year: 2022) }

    let(:npq_application) { create(:npq_application, :funded, npq_lead_provider:, cohort:) }

    let(:schedule_factory) do
      case npq_course.identifier
      when "npq-leading-teaching", "npq-leading-behaviour-culture", "npq-leading-teaching-development", "npq-leading-literacy"
        :npq_specialist_schedule
      when "npq-senior-leadership", "npq-headship", "npq-executive-leadership", "npq-early-years-leadership"
        :npq_leadership_schedule
      when "npq-additional-support-offer"
        :npq_aso_schedule
      when "npq-early-headship-coaching-offer"
        :npq_ehco_schedule
      else
        raise
      end
    end

    let(:schedule) { create(schedule_factory, cohort:) }

    let!(:statement) do
      create(
        :npq_statement,
        :output_fee,
        cpd_lead_provider:,
        deadline_date: 6.months.from_now,
        payment_date: 7.months.from_now,
        cohort:,
      )
    end

    before do
      profile.update!(schedule:)
    end

    it "accepts the declaration as eligible" do
      expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)

      declaration = ParticipantDeclaration.order(created_at: :asc).last

      expect(declaration).to be_eligible
      expect(declaration.statements).to include(statement)
    end
  end
end
