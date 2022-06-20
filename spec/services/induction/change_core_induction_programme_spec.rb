# frozen_string_literal: true

RSpec.describe Induction::ChangeCoreInductionProgramme do
  describe "#call" do
    let(:school_cohort) { create(:school_cohort) }
    let(:core_induction_programme) { create(:core_induction_programme, name: "Super provider") }
    let(:core_induction_programme_2) { create(:core_induction_programme, name: "Mega provider") }
    let(:induction_programme) { create(:induction_programme, :cip, school_cohort:, core_induction_programme:) }
    let(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }

    subject(:service) { described_class }

    before do
      Induction::Enrol.call(induction_programme:,
                            participant_profile: mentor_profile,
                            start_date: 6.months.ago)

      Induction::Enrol.call(induction_programme:,
                            participant_profile: ect_profile,
                            start_date: 6.months.ago,
                            mentor_profile:)

      school_cohort.update!(default_induction_programme: induction_programme, core_induction_programme:)
    end

    it "adds a new induction programme" do
      expect {
        service.call(school_cohort:,
                     core_induction_programme: core_induction_programme_2)
      }.to change { InductionProgramme.count }.by 1
    end

    it "sets the new programme as the default for the school cohort" do
      service.call(school_cohort:,
                   core_induction_programme: core_induction_programme_2)

      expect(school_cohort.default_induction_programme).to eq school_cohort.induction_programmes.order(created_at: :desc).first
    end

    it "sets the core_induction_programme on the new programme" do
      service.call(school_cohort:,
                   core_induction_programme: core_induction_programme_2)

      expect(school_cohort.default_induction_programme.core_induction_programme).to eq core_induction_programme_2
    end

    it "migrates the participants to the new programme" do
      service.call(school_cohort:,
                   core_induction_programme: core_induction_programme_2)

      expect(school_cohort.default_induction_programme.induction_records).to match_array [ect_profile.current_induction_record, mentor_profile.current_induction_record]
    end

    context "when the default programme does not have a core_induction_programme" do
      let(:induction_programme) { create(:induction_programme, :cip, school_cohort:, core_induction_programme: nil) }

      it "does not create a new induction_programme" do
        expect {
          service.call(school_cohort:,
                       core_induction_programme: core_induction_programme_2)
        }.not_to change { InductionProgramme.count }
      end

      it "sets the core_induction_programme on the existing programme" do
        service.call(school_cohort:,
                     core_induction_programme: core_induction_programme_2)

        expect(induction_programme.core_induction_programme).to eq core_induction_programme_2
      end

      it "does not change the default induction programme for the school cohort" do
        service.call(school_cohort:,
                     core_induction_programme: core_induction_programme_2)

        expect(school_cohort.default_induction_programme).to eq induction_programme
      end
    end

    context "when the default induction programme is not a CIP" do
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }

      it "does not create a new induction_programme" do
        expect {
          service.call(school_cohort:,
                       core_induction_programme: core_induction_programme_2)
        }.not_to change { InductionProgramme.count }
      end

      it "does not set the core_induction_programme on the existing programme" do
        service.call(school_cohort:,
                     core_induction_programme: core_induction_programme_2)

        expect(induction_programme.core_induction_programme).to be_nil
      end

      it "does not change the default induction programme for the school cohort" do
        service.call(school_cohort:,
                     core_induction_programme: core_induction_programme_2)

        expect(school_cohort.default_induction_programme).to eq induction_programme
      end
    end
  end
end
