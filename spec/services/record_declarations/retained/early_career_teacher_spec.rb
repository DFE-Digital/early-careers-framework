# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Retained::EarlyCareerTeacher do
  let(:profile) { create(:ect_participant_profile, schedule:) }
  let(:user) { profile.user }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:declaration_date) { Date.new(2021, 11, 10) }
  let(:declaration_type) { "retained-1" }
  let(:schedule) { create(:ecf_schedule) }
  let(:cohort) { Cohort.current || create(:cohort, start_year: 2021) }
  let(:school_cohort) { create(:school_cohort, cohort:, school: profile.school) }
  let(:partnership) { create(:partnership, school: profile.school, lead_provider:, cohort:) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership:, school_cohort:) }

  before do
    Induction::Enrol.call(participant_profile: profile, induction_programme:)
  end

  context "happy path" do
    subject do
      described_class.new(
        params: {
          participant_id: user.id,
          course_identifier: "ecf-induction",
          cpd_lead_provider:,
          declaration_date: declaration_date.rfc3339,
          declaration_type:,
          evidence_held: "other",
        },
      )
    end

    it "creates a participant declaration" do
      expect { subject.call }.to change { ParticipantDeclaration.count }.by(1)
    end

    it "caches uplift flags on declaration" do
      subject.call

      declaration = ParticipantDeclaration.last

      expect(declaration.pupil_premium_uplift).to eql(profile.pupil_premium_uplift)
      expect(declaration.sparsity_uplift).to eql(profile.sparsity_uplift)
    end
  end

  context "when course is incorrect" do
    subject do
      described_class.new(
        params: {
          participant_id: user.id,
          course_identifier: "ecf-mentor",
          cpd_lead_provider:,
          declaration_date: declaration_date.rfc3339,
          declaration_type:,
          evidence_held: "other",
        },
      )
    end

    it "raises an error" do
      expect { subject.call }.to raise_error(ActionController::ParameterMissing).with_message(/course_identifier' must be an available course to/)
    end
  end

  context "when user is in 2020 cohort" do
    let(:cohort_2020) { create(:cohort, start_year: 2020) }
    let(:school_cohort_2020) { create(:school_cohort, cohort: cohort_2020, school: profile.school) }
    let(:partnership) { create(:partnership, school: profile.school, lead_provider:, cohort: cohort_2020) }
    let(:induction_programme) { create(:induction_programme, :fip, partnership:, school_cohort: school_cohort_2020) }

    subject do
      described_class.new(
        params: {
          participant_id: user.id,
          course_identifier: "ecf-induction",
          cpd_lead_provider:,
          declaration_date: declaration_date.rfc3339,
          declaration_type:,
          evidence_held: "other",
        },
      )
    end

    it "raises an error" do
      expect { subject.call }.to raise_error(ActionController::ParameterMissing).with_message(/participant_id' must be a valid Participant ID/)
    end
  end
end
