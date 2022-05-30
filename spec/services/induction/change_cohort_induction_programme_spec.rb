# frozen_string_literal: true

RSpec.describe Induction::ChangeCohortInductionProgramme do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :cip, school_cohort: school_cohort) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort: school_cohort) }
    let!(:mentor_induction_record) { Induction::Enrol.call(induction_programme: induction_programme, participant_profile: mentor_profile, start_date: 6.months.ago) }
    let!(:induction_record) { Induction::Enrol.call(induction_programme: induction_programme, participant_profile: ect_profile, start_date: 6.months.ago, mentor_profile: mentor_profile) }
    let(:programme_choice) { "full_induction_programme" }

    subject(:service) { described_class }

    before do
      school_cohort.update!(default_induction_programme: induction_programme)
    end

    it "changes the programme choice on the school cohort" do
      service.call(school_cohort: school_cohort, programme_choice: programme_choice)
      expect(school_cohort).to be_full_induction_programme
    end

    it "creates a new induction programme of the correct type" do
      expect {
        service.call(school_cohort: school_cohort, programme_choice: programme_choice)
      }.to change { InductionProgramme.full_induction_programme.count }.by 1
    end

    it "changes the default induction programme programme choice on the school cohort" do
      service.call(school_cohort: school_cohort, programme_choice: programme_choice)
      expect(school_cohort.default_induction_programme).to be_full_induction_programme
    end

    it "enrols any participants into the new programme" do
      service.call(school_cohort: school_cohort, programme_choice: programme_choice)
      expect(induction_programme.induction_records.active.count).to eq 0
      expect(school_cohort.default_induction_programme.induction_records.active.count).to eq 2
    end

    context "when existing programme is a partnered FIP" do
      let(:partnership) { create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort) }
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort, partnership: partnership) }
      let(:programme_choice) { "core_induction_programme" }

      it "raises an error" do
        expect {
          service.call(school_cohort: school_cohort, programme_choice: programme_choice)
        }.to raise_error ArgumentError
      end
    end
  end
end
