# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::PreTermReminderToReportAnyChangesQuery do
  let(:cohort) { create(:seed_cohort) }
  let(:query_cohort) { cohort }
  let(:school_type_codes) { [] }

  let(:fip_school_cohort) { create(:seed_school_cohort, :fip, :with_school, cohort:) }
  let(:induction_programme) { create(:seed_induction_programme, :fip, school_cohort: fip_school_cohort) }
  let(:fip_school) { fip_school_cohort.school }

  let(:cip_school_cohort) { create(:seed_school_cohort, :cip, :with_school, cohort:) }
  let(:induction_programme) { create(:seed_induction_programme, :cip, school_cohort: cip_school_cohort) }
  let(:cip_school) { cip_school_cohort.school }

  let(:diy_school_cohort) { create(:seed_school_cohort, :design_our_own, :with_school, cohort:) }
  let(:induction_programme) { create(:seed_induction_programme, :design_our_own, school_cohort: diy_school_cohort) }
  let(:diy_school) { diy_school_cohort.school }

  let(:opted_out_school_cohort) { create(:seed_school_cohort, :fip, :with_school, cohort:, opt_out_of_updates: true) }
  let(:opted_out_school) { opted_out_school_cohort.school }

  let(:school_funded_fip_school_cohort) { create(:seed_school_cohort, :school_funded_fip, :with_school, cohort:) }
  let(:induction_programme) { create(:seed_induction_programme, :school_funded_fip, partnership:, school_cohort: school_funded_fip_school_cohort) }
  let(:school_funded_fip_school) { school_funded_fip_school_cohort.school }

  subject(:query_result) { described_class.call(cohort: query_cohort, school_type_codes:) }

  describe "#call" do
    it "does not return schools that have opted out of updates" do
      expect(query_result).not_to include(opted_out_school)
    end

    it "does not return schools that run DIY programmes" do
      expect(query_result).not_to include(diy_school)
    end

    it "does not return schools that run School Funded FIP" do
      expect(query_result).not_to include(school_funded_fip_school)
    end

    it "returns schools running FIP" do
      expect(query_result).to include(fip_school)
    end

    it "returns schools running CIP" do
      expect(query_result).to include(cip_school)
    end

    context "when school type codes are supplied" do
      let(:school_type_codes) { [1, 2, 3] }

      context "and the school does not match one of the school types" do
        before do
          fip_school.update!(school_type_code: 5)
        end

        it "does not return the school" do
          expect(query_result).not_to include(fip_school)
        end
      end
    end

    context "and the school matches one of the school types" do
      before do
        fip_school.update!(school_type_code: 2)
      end

      it "includes the school" do
        expect(query_result).to include(fip_school)
      end
    end
  end
end
