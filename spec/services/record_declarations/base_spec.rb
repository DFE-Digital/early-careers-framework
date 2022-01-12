# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecordDeclarations::Base do
  let(:cpd_lead_provider) { build(:cpd_lead_provider) }
  let(:user) { create(:user) }
  let(:teacher_profile) { create(:teacher_profile, user: user) }
  let!(:ecf_profile) { create(:ecf_participant_profile, teacher_profile: teacher_profile) }

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

  context "when milestone has null milestone_date" do
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
