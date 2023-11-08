# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::UnpartneredLastYearAndHaveNotPartneredThisYearQuery do
  describe "#call" do
    let(:cohort) { create(:seed_cohort) }
    let(:previous_cohort) { cohort.previous || create(:seed_cohort, start_year: cohort.start_year - 1) }
    let(:query_cohort) { cohort }
    let(:school_type_codes) { [] }

    let(:school_cohort) { create(:seed_school_cohort, :fip, :with_school, cohort:) }
    let!(:previous_school_cohort) { create(:seed_school_cohort, :fip, school:, cohort: previous_cohort) }
    let!(:school) { school_cohort.school }

    subject(:query_result) { described_class.call(cohort: query_cohort, school_type_codes:) }

    context "when there are no active partnerships in the cohort" do
      it "includes the school" do
        expect(query_result).to include(school)
      end
    end

    context "when there is an active partnership" do
      let!(:partnership) { create(:seed_partnership, :valid, school:, cohort:) }

      it "does not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when there is a challenged partnership" do
      let!(:partnership) { create(:seed_partnership, :valid, :challenged, school:, cohort:) }

      it "includes the school" do
        expect(query_result).to include(school)
      end
    end

    context "when there is a relationship" do
      let!(:relationship) { create(:seed_partnership, :valid, relationship: true, school:, cohort:) }

      it "does not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when there is an active partnership in the previous cohort" do
      let!(:partnership) { create(:seed_partnership, :valid, school:, cohort: previous_cohort) }

      it "does not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when the school is doing CIP" do
      let(:school_cohort) { create(:seed_school_cohort, :cip, :with_school, cohort:) }

      it "does not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when the school is not expecting ECTs" do
      let(:school_cohort) { create(:seed_school_cohort, :no_early_career_teachers, :with_school, cohort:) }

      it "does not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when the school is doing a school-funded FIP" do
      let(:school_cohort) { create(:seed_school_cohort, :school_funded_fip, :with_school, cohort:) }

      it "does not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when the school is doing DIY" do
      let(:school_cohort) { create(:seed_school_cohort, :design_our_own, :with_school, cohort:) }

      it "does not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when school type codes are supplied" do
      let(:school_type_codes) { [1, 2, 3] }

      context "and the school matches one of the school types" do
        before do
          school.update!(school_type_code: 2)
        end

        context "when there are no active partnerships in the cohort" do
          it "includes the school" do
            expect(query_result).to include(school)
          end
        end

        context "when there is an active partnership in the previous cohort" do
          let!(:partnership) { create(:seed_partnership, :valid, school:, cohort: previous_cohort) }

          it "does not include the school" do
            expect(query_result).not_to include(school)
          end
        end
      end

      context "and the school does not match one of the school types" do
        before do
          school.update!(school_type_code: 5)
        end

        context "when there are no active partnerships in the cohort" do
          it "does not include the school" do
            expect(query_result).not_to include(school)
          end
        end
      end
    end
  end
end
