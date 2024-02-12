# frozen_string_literal: true

require "rails_helper"

RSpec.describe(TeacherProfile, type: :model) do
  describe(:oldest_first) do
    specify "constructs the right order by clause" do
      expect(TeacherProfile.oldest_first.to_sql).to match(/ORDER BY "teacher_profiles"."created_at" ASC/)
    end
  end

  describe "#has_participant_profile_with_declarations?" do
    let!(:participant_profile) { create(:ect, :eligible_for_funding, user: teacher_profile.user) }

    subject(:teacher_profile) { create(:teacher_profile) }

    it { is_expected.not_to have_participant_profile_with_declarations }

    context "when there is a participant profile with declarations" do
      before do
        cpd_lead_provider = participant_profile.lead_provider.cpd_lead_provider
        create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)
      end

      it { is_expected.to have_participant_profile_with_declarations }
    end
  end
end
