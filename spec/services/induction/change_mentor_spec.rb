# frozen_string_literal: true

RSpec.describe Mentors::Change do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
    let(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort:) }
    let!(:induction_record) { Induction::Enrol.call(induction_programme:, participant_profile: ect_profile, start_date: 6.months.ago, mentor_profile:) }

    subject(:service) { described_class }

    it "adds a new induction record to the new programme for the participant" do
      expect {
        service.call(induction_record:,
                     mentor_profile: mentor_profile_2)
      }.to change { ect_profile.induction_records.count }.by 1
    end

    it "sets the mentor_profile to the correct value" do
      service.call(induction_record:, mentor_profile: mentor_profile_2)
      expect(ect_profile.current_induction_record.mentor_profile).to eq mentor_profile_2
    end
  end
end
