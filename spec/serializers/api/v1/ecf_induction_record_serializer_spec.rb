# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe ECFInductionRecordSerializer do
      let(:core_induction_programme) { create(:core_induction_programme, name: "Teach First") }
      let(:induction_programme) do
        induction_programme = create(:induction_programme, :cip)
        induction_programme.update!(core_induction_programme:)
        induction_programme
      end
      let(:ect_profile) { create(:ect_participant_profile) }

      before do
        Induction::Enrol.call(participant_profile: ect_profile, induction_programme:, start_date: 2.months.ago)
      end

      describe "registration_completed" do
        context "before validation started" do
          it "returns false" do
            expect(user_attributes(ect_profile)[:registration_completed]).to be false
          end
        end

        context "when details were not matched" do
          before do
            create(:ecf_participant_validation_data, participant_profile: ect_profile)
          end

          it "returns true" do
            expect(user_attributes(ect_profile)[:registration_completed]).to be true
          end
        end

        context "when the details were matched" do
          before do
            create(:ecf_participant_validation_data, participant_profile: ect_profile)
            eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
            eligibility.matched_status!
          end

          it "returns true" do
            expect(user_attributes(ect_profile)[:registration_completed]).to be true
          end
        end
      end

    private

      def user_attributes(profile)
        described_class.new(profile.current_induction_records.first).serializable_hash[:data][:attributes]
      end
    end
  end
end
