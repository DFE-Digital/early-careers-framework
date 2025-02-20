# frozen_string_literal: true

require "rails_helper"
require "participant_profile_deduplicator"

describe ParticipantProfileDeduplicator do
  let(:primary_profile) { create(:ect) }
  let(:duplicate_profile) { create(:ect, :eligible_for_funding, school_cohort: primary_profile.school_cohort) }
  let(:dry_run) { false }
  let!(:instance) { described_class.new(primary_profile.id, duplicate_profile.id, dry_run:) }

  before { allow(Rails.logger).to receive(:info) }

  describe "#dedup!" do
    subject(:dedup!) { instance.dedup! }

    it { is_expected.to eq(instance.recorded_info) }

    context "when dry_run is true" do
      let(:dry_run) { true }

      it "does not make any changes, but logs out as if it does" do
        expect { dedup! }.not_to change(ParticipantProfile::ECF, :count)
        expect(instance).to have_recorded_info([
          "~~~ DRY RUN ~~~",
          "User: #{primary_profile.user.id}",
          "Primary profile: #{primary_profile.id}",
          "Duplicate profile: #{duplicate_profile.id}",
          "Destroyed duplicate profile.",
        ])
      end
    end

    context "when the lead providers are different but the schools are the same" do
      let(:duplicate_profile) do
        create(:ect) do |ect|
          ect.update!(school_cohort: primary_profile.school_cohort)
          ect.latest_induction_record.update!(school_cohort: primary_profile.school_cohort)
        end
      end

      it "deletes the duplicate without reconciling" do
        expect { dedup! }.not_to change { primary_profile.induction_records.reload.count }
      end

      context "when there are declarations on the duplicate" do
        let!(:duplicate_declaration) do
          travel_to duplicate_profile.schedule.milestones.find_by(declaration_type: "retained-1").start_date + 2.days do
            create(:ect_participant_declaration,
                   :submitted,
                   declaration_type: "retained-1",
                   participant_profile: duplicate_profile,
                   cpd_lead_provider: duplicate_profile.lead_provider.cpd_lead_provider)
          end
        end

        it { expect { dedup! }.to raise_error(described_class::DeduplicationError, "Lead provider change retaining the same school is not supported when there are declarations on the duplicate") }
      end
    end

    context "when the training programmes are different" do
      let(:induction_programme) { create(:induction_programme, :cip) }

      before { create(:induction_record, participant_profile: duplicate_profile, induction_programme:) }

      it "logs a warning" do
        dedup!

        expect(instance).to have_recorded_info("WARNING: induction programmes are different (double check primary/duplicate ordering).")
      end
    end

    context "when deduplicating Mentor profiles" do
      let(:primary_profile) { create(:mentor) }
      let(:duplicate_profile) { create(:mentor) }
      let(:other_mentor) { create(:mentor) }

      let!(:duplicate_mentee) { create(:ect, mentor_profile: duplicate_profile) }
      let!(:relevant_historical_induction_record) { travel_to(1.day.ago) { create(:induction_record, participant_profile: duplicate_mentee, mentor_profile: duplicate_profile) } }
      let!(:irrelevant_historical_induction_record) { travel_to(2.days.ago) { create(:induction_record, participant_profile: duplicate_mentee, mentor_profile: other_mentor) } }
      let!(:other_mentee_relevant_historical_induction_record) { create(:induction_record, mentor_profile: duplicate_profile) }

      it "transfers the duplicate profile mentees to the primary profile" do
        dedup!

        # Transfer mentee to the primary profile
        expect(primary_profile.mentee_profiles).to include(duplicate_mentee)

        # Update relevant induction records on the mentee to point to the primary
        expect(duplicate_mentee.latest_induction_record.reload).to have_attributes({ mentor_profile_id: primary_profile.id })
        expect(relevant_historical_induction_record.reload).to have_attributes({ mentor_profile_id: primary_profile.id })
        # Don't update induction records pointing to another mentor
        expect(irrelevant_historical_induction_record.reload).to have_attributes({ mentor_profile_id: other_mentor.id })

        # Don't transfer mentees that are not currently with the duplicate mentor
        expect(primary_profile.mentee_profiles).not_to include(other_mentee_relevant_historical_induction_record.participant_profile)
        # But do update relevant induction records on these mentees
        expect(other_mentee_relevant_historical_induction_record.reload).to have_attributes({ mentor_profile_id: primary_profile.id })
      end
    end

    context "when duplicate profile is ECT and primary profile is Mentor" do
      let(:primary_profile) { create(:mentor) }

      it "logs a warning" do
        dedup!

        expect(instance).to have_recorded_info("WARNING: transition from ECT to Mentor may not indicate a duplication.")
      end
    end

    it "destroys the duplicate profile and associated data" do
      create(:induction_record, participant_profile: duplicate_profile)
      validation_decision = duplicate_profile.validation_decisions.build(validation_step: "test")
      participant_profile_state = create(:participant_profile_state, participant_profile: duplicate_profile)
      schedule = ParticipantProfileSchedule.create!(participant_profile: duplicate_profile, schedule: Finance::Schedule.first)
      validation_data = duplicate_profile.ecf_participant_validation_data
      eligibility = duplicate_profile.ecf_participant_eligibility

      expect { dedup! }.to change(ParticipantProfile::ECF, :count).by(-1)

      expect { eligibility.reload }.not_to raise_error
      expect { validation_data.reload }.not_to raise_error

      expect { schedule.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { participant_profile_state.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { validation_decision.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { duplicate_profile.reload }.to raise_error(ActiveRecord::RecordNotFound)

      expect(instance).to have_recorded_info("Destroyed duplicate profile.")
    end

    context "when the school has changed" do
      let(:duplicate_profile) { create(:ect) }
      let!(:oldest_induction_record) do
        travel_to(3.days.ago) do
          preferred_identity = primary_profile.latest_induction_record.preferred_identity
          induction_programme = primary_profile.latest_induction_record.induction_programme
          create(:induction_record, participant_profile: primary_profile, preferred_identity:, induction_programme:)
        end
      end
      let!(:duplicate_induction_record) { duplicate_profile.latest_induction_record }
      let(:primary_latest_induction_record) { primary_profile.latest_induction_record }
      let(:primary_oldest_induction_record) { primary_profile.induction_records.oldest }

      before do
        start_date = primary_profile.induction_records.oldest.start_date - 2.days
        duplicate_profile.latest_induction_record.update!(start_date:, partnership: primary_latest_induction_record.partnership)
      end

      it "transfers the latest induction record, setting the start_date to 1 minute before the oldest primary induction record end_date" do
        end_date = primary_oldest_induction_record.start_date - 1.minute
        preferred_identity = primary_latest_induction_record.preferred_identity

        dedup!

        duplicate_induction_record.reload
        expect(duplicate_induction_record).to have_attributes(
          participant_profile_id: primary_profile.id,
          induction_status: "leaving",
          end_date:,
          preferred_identity:,
        )

        expect(instance).to have_recorded_info([
          "Duplicate profile latest induction record transferred. End date: #{end_date}.",
          "Preferred identity updated on duplicate profile latest induction record.",
        ])
      end

      it "sets school_transfer to true on the primary profile's oldest induction record" do
        expect { dedup! }.to change { primary_oldest_induction_record.reload.school_transfer }.from(false).to(true)

        expect(instance).to have_recorded_info("Primary profile oldest induction record set as school transfer. Current school: #{primary_profile.school.urn}.")
      end

      context "when the induction record start dates are the same" do
        before do
          start_date = primary_profile.induction_records.oldest.start_date
          duplicate_profile.latest_induction_record.update!(start_date:)
        end

        it "sets the start_date to the oldest primary induction record end_date" do
          end_date = primary_oldest_induction_record.start_date

          expect { dedup! }.to change { duplicate_induction_record.reload.end_date }.to(end_date)
        end
      end

      context "when the duplicate induction record already has an end_date" do
        before do
          duplicate_profile.latest_induction_record.update!(end_date: 2.years.ago)
        end

        it "retains the end_date" do
          expect { dedup! }.not_to change { duplicate_induction_record.reload.end_date }
        end
      end

      context "when the duplicate induction record start date is after the oldest primary induction record start date" do
        before do
          start_date = primary_profile.induction_records.oldest.start_date + 1.minute
          duplicate_profile.latest_induction_record.update!(start_date:)
        end

        it "logs a warning" do
          dedup!
          expect(instance).to have_recorded_info("WARNING: induction record on the duplicate profile is after the oldest induction record on the primary profile. You may want to swap before continuing.")
        end
      end

      context "when the duplicate preferred_identity#user is the same as the primary" do
        before do
          user = primary_latest_induction_record.preferred_identity.user
          duplicate_induction_record.preferred_identity.update!(user:)
        end

        it "does not update the preferred identity on the transferred induction record" do
          expect { dedup! }.not_to change { duplicate_induction_record.reload.preferred_identity }
          expect(instance).not_to have_recorded_info("Preferred identity updated on duplicate profile induction record.")
        end
      end
    end

    context "when the duplicate has multiple induction records" do
      let!(:other_induction_record) { create(:induction_record, participant_profile: duplicate_profile, end_date: nil) }

      it "transfers all of the induction records" do
        expect { dedup! }.to change(primary_profile.induction_records, :count).by(duplicate_profile.induction_records.count)
      end

      it "ensures transferred induction records have an end_date" do
        expect { dedup! }.to change { other_induction_record.reload.end_date }
      end
    end

    it "retains a serialized record of the duplicate" do
      expect { dedup! }.to change { Finance::ECF::DeletedDuplicate.count }.by(1)

      serialized_duplicate = Finance::ECF::DeletedDuplicate.last

      expect(serialized_duplicate.data.dig("data", "id")).to eq(duplicate_profile.id)
      expect(serialized_duplicate.primary_participant_profile).to eq(primary_profile)
    end

    it "transfers ecf_participant_validation_data from the duplicate to the primary" do
      duplicate_validation_data = duplicate_profile.ecf_participant_validation_data

      expect { dedup! }.to change { duplicate_validation_data.reload.participant_profile_id }.to(primary_profile.id)

      expect(instance).to have_recorded_info("Validation data transferred.")
    end

    it "transfers ecf_participant_eligibility from the duplicate to the primary" do
      duplicate_eligibility = duplicate_profile.ecf_participant_eligibility

      expect { dedup! }.to change { duplicate_eligibility.reload.participant_profile_id }.to(primary_profile.id)

      expect(instance).to have_recorded_info("Eligibility transferred.")
    end

    context "when there are declarations" do
      let(:primary_profile) { create(:ect, :eligible_for_funding) }

      let!(:duplicate_declaration) do
        travel_to duplicate_profile.schedule.milestones.find_by(declaration_type: "retained-1").start_date + 2.days do
          create(:ect_participant_declaration,
                 :submitted,
                 declaration_type: "retained-1",
                 participant_profile: duplicate_profile,
                 cpd_lead_provider: duplicate_profile.lead_provider.cpd_lead_provider)
        end
      end
      let!(:conflicting_declaration) do
        travel_to primary_profile.schedule.milestones.find_by(declaration_type: "retained-1").start_date + 2.days do
          create(:ect_participant_declaration,
                 :submitted,
                 declaration_type: "retained-1",
                 declaration_date: duplicate_declaration.declaration_date + 1.day,
                 participant_profile: primary_profile,
                 cpd_lead_provider: primary_profile.lead_provider.cpd_lead_provider)
        end
      end

      context "when primary profile only has voided declarations and duplicate does not" do
        before { conflicting_declaration.make_voided! }

        it "logs a warning" do
          dedup!

          expect(instance).to have_recorded_info("WARNING: voided declarations on primary suggest the duplicate may be the primary. You may want to swap before continuing.")
        end
      end

      it "transfers declarations from the duplicate to the primary" do
        dedup!

        expect(duplicate_declaration.reload).to have_attributes(
          participant_profile_id: primary_profile.id,
          user_id: primary_profile.user_id,
        )

        expect(instance).to have_recorded_info([
          "User changed on declaration (#{duplicate_declaration.id}).",
          "Transferred declaration: retained-1, submitted (#{duplicate_declaration.id}).",
        ])
      end

      context "when the user in the duplicate declaration matches the primary profile user" do
        before { duplicate_declaration.update!(user_id: primary_profile.user_id) }

        it "does not log out the user change" do
          dedup!
          expect(instance).not_to have_recorded_info("User changed on declaration (#{duplicate_declaration.id}).")
        end
      end

      it "voids the later declaration when there are conflicts" do
        expect { dedup! }.to change { conflicting_declaration.reload.state }.to("voided")
        expect(instance).to have_recorded_info("Voided declaration: retained-1, submitted (#{conflicting_declaration.id}).")
      end
    end

    context "when the primary profile already has ecf_participant_validation_data/ecf_participant_eligibility" do
      let(:primary_profile) { create(:ect, :eligible_for_funding) }

      it "destroys the ecf_participant_validation_data/ecf_participant_eligibility on the duplicate" do
        validation_data = duplicate_profile.ecf_participant_validation_data
        eligibility = duplicate_profile.ecf_participant_eligibility

        dedup!

        expect { eligibility.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { validation_data.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the schedules and cohorts are different" do
      let!(:primary_profile_declaration) do
        travel_to primary_profile.schedule.milestones.find_by(declaration_type: "retained-1").start_date + 2.days do
          create(:ect_participant_declaration,
                 :submitted,
                 declaration_type: "retained-1",
                 participant_profile: primary_profile,
                 cpd_lead_provider: primary_profile.lead_provider.cpd_lead_provider)
        end
      end
      let!(:duplicate_profile_declaration) do
        travel_to duplicate_profile.schedule.milestones.find_by(declaration_type: "retained-2").start_date + 2.days do
          create(:ect_participant_declaration,
                 :submitted,
                 declaration_type: "retained-2",
                 participant_profile: duplicate_profile,
                 cpd_lead_provider: duplicate_profile.lead_provider.cpd_lead_provider)
        end
      end
      let!(:primary_profile_schedule) { primary_profile.latest_induction_record.schedule }
      let(:duplicate_profile_cohort) { create(:cohort, start_year: primary_profile.cohort.start_year + 1) }
      let!(:duplicate_profile_schedule) do
        create(:schedule, name: "other-schedule", cohort: duplicate_profile_cohort).tap do |schedule|
          duplicate_profile.latest_induction_record.update!(schedule:)
        end
      end

      before do
        school = primary_profile.school
        cohort = duplicate_profile_cohort
        default_induction_programme = create(:induction_programme)
        create(:school_cohort, school:, cohort:, default_induction_programme:)
        create(:partnership, school:, cohort:, lead_provider: primary_profile.lead_provider)
      end

      context "when the change of schedule is not valid" do
        before do
          primary_profile.latest_induction_record.training_status_withdrawn!
          primary_profile_declaration.update!(declaration_date: duplicate_profile_declaration.declaration_date + 1.day)
        end

        it { expect { dedup! }.to raise_error(described_class::DeduplicationError, "Cannot perform actions on a withdrawn participant") }
      end

      context "when the duplicate profile has the relevant schedule (by earliest declaration_date)" do
        before { primary_profile_declaration.update!(declaration_date: duplicate_profile_declaration.declaration_date + 1.day) }

        it "updates the primary profile to use the schedule from the duplicate profile" do
          dedup!

          expect(primary_profile.reload.schedule).to eq(duplicate_profile_schedule)
          expect(primary_profile.school_cohort.cohort).to eq(duplicate_profile_cohort)
          expect(instance).to have_recorded_info("Changed schedule on primary profile: #{duplicate_profile_schedule.schedule_identifier}, #{duplicate_profile_cohort.start_year} (#{duplicate_profile_schedule.id}).")
        end

        it "creates an induction record with the new schedule" do
          dedup!

          expect(primary_profile.latest_induction_record.schedule).to eq(duplicate_profile_schedule)
        end

        it "voids the declarations on the primary profile" do
          dedup!

          expect(primary_profile_declaration.reload).to be_voided
          expect(instance).to have_recorded_info("Voided declaration: retained-1, submitted (#{primary_profile_declaration.id}).")
        end
      end

      context "when the primary profile has the relevant schedule (by earliest declaration_date)" do
        before { duplicate_profile_declaration.update!(declaration_date: primary_profile_declaration.declaration_date + 1.day) }

        it "does not change the primary profile schedule" do
          dedup!

          expect(primary_profile.latest_induction_record.reload.schedule).to eq(primary_profile_schedule)
        end

        it "voids the declarations on the duplicate profile" do
          dedup!

          expect(duplicate_profile_declaration.reload).to be_voided
          expect(instance).to have_recorded_info("Voided declaration: retained-2, submitted (#{duplicate_profile_declaration.id}).")
        end
      end

      context "when the earliest declarations are not in a voidable state" do
        before do
          primary_profile_declaration.update!(declaration_date: duplicate_profile_declaration.declaration_date + 1.day)
          duplicate_profile_declaration.voided!
        end

        it "does not change the primary profile schedule (as it ignores voided declarations when determining the primary schedule)" do
          dedup!

          expect(primary_profile.latest_induction_record.reload.schedule).to eq(primary_profile_schedule)
        end
      end

      context "when there are no voidable declarations" do
        before do
          primary_profile_declaration.update!(declaration_date: duplicate_profile_declaration.declaration_date + 1.day, state: :voided)
          duplicate_profile_declaration.voided!
        end

        it "does not change the primary profile schedule" do
          dedup!

          expect(primary_profile.latest_induction_record.reload.schedule).to eq(primary_profile_schedule)
        end
      end
    end
  end
end
