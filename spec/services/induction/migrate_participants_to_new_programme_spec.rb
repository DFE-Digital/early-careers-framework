# frozen_string_literal: true

RSpec.describe Induction::MigrateParticipantsToNewProgramme do
  describe "#call" do
    let(:school_cohort) { create(:school_cohort) }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:induction_programme_2) { create(:induction_programme, :cip, school_cohort:) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
    let(:appropriate_body) { create(:appropriate_body_teaching_school_hub) }

    subject(:service) { described_class }

    before do
      Induction::Enrol.call(induction_programme:,
                            participant_profile: mentor_profile,
                            start_date: 6.months.ago)
      Induction::ChangeInductionRecord.call(induction_record: mentor_profile.latest_induction_record,
                                            changes: { appropriate_body_id: appropriate_body.id })

      Induction::Enrol.call(induction_programme:,
                            participant_profile: ect_profile,
                            start_date: 6.months.ago,
                            mentor_profile:)
    end

    it "adds new induction records for the participants" do
      expect {
        service.call(from_programme: induction_programme,
                     to_programme: induction_programme_2)
      }.to change { InductionRecord.count }.by 2
    end

    it "updates the old programmes induction records to changing status" do
      expect(induction_programme.induction_records.changed_induction_status.count).to eq 1

      service.call(from_programme: induction_programme,
                   to_programme: induction_programme_2)

      expect(induction_programme.induction_records.changed_induction_status.count).to eq 3
    end

    it "migrates the participants to the new programme" do
      service.call(from_programme: induction_programme,
                   to_programme: induction_programme_2)

      expect(ect_profile.current_induction_record.induction_programme).to eq induction_programme_2
      expect(mentor_profile.current_induction_record.induction_programme).to eq induction_programme_2
    end
  end
end
