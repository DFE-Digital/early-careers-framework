# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::ThatHaveNotEngagedQuery do
  describe "#call" do
    let(:cohort) { create(:seed_cohort) }
    let(:query_cohort) { cohort.next || create(:seed_cohort, start_year: cohort.start_year + 1) }
    let(:school_type_codes) { [] }

    let(:school_cohort) { create(:seed_school_cohort, :with_school, cohort:) }
    let!(:school) { school_cohort.school }

    subject(:query_result) { described_class.call(cohort: query_cohort, school_type_codes:) }

    context "when the school has not engaged" do
      it "includes the school" do
        expect(query_result).to include(school)
      end
    end

    context "when the school has engaged" do
      let!(:query_school_cohort) { create(:seed_school_cohort, :fip, school:, cohort: query_cohort) }

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

        context "when the school has not engaged" do
          it "includes the school" do
            expect(query_result).to include(school)
          end
        end

        context "when the school has engaged" do
          let!(:query_school_cohort) { create(:seed_school_cohort, school:, cohort: query_cohort) }

          it "does not include the school" do
            expect(query_result).not_to include(school)
          end
        end
      end

      context "and the school does not match one of the school types" do
        before do
          school.update!(school_type_code: 5)
        end

        context "when the school has not engaged" do
          it "does not include the school" do
            expect(query_result).not_to include(school)
          end
        end

        context "when the school has engaged" do
          let!(:query_school_cohort) { create(:seed_school_cohort, school:, cohort: query_cohort) }

          it "does not include the school" do
            expect(query_result).not_to include(school)
          end
        end
      end
    end
  end
end
