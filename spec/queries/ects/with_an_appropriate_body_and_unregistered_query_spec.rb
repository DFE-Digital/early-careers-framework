# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ects::WithAnAppropriateBodyAndUnregisteredQuery do
  describe "#call" do
    let(:fip_ab) { create(:seed_appropriate_body, :valid) }
    let(:cip_ab) { create(:seed_appropriate_body, :valid) }

    let(:fip_school_cohort) { create(:seed_school_cohort, :fip, :valid, appropriate_body: fip_ab) }
    let(:cip_school_cohort) { create(:seed_school_cohort, :cip, :valid, appropriate_body: cip_ab) }
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

    let!(:fip_eligibility) do
      create(:seed_ecf_participant_eligibility, :no_induction, participant_profile: fip_participant_profile)
    end

    let!(:cip_eligibility) do
      create(:seed_ecf_participant_eligibility, :no_induction, participant_profile: cip_participant_profile)
    end

    subject(:query_result) { described_class.call(include_fip:, include_cip:) }

    context "when there are ECTs without induction start dates" do
      context "when the school has an AB selected" do
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

      context "when the participant has an AB selected" do
        before do
          fip_induction_record.update!(appropriate_body: fip_ab)
          cip_induction_record.update!(appropriate_body: cip_ab)
          fip_school_cohort.update!(appropriate_body: nil)
          cip_school_cohort.update!(appropriate_body: nil)
        end

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

      context "when an AB is not selected" do
        let(:fip_ab) { nil }

        it "does not return participants" do
          expect(query_result).to match_array [cip_induction_record]
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

    context "when there is no QTS" do
      let!(:fip_eligibility) do
        create(:seed_ecf_participant_eligibility, :no_qts, no_induction: true, participant_profile: fip_participant_profile)
      end

      it "does not return those participants" do
        expect(query_result).to match_array [cip_induction_record]
      end
    end

    context "when there is no eligibility record" do
      let!(:fip_eligibility)  { nil }

      it "does not return those participants" do
        expect(query_result).to match_array [cip_induction_record]
      end
    end

    context "when there are active flags" do
      let!(:fip_eligibility) do
        create(:seed_ecf_participant_eligibility, :active_flags, no_induction: true, participant_profile: fip_participant_profile)
      end

      it "does not return those participants" do
        expect(query_result).to match_array [cip_induction_record]
      end
    end

    context "when a previous induction is flagged" do
      let!(:fip_eligibility) do
        create(:seed_ecf_participant_eligibility, :previous_induction, no_induction: true, participant_profile: fip_participant_profile)
      end

      it "does not return those participants" do
        expect(query_result).to match_array [cip_induction_record]
      end
    end
  end
end
