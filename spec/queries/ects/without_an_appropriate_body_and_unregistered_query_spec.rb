# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ects::WithoutAnAppropriateBodyAndUnregisteredQuery do
  describe "#call" do
    let(:fip_school_cohort) { create(:seed_school_cohort, :fip, :valid) }
    let(:cip_school_cohort) { create(:seed_school_cohort, :cip, :valid) }
    let(:fip_induction_programme) { create(:seed_induction_programme, :fip, school_cohort: fip_school_cohort) }
    let(:cip_induction_programme) { create(:seed_induction_programme, :cip, school_cohort: cip_school_cohort) }

    let(:fip_participant_profile) { create(:seed_ect_participant_profile, :valid, school_cohort: fip_school_cohort) }
    let(:cip_participant_profile) { create(:seed_ect_participant_profile, :valid, school_cohort: cip_school_cohort) }

    let(:include_fip) { true }
    let(:include_cip) { true }

    let!(:fip_induction_record) do
      create(:seed_induction_record, :valid, participant_profile: fip_participant_profile, induction_programme: fip_induction_programme)
    end

    let!(:cip_induction_record) do
      create(:seed_induction_record, :valid, participant_profile: cip_participant_profile, induction_programme: cip_induction_programme)
    end

    subject(:query_result) { described_class.call(include_fip:, include_cip:) }

    context "when there are ECTs without induction start dates" do
      context "when no AB is selected" do
        it "returns the induction records for the participants without induction start dates" do
          expect(query_result).to match_array [fip_induction_record, cip_induction_record]
        end

        context "when CIP is not included" do
          let(:include_cip) { false }

          it "does not return CIP participants" do
            expect(query_result).to match_array [fip_induction_record]
          end
        end

        context "when FIP is not included" do
          let(:include_fip) { false }

          it "does not return FIP participants" do
            expect(query_result).to match_array [cip_induction_record]
          end
        end
      end

      context "when the school has an AB" do
        before do
          fip_school_cohort.update!(appropriate_body: create(:seed_appropriate_body, :valid))
        end

        it "does not return those participants" do
          expect(query_result).to match_array [cip_induction_record]
        end
      end

      context "when the participant has an AB" do
        before do
          cip_induction_record.update!(appropriate_body: create(:seed_appropriate_body, :valid))
        end

        it "does not return those participants" do
          expect(query_result).to match_array [fip_induction_record]
        end
      end
    end

    context "when there are ECTs with induction start dates" do
      before do
        cip_participant_profile.update!(induction_start_date: 1.week.ago)
      end

      it "does not return those participants" do
        expect(query_result).to match_array [fip_induction_record]
      end
    end
  end
end
