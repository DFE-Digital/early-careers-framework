# frozen_string_literal: true

namespace :extended_schedules do
  desc "Fix schedule for unfinished 2021 participants moved to 2024 cohort"
  task run: :environment do
    schedule_identifier = "ecf-extended-september"
    cohort = Cohort.find_by_start_year(2024)
    schedule = Finance::Schedule::ECF.find_by(cohort:, schedule_identifier:)
    participants = ParticipantProfile.where(cohort_changed_after_payments_frozen: true).to_a

    participants.map do |participant_profile|
      # exclude those already in the extended schedule
      if participant_profile.schedule == schedule
        puts "#{participant_profile.id}: already in extended schedule!"
        next
      end

      # exclude those with submitted or billable declarations in a non-frozen cohort
      if participant_profile.participant_declarations
                            .joins(:cohort)
                            .billable_or_changeable
                            .where(cohorts: { payments_frozen_at: nil })
                            .exists?
        puts "#{participant_profile.id}: failed! (has blocking declarations in not frozen cohort)"
        next
      end

      induction_record = participant_profile.latest_induction_record
      school = induction_record.school
      target_school_cohort = SchoolCohort.find_by(school:, cohort:)
      induction_programme = if induction_record && induction_record.cohort == cohort
                              induction_record.induction_programme
                            else
                              target_school_cohort&.default_induction_programme
                            end

      ActiveRecord::Base.transaction do
        Induction::ChangeInductionRecord.call(induction_record:,
                                              changes: { induction_programme:, schedule: })
        participant_profile.update!(school_cohort: target_school_cohort, schedule:)

        puts "#{participant_profile.id}: success!"
      rescue ActiveRecord::RecordInvalid => e
        puts "#{participant_profile.id}: failed! (#{e.message})"
      end
    end
  end
end
