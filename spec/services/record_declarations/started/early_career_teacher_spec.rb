# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Started::EarlyCareerTeacher do
  let(:declaration_date_object) { Date.new(2021, 10, 1) }
  let(:declaration_date) { declaration_date_object.rfc3339 }

  let(:user) { profile.user }
  let(:profile) { create(:ect_participant_profile) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }

  let(:school_cohort) { create(:school_cohort) }
  let(:school) { school_cohort.school }
  let(:cohort) { school_cohort.cohort }

  let(:partnership) { create(:partnership, school:, lead_provider:, cohort:) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership:) }

  let(:participant_id) { profile.user.id }
  let(:course_identifier) { "ecf-induction" }
  let(:declaration_type) { "started" }

  subject do
    described_class.new(
      params: {
        participant_id:,
        course_identifier:,
        cpd_lead_provider:,
        declaration_date:,
        declaration_type:,
      },
    )
  end

  context "when evidence_held is provided" do
    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    subject do
      described_class.new(
        params: {
          participant_id:,
          course_identifier:,
          cpd_lead_provider:,
          declaration_date:,
          declaration_type:,
          evidence_held: "foo",
        },
      )
    end

    it "ignores the superfluous parameter" do
      expect {
        subject.call
      }.to change {
        profile
          .participant_declarations
          .where(
            declaration_date:,
            course_identifier:,
            declaration_type:,
            evidence_held: nil,
          ).count
      }.by(1)
    end
  end

  context "when another lead provider makes the call" do
    let(:other_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:other_lead_provider) { other_cpd_lead_provider.lead_provider }

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    subject do
      described_class.new(
        params: {
          participant_id:,
          course_identifier:,
          cpd_lead_provider: other_cpd_lead_provider,
          declaration_date:,
          declaration_type:,
        },
      )
    end

    it "raises an error" do
      expect { subject.call }.to raise_error(ActionController::ParameterMissing, /The property '#\/participant_id' must be a valid Participant ID/)
    end
  end

  context "creating a declaration" do
    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    it "creates the declaration" do
      expect {
        subject.call
      }.to change {
        profile
          .participant_declarations
          .where(
            declaration_date:,
            course_identifier:,
            declaration_type:,
            evidence_held: nil,
          ).count
      }.by(1)
    end

    context "if called a subsequent time" do
      before do
        subject.call
      end

      it "does not create duplicates" do
        expect {
          subject.call
        }.to raise_error(ActionController::ParameterMissing, /There already exists a declaration that will be or has been paid for this event/)
         .and not_change { ParticipantDeclaration.count }
      end
    end
  end

  context "when declaration date is invalid" do
    let(:declaration_date) { "foo #{Date.new(2021, 10, 1).rfc3339} bar" }

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    it "raises an error" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /The property '#\/declaration_date' must be a valid RCF3339 date/)
    end
  end

  context "when declaration date is in the future" do
    let(:declaration_date) { 10.years.from_now.rfc3339 }

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    it "raises an error" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /The property '#\/declaration_date' can not declare a future date/)
    end
  end

  context "when declaration_date before milestone start" do
    let(:declaration_date) { (Finance::Milestone.pluck(:start_date).min - 10.days).rfc3339 }

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    it "raises an error" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /The property '#\/declaration_date' can not be before milestone start/)
    end
  end

  context "when declaration_date after milestone end" do
    let(:declaration_date) { Date.new(2021, 12, 1).rfc3339 }

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    it "raises an error" do
      expect {
        travel_to Date.new(2021, 12, 20)

        subject.call

        travel_back
      }.to raise_error(ActionController::ParameterMissing, /The property '#\/declaration_date' can not be after milestone end/)
    end
  end

  context "when user profile ParticipantProfileState is withdrawn, but was active on declaration date" do
    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call

      Participants::Withdraw::EarlyCareerTeacher.call(
        params: {
          participant_id: user.id,
          course_identifier:,
          cpd_lead_provider:,
          reason: "left-teaching-profession",
        },
      )
    end

    it "creates the declaration" do
      expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)
    end
  end

  context "when user profile ParticipantProfileState is withdrawn and also withdrawn on declaration date" do
    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call

      travel_to(declaration_date_object - 2.days) do
        Participants::Withdraw::EarlyCareerTeacher.call(
          params: {
            participant_id: user.id,
            course_identifier:,
            cpd_lead_provider:,
            reason: "left-teaching-profession",
          },
        )
      end
    end

    it "does not create the declaration" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /Declaration must be before withdrawal date/)
       .and not_change { ParticipantDeclaration.count }
    end
  end

  context "when user profile ParticipantProfileState is deferred, but was active on declaration date" do
    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
      create(:participant_profile_state, :deferred, participant_profile: profile, cpd_lead_provider:)
    end

    it "creates the declaration" do
      expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)
    end
  end

  context "when incorrect course provided" do
    let(:course_identifier) { "ecf-mentor" }

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    it "does not create the declaration" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /The property '#\/course_identifier' must be an available course to '#\/participant_id'/)
       .and not_change { ParticipantDeclaration.count }
    end
  end

  context "when NPQ course provided" do
    let(:course_identifier) { "npq-leading-teacher" }

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    it "does not create the declaration" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /The property '#\/course_identifier' must be an available course to '#\/participant_id'/)
       .and not_change { ParticipantDeclaration.count }
    end
  end

  context "when user is for 2020 cohort (ie NQT+1)" do
    let(:school_cohort) { create(:school_cohort, cohort:) }
    let(:cohort) { create(:cohort, start_year: 2020) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership:, school_cohort:) }

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    it "does not create the declaration" do
      expect {
        subject.call
      }.to raise_error(ActionController::ParameterMissing, /The property '#\/participant_id' must be a valid Participant ID/)
       .and not_change { ParticipantDeclaration.count }
    end
  end

  context "re-declaring after a clawback" do
    let!(:declaration) do
      create(
        :ect_participant_declaration,
        :awaiting_clawback,
        user:,
        participant_profile: profile,
        cpd_lead_provider:,
      )
    end

    let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile: profile) }

    let!(:statement) do
      create(
        :ecf_statement,
        :output_fee,
        cpd_lead_provider:,
        deadline_date: 6.months.from_now,
        payment_date: 7.months.from_now,
      )
    end

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    it "creates the declaration as eligible" do
      expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)

      declaration = ParticipantDeclaration.order(created_at: :asc).last

      expect(declaration).to be_eligible
    end
  end

  context "when declaring for a participant in 2022" do
    let(:school_cohort) { create(:school_cohort, cohort:) }
    let(:cohort) { create(:cohort, start_year: 2022) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership:, school_cohort:) }
    let(:schedule) { create(:ecf_schedule, cohort:) }
    let(:profile) { create(:ect_participant_profile, schedule:) }

    before do
      Induction::Enrol.new(induction_programme:, participant_profile: profile).call
    end

    let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile: profile) }

    let!(:statement) do
      create(
        :ecf_statement,
        :output_fee,
        cpd_lead_provider:,
        deadline_date: 6.months.from_now,
        payment_date: 7.months.from_now,
        cohort:,
      )
    end

    it "accepts the declaration as eligible" do
      expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)

      declaration = ParticipantDeclaration.order(created_at: :asc).last

      expect(declaration).to be_eligible
    end
  end
end
