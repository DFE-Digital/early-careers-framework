# frozen_string_literal: true

RSpec.describe Induction::FindRelevantTo, :with_default_schedules do
  let(:cohort) { Cohort.current }
  # after all the dates in the induction records
  let!(:a_point_in_time) { Date.new(cohort.start_year + 1, 2, 1) }
  # after the start_date but before the end_date of induction_4
  let!(:an_earlier_point_in_time) { Date.new(cohort.start_year, 12, 25) }
  let(:school_cohort_1) { create(:seed_school_cohort, :with_school, cohort:) }
  let(:school_cohort_2) { create(:seed_school_cohort, :with_school, cohort:) }
  let(:school_cohort_3) { create(:seed_school_cohort, :with_school, cohort:) }
  let(:partnership_1) { create(:seed_partnership, :with_lead_provider, :with_delivery_partner, cohort:, school: school_cohort_1.school) }
  let(:partnership_2) { create(:seed_partnership, :with_lead_provider, :with_delivery_partner, cohort:, school: school_cohort_2.school) }
  let(:partnership_3) { create(:seed_partnership, :with_lead_provider, :with_delivery_partner, cohort:, school: school_cohort_3.school) }
  let(:induction_programme_1) { create(:seed_induction_programme, school_cohort: school_cohort_1, partnership: partnership_1) }
  let(:induction_programme_2) { create(:seed_induction_programme, school_cohort: school_cohort_2, partnership: partnership_2) }
  let(:induction_programme_3) { create(:seed_induction_programme, school_cohort: school_cohort_3, partnership: partnership_3) }
  let(:teacher_profile) { create(:seed_teacher_profile, :valid) }
  let(:participant_identity) { create(:seed_participant_identity, user: teacher_profile.user) }
  let(:participant_profile) { create(:seed_ect_participant_profile, :with_schedule, teacher_profile:, participant_identity:, school_cohort: school_cohort_3) }

  let!(:induction_1) { create(:seed_induction_record, induction_programme: induction_programme_1, participant_profile:, schedule: participant_profile.schedule, start_date: Date.new(cohort.start_year, 9, 1), end_date: Date.new(cohort.start_year, 10, 1), induction_status: "leaving") }
  let!(:induction_2) { create(:seed_induction_record, induction_programme: induction_programme_2, participant_profile:, schedule: participant_profile.schedule, start_date: Date.new(cohort.start_year, 10, 1), end_date: Date.new(cohort.start_year, 11, 1), induction_status: "leaving") }
  let!(:induction_3) { create(:seed_induction_record, induction_programme: induction_programme_3, participant_profile:, schedule: participant_profile.schedule, start_date: Date.new(cohort.start_year, 11, 1), end_date: Date.new(cohort.start_year, 12, 1), induction_status: "changed") }
  let!(:induction_4) { create(:seed_induction_record, induction_programme: induction_programme_3, participant_profile:, schedule: participant_profile.schedule, start_date: Date.new(cohort.start_year, 12, 1), end_date: Date.new(cohort.start_year + 1, 1, 1), induction_status: "leaving") }

  subject(:service) { described_class }

  describe "#call" do
    it "returns the latest induction record for the participant" do
      travel_to a_point_in_time do
        expect(service.call(participant_profile:)).to eq induction_4
      end
    end

    context "when current not latest is set" do
      context "when there isn't a current record" do
        it "returns nil" do
          travel_to a_point_in_time do
            expect(service.call(participant_profile:, current_not_latest_record: true)).to be_nil
          end
        end
      end

      context "when a current record exists" do
        it "returns the current record for the participant" do
          # travel to before the end_date of induction_4
          travel_to an_earlier_point_in_time do
            expect(service.call(participant_profile:, current_not_latest_record: true)).to eq induction_4
          end
        end
      end
    end

    context "when a lead provider is supplied" do
      it "returns the latest induction record for that provider" do
        travel_to a_point_in_time do
          expect(service.call(participant_profile:, lead_provider: partnership_1.lead_provider)).to eq induction_1
          expect(service.call(participant_profile:, lead_provider: partnership_2.lead_provider)).to eq induction_2
          expect(service.call(participant_profile:, lead_provider: partnership_3.lead_provider)).to eq induction_4
        end
      end
    end

    context "when a delivery partner is supplied" do
      it "returns the latest induction record for that partner" do
        travel_to a_point_in_time do
          expect(service.call(participant_profile:, delivery_partner: partnership_1.delivery_partner)).to eq induction_1
          expect(service.call(participant_profile:, delivery_partner: partnership_2.delivery_partner)).to eq induction_2
          expect(service.call(participant_profile:, delivery_partner: partnership_3.delivery_partner)).to eq induction_4
        end
      end
    end

    context "when a school is supplied" do
      it "returns the latest induction record for that school" do
        travel_to a_point_in_time do
          expect(service.call(participant_profile:, school: school_cohort_1.school)).to eq induction_1
          expect(service.call(participant_profile:, school: school_cohort_2.school)).to eq induction_2
          expect(service.call(participant_profile:, school: school_cohort_3.school)).to eq induction_4
        end
      end
    end

    context "when a schedule is supplied" do
      let(:wrong_schedule) { create(:ecf_schedule_january) }
      it "returns the latest induction record with that schedule" do
        travel_to a_point_in_time do
          expect(service.call(participant_profile:, schedule: participant_profile.schedule)).to eq induction_4
          expect(service.call(participant_profile:, schedule: wrong_schedule)).to be_nil
        end
      end
    end

    context "when a date range is supplied" do
      it "returns the latest induction record in that period" do
        travel_to a_point_in_time do
          expect(service.call(participant_profile:, date_range: Date.new(cohort.start_year, 9, 1)..Date.new(cohort.start_year, 9, 30))).to eq induction_1
          expect(service.call(participant_profile:, date_range: Date.new(cohort.start_year, 11, 2)..)).to eq induction_4
          expect(service.call(participant_profile:, date_range: ..Date.new(cohort.start_year, 11, 30))).to eq induction_3
          expect(service.call(participant_profile:, date_range: Date.new(cohort.start_year + 1, 3, 22)..)).to be_nil
        end
      end
    end
  end
end
