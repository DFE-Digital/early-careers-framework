# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Base do
  let(:cpd_lead_provider)       { create(:cpd_lead_provider, :with_lead_provider) }
  let(:cohort)                  { create(:cohort, start_year: Time.zone.today.year) }
  let(:school)                  { create(:school) }
  let(:school_cohort)           { create(:school_cohort, school: school, cohort: cohort) }
  let(:declaration_date)        { Time.zone.parse("2021-11-02") }
  let(:declaration_type)        { "started" }
  let(:user)                    { create(:user) }
  let(:teacher_profile)         { create(:teacher_profile, user: user) }
  let!(:ect_participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort, teacher_profile: teacher_profile) }
  let(:params) do
    {
      participant_id: ect_participant_profile.user_id,
      course_identifier: "ecf-induction",
      cpd_lead_provider: cpd_lead_provider,
      declaration_date: declaration_date.rfc3339,
      declaration_type: declaration_type,
    }
  end

  before do
    create(:partnership, lead_provider: cpd_lead_provider.lead_provider, cohort: cohort, school: school)
  end

  context "when a similar declaration has been voided" do
    subject(:record_declaration) do
      RecordDeclarations::Started::EarlyCareerTeacher
        .call(params: params.merge(declaration_date: (declaration_date + 1.day).rfc3339))
    end
    let!(:void_declaration) do
      VoidParticipantDeclaration.new(
        cpd_lead_provider: cpd_lead_provider,
        id: JSON.parse(RecordDeclarations::Started::EarlyCareerTeacher.call(params: params)).dig("data", "id"),
      ).call
    end

    it "allows to re-send a new declaration" do
      expect(ParticipantDeclaration.find(JSON.parse(record_declaration).dig("data", "id"))).to be_submitted
    end
  end

  context "when milestone has null milestone_date" do
    let(:klass) do
      Class.new(described_class) do
        def self.valid_declaration_types
          %w[started completed retained-1 retained-2 retained-3 retained-4]
        end

        def self.valid_courses
          %w[ecf-induction]
        end

        def self.model_name
          ActiveModel::Name.new(self, nil, "temp")
        end

        def user_profile
          user.participant_profiles[0]
        end

        def matches_lead_provider?
          true
        end
      end
    end
    subject do
      klass.new(
        params: {
          course_identifier: "ecf-induction",
          cpd_lead_provider: cpd_lead_provider,
          declaration_date: 10.days.ago.iso8601,
          declaration_type: "started",
          participant_id: user.id,
        },
      )
    end

    before do
      Finance::Milestone.find_by(declaration_type: "started").update!(milestone_date: nil)
    end

    it "does not have errors on milestone_date" do
      expect { subject.call }.not_to raise_error(ActionController::ParameterMissing)
    end
  end
end
