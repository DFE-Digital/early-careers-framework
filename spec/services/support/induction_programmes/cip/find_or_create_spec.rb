# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::InductionProgrammes::Cip::FindOrCreate do
  subject(:reactivate) { described_class.new(school_urn:, cohort_year:, cip_name:) }

  let(:school_cohort) { create(:school_cohort, cohort:) }
  let(:school) { school_cohort.school }
  let(:school_urn) { school.urn }
  let(:cohort) { Cohort.current }
  let(:cohort_year) { cohort.start_year }
  let(:cip) { create(:core_induction_programme) }
  let(:cip_name) { cip.name }

  before do
    # disable logging
    reactivate.logger = Logger.new("/dev/null")
  end

  describe "#call" do
    it "creates a CIP induction programme" do
      expect { reactivate.call }.to change { InductionProgramme.count }.by(1)
    end

    it "creates the correct induction programme" do
      new_induction_programme = reactivate.call
      expect(new_induction_programme.core_induction_programme.name).to eq(cip_name)
      expect(new_induction_programme.school_cohort.school).to eq(school)
      expect(new_induction_programme.school_cohort.cohort.start_year).to eq(cohort_year)
    end

    describe "when the induction programme already exists" do
      let!(:school_cohort) do
        create(:school_cohort, :cip, :with_induction_programme, school: create(:school), cohort:, core_induction_programme: cip)
      end
      let!(:existing_induction_programme) { school_cohort.induction_programmes.core_induction_programme.first }

      it "does not create a new induction programme" do
        expect { reactivate.call }.to_not change { InductionProgramme.count }
      end

      it "returns the existing induction programme" do
        expect(reactivate.call).to eq(existing_induction_programme)
      end
    end

    describe "validation errors" do
      describe "save raises an error" do
        before do
          allow_any_instance_of(InductionProgramme).to receive(:save!).and_return(false)
        end

        it "rolls back the transaction" do
          expect { reactivate.call }.to_not change { InductionProgramme.count }
        end
      end
    end
  end
end
