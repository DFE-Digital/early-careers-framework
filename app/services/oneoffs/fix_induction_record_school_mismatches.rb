# frozen_string_literal: true

#
# One-off to fix induction programmes pointing at two different schools.
# Each induction_record should resolve to the same school via:
# - induction_programme.partnership.school
# - induction_programme.school_cohort.school
# We use the open/closed rules below and relink to existing records when needed.

module Oneoffs
  class FixInductionRecordSchoolMismatches
    include HasRecordableInformation

    def perform_change(dry_run: true, induction_record_ids: nil)
      reset_recorded_info

      record_info("~~~ DRY RUN ~~~") if dry_run

      updated_partnership_ids = Set.new
      updated_school_cohort_ids = Set.new
      updated_induction_programme_ids = Set.new
      processed = 0
      updated = 0
      skipped = 0

      ActiveRecord::Base.transaction do
        mismatch_scope(induction_record_ids).find_each do |induction_record|
          processed += 1

          induction_programme = induction_record.induction_programme
          partnership = induction_programme.partnership
          school_cohort = induction_programme.school_cohort

          partnership_school = partnership.school
          cohort_school = school_cohort.school

          if partnership_school.open? && cohort_school.closed?
            if update_school_cohort_school(induction_record, updated_school_cohort_ids, updated_induction_programme_ids)
              updated += 1
            else
              skipped += 1
            end
          elsif partnership_school.open? && cohort_school.open?
            if update_partnership_school(induction_record, updated_partnership_ids, updated_induction_programme_ids, scenario: "both schools open")
              updated += 1
            else
              skipped += 1
            end
          elsif partnership_school.closed? && cohort_school.open?
            if update_partnership_school(induction_record, updated_partnership_ids, updated_induction_programme_ids, scenario: "partnership school closed, cohort school open")
              updated += 1
            else
              skipped += 1
            end
          else
            skipped += 1
            record_info("InductionRecord #{induction_record.id}: no rule matched (partnership school: #{partnership_school.school_status_name}, cohort school: #{cohort_school.school_status_name}).")
          end
        end

        record_info("Processed: #{processed}, Updated: #{updated}, Skipped: #{skipped}")

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

  private

    def mismatch_scope(induction_record_ids)
      scope = InductionRecord
        .joins(induction_programme: %i[partnership school_cohort])
        .joins("JOIN schools partnership_schools ON partnership_schools.id = partnerships.school_id")
        .joins("JOIN schools cohort_schools ON cohort_schools.id = school_cohorts.school_id")
        .where("partnerships.school_id <> school_cohorts.school_id")
        .includes(induction_programme: [{ partnership: :school }, { school_cohort: :school }])

      return scope if induction_record_ids.blank?

      scope.where(induction_records: { id: induction_record_ids })
    end

    def update_school_cohort_school(induction_record, updated_school_cohort_ids, updated_induction_programme_ids)
      induction_programme = induction_record.induction_programme
      school_cohort = induction_programme.school_cohort
      partnership_school = induction_programme.partnership.school

      existing_school_cohort = SchoolCohort.find_by(school: partnership_school, cohort: school_cohort.cohort)
      if existing_school_cohort.present?
        return false if updated_induction_programme_ids.include?(induction_programme.id)

        record_info("InductionRecord #{induction_record.id}: partnership school open, cohort school closed. Existing school_cohort #{existing_school_cohort.id} for target school. Updating induction_programme #{induction_programme.id} school_cohort from #{school_cohort.id} to #{existing_school_cohort.id}.")
        induction_programme.update!(school_cohort: existing_school_cohort)
        updated_induction_programme_ids.add(induction_programme.id)
        return true
      end

      return false if updated_school_cohort_ids.include?(school_cohort.id)

      record_info("InductionRecord #{induction_record.id}: partnership school open, cohort school closed. Updating school_cohort #{school_cohort.id} school from #{school_cohort.school_id} to #{partnership_school.id}.")
      school_cohort.update!(school: partnership_school)
      updated_school_cohort_ids.add(school_cohort.id)
      true
    end

    def update_partnership_school(induction_record, updated_partnership_ids, updated_induction_programme_ids, scenario:)
      induction_programme = induction_record.induction_programme
      partnership = induction_programme.partnership
      cohort_school = induction_programme.school_cohort.school

      existing_partnership = Partnership.find_by(
        school_id: cohort_school.id,
        lead_provider_id: partnership.lead_provider_id,
        delivery_partner_id: partnership.delivery_partner_id,
        cohort_id: partnership.cohort_id,
      )

      if existing_partnership.present?
        return false if updated_induction_programme_ids.include?(induction_programme.id)

        record_info("InductionRecord #{induction_record.id}: #{scenario}. Existing partnership #{existing_partnership.id} for target school. Updating induction_programme #{induction_programme.id} partnership from #{partnership.id} to #{existing_partnership.id}.")
        induction_programme.update!(partnership: existing_partnership)
        updated_induction_programme_ids.add(induction_programme.id)
        return true
      end

      return false if updated_partnership_ids.include?(partnership.id)

      partnership_school_id = partnership.school_id
      record_info("InductionRecord #{induction_record.id}: #{scenario}. Updating partnership #{partnership.id} school from #{partnership_school_id} to #{cohort_school.id}.")
      partnership.update!(school: cohort_school)
      updated_partnership_ids.add(partnership.id)
      true
    end
  end
end
