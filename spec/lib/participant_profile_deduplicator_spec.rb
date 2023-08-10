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

    it { is_expected.to eq(instance.changes) }

    context "when dry_run is true" do
      let(:dry_run) { true }

      it "does not make any changes, but logs out as if it does" do
        expect { dedup! }.not_to change(ParticipantProfile::ECF, :count)
        expect_changes([
          "~~~ DRY RUN ~~~",
          "Destroyed duplicate profile.",
        ])
      end
    end

    context "when the lead providers are different" do
      let(:duplicate_profile) { create(:ect) }

      it { expect { dedup! }.to raise_error(described_class::DeduplicationError, "Only duplicates with the same lead_provider are supported.") }
    end

    context "when the schedules are different" do
      before { duplicate_profile.latest_induction_record.update(schedule: create(:schedule, name: "other")) }

      it { expect { dedup! }.to raise_error(described_class::DeduplicationError, "Only duplicates with the same schedule are supported.") }
    end

    context "when the training programmes are different" do
      before { create(:induction_record, participant_profile: primary_profile) }

      it { expect { dedup! }.to raise_error(described_class::DeduplicationError, "Only duplicates with the same training programme are supported.") }
    end

    context "when duplicate profile is ECT and primary profile is Mentor" do
      let(:primary_profile) { create(:mentor) }

      it "logs a warning" do
        dedup!

        expect_changes("WARNING: transition from ECT to Mentor may not indicate a duplication.")
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

      expect_changes("Destroyed duplicate profile.")
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

      before { duplicate_profile.latest_induction_record.update!(partnership: primary_latest_induction_record.partnership) }

      it "transfers the latest induction record" do
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

        expect_changes([
          "Duplicate profile latest induction record transferred. End date: #{end_date}.",
          "Preferred identity updated on duplicate profile latest induction record.",
        ])
      end

      it "sets school_transfer to true on the primary profile's oldest induction record" do
        expect { dedup! }.to change { primary_oldest_induction_record.reload.school_transfer }.from(false).to(true)

        expect_changes("Primary profile oldest induction record set as school transfer.")
      end

      context "when the duplicate preferred_identity#user is the same as the primary" do
        before do
          user = primary_latest_induction_record.preferred_identity.user
          duplicate_induction_record.preferred_identity.update!(user:)
        end

        it "does not update the preferred identity on the transferred induction record" do
          expect { dedup! }.not_to change { duplicate_induction_record.reload.preferred_identity }
          expect(instance.changes).not_to include("Preferred identity updated on duplicate profile induction record.")
        end
      end
    end

    context "when the duplicate has multiple induction records" do
      before { create(:induction_record, participant_profile: duplicate_profile) }

      it "transfers all of the induction records" do
        expect { dedup! }.to change(primary_profile.induction_records, :count).by(duplicate_profile.induction_records.count)
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

      expect_changes("Validation data transferred.")
    end

    it "transfers ecf_participant_eligibility from the duplicate to the primary" do
      duplicate_eligibility = duplicate_profile.ecf_participant_eligibility

      expect { dedup! }.to change { duplicate_eligibility.reload.participant_profile_id }.to(primary_profile.id)

      expect_changes("Eligibility transferred.")
    end

    context "when there are declarations" do
      let(:primary_profile) { create(:ect, :eligible_for_funding) }

      let!(:duplicate_declaration) do
        travel_to(1.day.ago) do
          create(:ect_participant_declaration,
                 :submitted,
                 declaration_type: "retained-1",
                 participant_profile: duplicate_profile,
                 cpd_lead_provider: duplicate_profile.lead_provider.cpd_lead_provider)
        end
      end
      let!(:conflicting_declaration) do
        create(:ect_participant_declaration,
               :submitted,
               declaration_type: "retained-1",
               participant_profile: primary_profile,
               cpd_lead_provider: primary_profile.lead_provider.cpd_lead_provider)
      end

      it "transfers declarations from the duplicate to the primary" do
        dedup!

        expect(duplicate_declaration.reload).to have_attributes(
          participant_profile_id: primary_profile.id,
          user_id: primary_profile.user_id,
        )

        expect_changes([
          "User changed on declaration (#{duplicate_declaration.id}).",
          "Transferred declaration: retained-1, submitted (#{duplicate_declaration.id}).",
        ])
      end

      context "when the user in the duplicate declaration matches the primary profile user" do
        before { duplicate_declaration.update!(user_id: primary_profile.user_id) }

        it "does not log out the user change" do
          dedup!
          expect(instance.changes).not_to include("User changed on declaration (#{duplicate_declaration.id}).")
        end
      end

      it "voids the later declaration when there are conflicts" do
        expect { dedup! }.to change { conflicting_declaration.reload.state }.to("voided")
        expect_changes("Voided conflicting declaration: retained-1, submitted (#{conflicting_declaration.id}).")
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
  end

  def expect_changes(changes)
    Array.wrap(changes).each do |change|
      expect(instance.changes).to include(change)
      expect(Rails.logger).to have_received(:info).with(change)
    end
  end
end
