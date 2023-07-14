# frozen_string_literal: true

class Mailers::LaunchReminderComms
  # the school_type_codes of schools we want to send reminder emails to
  SCHOOL_TYPES_TO_INCLUDE = [1, 2, 3, 5, 6, 7, 8, 12, 28, 33, 34, 35, 36, 40, 44].freeze

  attr_reader :cohort, :dry_run, :email_count

  def initialize(cohort:, dry_run: false)
    @cohort = cohort
    @dry_run = dry_run
    @email_count = 0
  end

  # SIT that has told us they will do FIP or CIP but not added participants
  def contact_sits_that_have_not_added_participants
    @email_count = 0
    sits = []

    SchoolCohort.joins(:school, :cohort)
      .includes(:school)
      .where(cohort:,
             induction_programme_choice: %w[full_induction_programme core_induction_programme])
      .where(school: schools_to_remind)
      .where.missing(:induction_records)
      .find_each do |school_cohort|
        sits << school_cohort.school.induction_coordinator_profiles
      end

    # ensure SIT is only contacted once regardless of how many schools they manage as email does not mention school
    sits.flatten.uniq.compact.each do |induction_coordinator|
      @email_count += 1

      next if dry_run

      SchoolMailer.with(induction_coordinator:).remind_sit_to_add_ects_and_mentors_email.deliver_later
    end

    self
  end

  # SIT that has added ECTs but they some/all do not have mentors
  def contact_sits_that_need_to_assign_mentors
    @email_count = 0
    sits = []

    SchoolCohort.joins(:school, :cohort)
      .includes(:school)
      .where(cohort:,
             induction_programme_choice: %w[full_induction_programme core_induction_programme])
      .where(id: SchoolCohort.where(cohort:).joins(:active_induction_records))
      .where(school: schools_to_remind)
      .find_each do |sc|
        sits << sc.school.induction_coordinator_profiles if sc.induction_records.ects.where(mentor_profile_id: nil).any?
      end

    # ensure SIT is only contacted once regardless of how many schools they manage
    sits.flatten.uniq.compact.each do |induction_coordinator|
      @email_count += 1

      next if dry_run

      SchoolMailer.with(induction_coordinator:).remind_sit_to_assign_mentors_to_ects_email.deliver_later
    end

    self
  end

  # School without SIT has not engaged - GIAS contact
  def contact_schools_without_a_sit_that_have_not_engaged
    @email_count = 0
    schools_to_remind
      .where.not(id: SchoolCohort.where(cohort:).select(:school_id))
      .where.not(id: InductionCoordinatorProfilesSchool.select(:school_id))
      .find_each do |school|
        gias_contact_email = school.primary_contact_email || school.secondary_contact_email
        next if gias_contact_email.blank?

        @email_count += 1
        next if dry_run

        SchoolMailer.with(school:, gias_contact_email:, opt_in_out_link: opt_in_out_url(email: gias_contact_email, school:))
          .launch_ask_gias_contact_to_report_school_training_details
          .deliver_later
      end
    self
  end

  # School with SIT has not engaged
  def contact_schools_with_a_sit_that_have_not_engaged
    @email_count = 0
    schools_to_remind
      .joins(:induction_coordinator_profiles)
      .where.not(id: SchoolCohort.where(cohort: Cohort.find_by(start_year: 2023)).select(:school_id))
      .find_each do |school|
        school.induction_coordinators.each do |sit_user|
          @email_count += 1

          next if dry_run

          SchoolMailer.with(sit_user:, nomination_link: nomination_url(email: sit_user.email, school:))
            .launch_ask_sit_to_report_school_training_details
            .deliver_later
        end
      end
    self
  end

private

  def schools_to_remind
    School.currently_open.in_england.where(school_type_code: SCHOOL_TYPES_TO_INCLUDE)
  end

  def nomination_token(email:, school:)
    NominationEmail.create_nomination_email(sent_at: Time.zone.now, sent_to: email, school:).token
  end

  def nomination_url(email:, school:)
    Rails.application.routes.url_helpers.start_nominate_induction_coordinator_url(token: nomination_token(email:, school:),
                                                                                  host: Rails.application.config.domain)
  end

  def opt_in_out_url(email:, school:)
    Rails.application.routes.url_helpers.choose_how_to_continue_url(token: nomination_token(email:, school:),
                                                                    host: Rails.application.config.domain)
  end
end
