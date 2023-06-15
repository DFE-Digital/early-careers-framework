# frozen_string_literal: true

RSpec.describe Induction::FindBy, :with_default_schedules do
  let(:cohort) { Cohort.current }
  let(:current_year) { cohort.start_year }

  # after all the dates in the induction records
  let!(:a_point_in_time) { Date.new(current_year + 1, 2, 1) }
  # after the start_date but before the end_date of induction_4
  let!(:an_earlier_point_in_time) { Date.new(current_year, 12, 25) }

  let(:school_1) { NewSeeds::Scenarios::Schools::School.new.build.chosen_fip_and_partnered_in(cohort:) }
  let(:school_2) { NewSeeds::Scenarios::Schools::School.new.build.chosen_fip_and_partnered_in(cohort:) }
  let(:school_3) { NewSeeds::Scenarios::Schools::School.new.build.chosen_fip_and_partnered_in(cohort:) }
  let(:ect) { NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort: school_1.school_cohort).build }

  let(:participant_profile) { ect.participant_profile }

  let!(:induction_1) { ect.add_induction_record(induction_programme: school_1.induction_programme, start_date: Date.new(current_year, 9, 1), end_date: Date.new(current_year, 10, 1), induction_status: "leaving") }
  let!(:induction_2) { ect.add_induction_record(induction_programme: school_2.induction_programme, start_date: Date.new(current_year, 10, 1), end_date: Date.new(current_year, 11, 1), induction_status: "leaving") }
  let!(:induction_3) { ect.add_induction_record(induction_programme: school_3.induction_programme, start_date: Date.new(current_year, 11, 1), end_date: Date.new(current_year, 12, 1), induction_status: "changed") }
  let!(:induction_4) { ect.add_induction_record(induction_programme: school_3.induction_programme, start_date: Date.new(current_year, 12, 1), end_date: Date.new(current_year + 1, 1, 1), induction_status: "leaving") }
  let!(:induction_5) { ect.add_induction_record(induction_programme: school_3.induction_programme, start_date: Date.new(current_year + 1, 1, 1), end_date: nil, induction_status: "leaving") }

  subject(:service) { described_class }

  describe "#call" do
    it "returns the latest induction record for the participant" do
      travel_to a_point_in_time do
        expect(service.call(participant_profile:)).to eq induction_5
      end
    end

    context "when there are multiple induction records with the same start_date" do
      context "if a duplicate has a nil end_date" do
        let!(:induction_2_nil_end_date) { ect.add_induction_record(induction_programme: school_2.induction_programme, start_date: induction_2.start_date, end_date: nil, induction_status: "leaving") }

        it "treats the induction record with a nil end_date as the latest" do
          travel_to a_point_in_time do
            expect(service.call(participant_profile:, date_range: ..induction_2.start_date)).to eq induction_2_nil_end_date
          end
        end
      end

      context "if a duplicate has a later end_date" do
        let!(:induction_2_later_end_date) { ect.add_induction_record(induction_programme: school_2.induction_programme, start_date: induction_2.start_date, end_date: induction_2.end_date + 1.day, induction_status: "leaving") }

        it "returns the induction record with the later end date as the latest" do
          travel_to a_point_in_time do
            expect(service.call(participant_profile:, date_range: ..induction_2.start_date)).to eq induction_2_later_end_date
          end
        end
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
          expect(service.call(participant_profile:, lead_provider: school_1.partnership.lead_provider)).to eq induction_1
          expect(service.call(participant_profile:, lead_provider: school_2.partnership.lead_provider)).to eq induction_2
          expect(service.call(participant_profile:, lead_provider: school_3.partnership.lead_provider)).to eq induction_5
        end
      end

      context "when only active partnerships should be considered" do
        it "does not include records associated with challenged partnerships" do
          travel_to a_point_in_time do
            school_2.partnership.update!(challenged_at: 2.days.ago, challenge_reason: "mistake")
            expect(service.call(participant_profile:, lead_provider: school_2.partnership.lead_provider, only_active_partnerships: true)).to be_nil
          end
        end
      end
    end

    context "when a delivery partner is supplied" do
      it "returns the latest induction record for that partner" do
        travel_to a_point_in_time do
          expect(service.call(participant_profile:, delivery_partner: school_1.partnership.delivery_partner)).to eq induction_1
          expect(service.call(participant_profile:, delivery_partner: school_2.partnership.delivery_partner)).to eq induction_2
          expect(service.call(participant_profile:, delivery_partner: school_3.partnership.delivery_partner)).to eq induction_5
        end
      end

      context "when only active partnerships should be considered" do
        it "does not include records associated with challenged partnerships" do
          travel_to a_point_in_time do
            school_2.partnership.update!(challenged_at: 2.days.ago, challenge_reason: "mistake")
            expect(service.call(participant_profile:, delivery_partner: school_2.partnership.delivery_partner, only_active_partnerships: true)).to be_nil
          end
        end
      end
    end

    context "when a school is supplied" do
      it "returns the latest induction record for that school" do
        travel_to a_point_in_time do
          expect(service.call(participant_profile:, school: school_1.school)).to eq induction_1
          expect(service.call(participant_profile:, school: school_2.school)).to eq induction_2
          expect(service.call(participant_profile:, school: school_3.school)).to eq induction_5
        end
      end
    end

    context "when a schedule is supplied" do
      let(:wrong_schedule) { create(:ecf_schedule_january) }
      it "returns the latest induction record with that schedule" do
        travel_to a_point_in_time do
          expect(service.call(participant_profile:, schedule: participant_profile.schedule)).to eq induction_5
          expect(service.call(participant_profile:, schedule: wrong_schedule)).to be_nil
        end
      end
    end

    context "when a date range is supplied" do
      it "returns the latest induction record in that period" do
        travel_to a_point_in_time do
          expect(service.call(participant_profile:, date_range: Date.new(current_year, 9, 1)..Date.new(current_year, 9, 30))).to eq induction_1
          expect(service.call(participant_profile:, date_range: Date.new(current_year, 11, 2)..)).to eq induction_5
          expect(service.call(participant_profile:, date_range: ..Date.new(current_year, 11, 30))).to eq induction_3
          expect(service.call(participant_profile:, date_range: Date.new(current_year + 1, 3, 22)..)).to be_nil
          expect(service.call(participant_profile:, date_range: ..a_point_in_time)).to eq(induction_5)
        end
      end
    end
  end
end
