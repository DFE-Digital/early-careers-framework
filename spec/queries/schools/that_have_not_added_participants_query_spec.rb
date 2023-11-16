# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::ThatHaveNotAddedParticipantsQuery do
  describe "#call" do
    let(:cohort) { create(:seed_cohort) }
    let(:query_cohort) { nil }
    let(:school_type_codes) { [] }

    let(:school_cohort) { create(:seed_school_cohort, :fip, :with_school, cohort:) }
    let(:induction_programme) { create(:seed_induction_programme, :fip, school_cohort:) }
    let(:school) { school_cohort.school }

    let(:participant_profile) { create(:seed_ect_participant_profile, :valid, school_cohort:) }

    subject(:query_result) { described_class.call(cohort: query_cohort, school_type_codes:) }

    context "when there are no cohorts without participants" do
      let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:, induction_programme:) }

      it "does not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when a cohort is supplied" do
      context "and there are no participants in the cohort" do
        let(:query_cohort) { cohort }

        it "includes the school" do
          expect(query_result).to include(school)
        end
      end

      context "and there are participants in the cohort" do
        let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:, induction_programme:) }
        let(:query_cohort) { cohort }

        it "does not include the school" do
          expect(query_result).not_to include(school)
        end
      end

      context "and there are active participants in a different cohort" do
        let(:query_cohort) { create(:seed_cohort, start_year: cohort.start_year + 1) }
        let!(:query_school_cohort) { create(:seed_school_cohort, :fip, school:, cohort: query_cohort) }

        it "includes the school" do
          expect(query_result).to include(school)
        end
      end
    end

    context "when school type codes are supplied" do
      let(:school_type_codes) { [1, 2, 3] }

      context "and the school matches one of the school types" do
        before do
          school.update!(school_type_code: 2)
        end

        context "when there are no cohorts without participants" do
          let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:, induction_programme:) }

          it "does not include the school" do
            expect(query_result).not_to include(school)
          end
        end

        context "when there are cohorts without participants" do
          it "includes the school" do
            expect(query_result).to include(school)
          end
        end
      end

      context "and the school does not match one of the school types" do
        before do
          school.update!(school_type_code: 5)
        end

        context "when there are no cohorts without participants" do
          let!(:induction_record) { create(:seed_induction_record, :valid, participant_profile:, induction_programme:) }

          it "does not include the school" do
            expect(query_result).not_to include(school)
          end
        end

        context "when there are cohorts without participants" do
          it "does not include the school" do
            expect(query_result).not_to include(school)
          end
        end
      end
    end
  end
end
