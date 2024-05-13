# frozen_string_literal: true

class ParticipantDeclaration::Unexpected < ParticipantDeclaration; end

describe Oneoffs::BackfillDeclarationCohort do
  let(:instance) { described_class.new }

  before { allow(Rails.logger).to receive(:info) }

  describe "#perform_change" do
    let(:dry_run) { false }

    subject(:perform_change) { instance.perform_change(dry_run:) }

    it { is_expected.to eq(instance.recorded_info) }

    it "does not touch the declaration when setting the cohort (the updated_at does not change)" do
      declaration = travel_to(1.day.ago) { create(:ect_participant_declaration, :paid) }

      travel_to(1.hour.ago) { declaration.tap { |d| d.update!(cohort: nil) } }

      expect { perform_change }.to change { declaration.reload.cohort }.and not_change { declaration.reload.updated_at }
    end

    it "backfills the cohort for ECF declarations from the statement where available" do
      declaration = create(:ect_participant_declaration, :paid).tap { |d| d.update!(cohort: nil) }
      statement_cohort = declaration.statements.first.cohort
      latest_induction_record = declaration.participant_profile.latest_induction_record

      latest_induction_record.school_cohort.update!(cohort: statement_cohort.next)

      expect(statement_cohort).not_to eq(latest_induction_record.cohort)
      expect { perform_change }.to change { declaration.reload.cohort }.from(nil).to(statement_cohort)
    end

    it "backfills the cohort for NPQ declarations from the statement where available" do
      declaration = create(:npq_participant_declaration, :paid).tap { |d| d.update!(cohort: nil) }
      statement_cohort = declaration.statements.first.cohort
      profile_schedule = declaration.participant_profile.schedule

      profile_schedule.update!(cohort: statement_cohort.next)

      expect(statement_cohort).not_to eq(profile_schedule.cohort)
      expect { perform_change }.to change { declaration.reload.cohort }.from(nil).to(statement_cohort)
    end

    it "backfills the cohort for ECF declarations from profile schedule (not the induction records) when no statement is available" do
      declaration = create(:ect_participant_declaration).tap { |d| d.update!(cohort: nil) }
      latest_induction_record = declaration.participant_profile.latest_induction_record
      schedule = declaration.participant_profile.schedule

      schedule.update!(cohort: latest_induction_record.cohort.next)

      expect(declaration.statements).to be_empty
      expect(latest_induction_record.cohort).not_to eq(schedule.cohort)
      expect { perform_change }.to change { declaration.reload.cohort }.from(nil).to(schedule.cohort)
    end

    it "backfills the cohort for NPQ declarations from the profile schedule when no statement is available" do
      declaration = create(:npq_participant_declaration).tap { |d| d.update!(cohort: nil) }
      schedule = declaration.participant_profile.schedule

      expect(declaration.statements).to be_empty
      expect { perform_change }.to change { declaration.reload.cohort }.from(nil).to(schedule.cohort)
    end

    it "logs out information" do
      stub_const("#{described_class}::BATCH_SIZE", 1)

      create_list(:ect_participant_declaration, 3).each { |d| d.update!(cohort: nil) }

      perform_change

      expect(instance).to have_recorded_info([
        "Backfilling 3 declarations with a cohort",
        "Progress: 0%",
        "Progress: 33%",
        "Progress: 67%",
        "Backfill complete",
      ])
    end

    it "selects the first statement cohort when a declaration has multiple statements with different cohorts" do
      declaration = create(:ect_participant_declaration, :paid).tap { |d| d.update!(cohort: nil) }
      first_statement = declaration.statements.first

      # Simulate bad data in our system, where a declaration was declared against one statement/cohort,
      # but the participant changed cohort and the declaration was then clawed back against a different statement/cohort.
      next_cohort = first_statement.cohort.next
      declaration.participant_profile.schedule.update!(cohort: next_cohort)
      create(:ecf_statement, :next_output_fee, cpd_lead_provider: declaration.cpd_lead_provider, cohort: next_cohort)
      Finance::ClawbackDeclaration.new(declaration).call

      expect { perform_change }.to change { declaration.reload.cohort }.from(nil).to(first_statement.cohort)

      expect(instance).to have_recorded_info([
        "Declaration #{declaration.id} has multiple statements with different cohorts - selecting the first one",
      ])
    end

    it "raises an error when a cohort cannot be found" do
      declaration = create(:npq_participant_declaration).tap { |d| d.update!(cohort: nil) }
      declaration.participant_profile.schedule.update_attribute(:cohort_id, nil) # rubocop:disable Rails/SkipsModelValidations

      perform_change

      expect(instance).to have_recorded_info([
        "Cohort could not be inferred for declaration #{declaration.id}",
      ])
    end

    it "raises an error when an unexpected declaration type is encountered" do
      participant_profile = create(:npq_participant_profile)
      cpd_lead_provider = create(:cpd_lead_provider)
      course_identifier = create(:npq_course).identifier
      unexpected_declaration = ParticipantDeclaration::Unexpected.create!(
        participant_profile:,
        cpd_lead_provider:,
        user: participant_profile.user,
        course_identifier:,
        declaration_date: Time.zone.now,
        declaration_type: :"retained-1",
      )

      expect { perform_change }.to raise_error(
        described_class::UnexpectedDeclarationTypeError,
        "Unexpected declaration type: #{unexpected_declaration.class}",
      )
    end

    context "when dry_run is true" do
      let(:dry_run) { true }

      it "does not make any changes, but records the changes it would make" do
        declaration = create(:ect_participant_declaration).tap { |d| d.update!(cohort: nil) }

        expect { perform_change }.not_to change { declaration.reload.cohort }

        expect(instance).to have_recorded_info([
          "~~~ DRY RUN ~~~",
          "Backfilling 1 declarations with a cohort",
          "Backfill complete",
        ])
      end
    end
  end
end
