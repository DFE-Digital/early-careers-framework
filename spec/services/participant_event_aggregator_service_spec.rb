# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantEventAggregator do
  let(:lead_provider) { create(:lead_provider) }

  context "event declarations" do
    before do
      sparse_school = create(:school, :sparsity_uplift)
      pupil_premium_school = create(:school, :pupil_premium_uplift)
      teacher_sparse = create(:early_career_teacher_profile, school: sparse_school)
      teacher_pupil_premium = create(:early_career_teacher_profile, school: pupil_premium_school)
      profile_sparse = create(:early_career_teacher_profile, teacher_sparse)

      # TODO: DRY
      6.times do
        participant_declaration = create(:participant_declaration, lead_provider: lead_provider)
        create(:participant_declaration, early_career_teacher_profile: participant_declaration.early_career_teacher_profile, lead_provider: lead_provider)

        participant_record = create(:participation_record, lead_provider: lead_provider)
        participant_record.join!
      end
      2.times do
        early_career_teacher_profile = create(:early_career_teacher_profile, uplift: true)
        participant_declaration = create(:participant_declaration, lead_provider: lead_provider, early_career_teacher_profile: early_career_teacher_profile)
        create(:participant_declaration, early_career_teacher_profile: participant_declaration.early_career_teacher_profile, lead_provider: lead_provider)

        participant_record = create(:participation_record, lead_provider: lead_provider)
        participant_record.join!
      end
    end

    describe ".call" do
      context "aggregate using ParticipationRecorder" do
        it "returns a count of the active participants" do
          active, = described_class.call(lead_provider)
          expect(active).to eq(10)
        end

        it "returns a count of the participants eligible for uplift payments" do
          _, uplift = described_class.call(lead_provider)
          expect(uplift).to eq(4)
        end
      end
    end
  end
end
