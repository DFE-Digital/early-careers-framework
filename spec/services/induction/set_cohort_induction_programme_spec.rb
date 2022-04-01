# frozen_string_literal: true

RSpec.describe Induction::SetCohortInductionProgramme do
  describe "#call" do
    let(:school_cohort) { create :school_cohort, induction_programme_choice: "no_early_career_teachers", opt_out_of_updates: true }

    subject(:service) { described_class }

    it "sets the programme choice" do
      service.call(school_cohort: school_cohort, programme_choice: "full_induction_programme")
      expect(school_cohort).to be_full_induction_programme
    end

    it "sets the opt out flag correctly" do
      service.call(school_cohort: school_cohort, programme_choice: "full_induction_programme")
      expect(school_cohort).not_to be_opt_out_of_updates
    end

    it "creates a new induction programme" do
      expect {
        service.call(school_cohort: school_cohort, programme_choice: "full_induction_programme")
      }.to change { InductionProgramme.count }.by 1
    end

    it "sets the default induction programme" do
      service.call(school_cohort: school_cohort, programme_choice: "full_induction_programme")
      expect(school_cohort.default_induction_programme).to be_full_induction_programme
    end

    context "when a non-training programme is chosen" do
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }

      before do
        school_cohort.update!(default_induction_programme: induction_programme, opt_out_of_updates: false)
      end

      it "does not add an induction programme" do
        expect {
          service.call(school_cohort: school_cohort, programme_choice: "no_early_career_teachers")
        }.not_to change { InductionProgramme.count }
      end

      it "removes any default induction programme association" do
        service.call(school_cohort: school_cohort, programme_choice: "no_early_career_teachers")
        expect(school_cohort.default_induction_programme).to be_blank
      end

      it "sets the opt out flag correctly" do
        service.call(school_cohort: school_cohort, programme_choice: "no_early_career_teachers", opt_out_of_updates: true)
        expect(school_cohort).to be_opt_out_of_updates
      end
    end

    context "when a default induction programme already exists" do
      let(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }

      before do
        school_cohort.update!(default_induction_programme: induction_programme)
      end

      it "replaces the default induction programme" do
        service.call(school_cohort: school_cohort, programme_choice: "core_induction_programme")
        expect(school_cohort.default_induction_programme).to be_core_induction_programme
      end
    end
    
    context "when a CIP is chosen and the programme specified" do
      let(:cip) { create(:core_induction_programme) }

      it "sets the core_induction_programme" do
        service.call(school_cohort: school_cohort, programme_choice: "core_induction_programme", core_induction_programme: cip)
        expect(school_cohort.default_induction_programme.core_induction_programme).to eq cip
      end
    end
  end
end
