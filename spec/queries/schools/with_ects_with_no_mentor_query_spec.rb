# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::WithEctsWithNoMentorQuery do
  describe "#call" do
    let(:cohort) { create(:seed_cohort) }
    let(:query_cohort) { nil }
    let(:school_type_codes) { [] }

    let(:school_cohort) { create(:seed_school_cohort, :fip, :with_school, cohort:) }
    let(:induction_programme) { create(:seed_induction_programme, :fip, school_cohort:) }
    let(:school) { school_cohort.school }

    let(:participant_profile) { create(:seed_ect_participant_profile, :valid, school_cohort:) }
    let(:mentor_profile) { nil }

    let(:induction_status) { "active" }
    let(:training_status) { "active" }
    let!(:induction_record) { create(:seed_induction_record, :valid, induction_status:, training_status:, participant_profile:, induction_programme:, mentor_profile:) }

    let(:eligibility_status) { "eligible" }
    let!(:eligibility) { create(:seed_ecf_participant_eligibility, participant_profile:, status: eligibility_status) }

    subject(:query_result) { described_class.call(cohort: query_cohort, school_type_codes:) }

    context "when there are participants with mentor assigned" do
      let(:mentor_profile) { create(:seed_mentor_participant_profile, :valid, school_cohort:) }

      it "do not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when there are participants with withdrawn induction status" do
      let(:induction_status) { "withdrawn" }

      it "do not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when there are participants with withdrawn training induction status" do
      let(:training_status) { "withdrawn" }

      it "do not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when there are participants with deferred training induction status" do
      let(:training_status) { "deferred" }

      it "do not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when there are active participants :ineligible and with no mentor associated" do
      let(:eligibility_status) { "ineligible" }

      it "do not include the school" do
        expect(query_result).not_to include(school)
      end
    end

    context "when there are active participants on :matched eligibility and no mentor associated" do
      let(:eligibility_status) { "matched" }

      it "includes the school" do
        expect(query_result).to include(school)
      end
    end

    context "when there are active participants on :manual-check eligibility and no mentor associated" do
      let(:eligibility_status) { "manual_check" }

      it "includes the school" do
        expect(query_result).to include(school)
      end
    end

    context "when a cohort is supplied" do
      context "and there are active participants with no mentor associated in the cohort" do
        let(:query_cohort) { cohort }

        it "includes the school" do
          expect(query_result).to include(school)
        end
      end

      context "and there are active participants with no mentor associated in a different cohort" do
        let(:query_cohort) { create(:seed_cohort, start_year: cohort.start_year + 1) }

        it "does not include the school" do
          expect(query_result).not_to include(school)
        end
      end
    end

    context "when school type codes are supplied" do
      let(:school_type_codes) { [1, 2, 3] }

      context "when there are active participants with no mentor associated in matching school types" do
        before do
          school.update!(school_type_code: 2)
        end

        it "includes the school" do
          expect(query_result).to include(school)
        end
      end

      context "when there are active participants with no mentor associated in different school types" do
        before do
          school.update!(school_type_code: 5)
        end

        it "does not include the school" do
          expect(query_result).not_to include(school)
        end
      end
    end
  end
end
