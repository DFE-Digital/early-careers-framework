# frozen_string_literal: true

module BulkMailers
  class SchoolReminderComms
    SCHOOL_TYPES_TO_INCLUDE = [1, 2, 3, 5, 6, 7, 8, 12, 28, 33, 34, 35, 36, 40, 44].freeze

    attr_reader :cohort, :dry_run, :email_schedule

    # Set dry_run = true to just return the number of emails that would be sent but don't send any emails
    def initialize(cohort:, dry_run: false, email_schedule: nil)
      @cohort = cohort
      @dry_run = dry_run
      @email_schedule = email_schedule
    end

    def contact_sits_that_need_to_chase_their_ab_to_register_ects
      query = Ects::WithAnAppropriateBodyAndUnregisteredQuery.call(include_cip: false)

      return query.count if dry_run

      email_count = 0

      query
        .eager_load(:user, :school)
        .find_each do |induction_record|
          ect_name = induction_record.user.full_name
          school = induction_record.school
          appropriate_body_name = appropriate_body_name(induction_record)
          lead_provider_name = induction_record.lead_provider_name
          delivery_partner_name = induction_record.delivery_partner_name

          school.induction_coordinator_profiles.each do |induction_coordinator|
            email_count += 1

            SchoolMailer
              .with(school:, induction_coordinator:, ect_name:, appropriate_body_name:, lead_provider_name:, delivery_partner_name:)
              .remind_sit_that_ab_has_not_registered_ect
              .deliver_later(wait: get_waiting_time(email_count))
          end
        end

      email_count
    end

    def contact_sits_that_need_to_appoint_an_ab_for_unregistered_ects
      query = Ects::WithoutAnAppropriateBodyAndUnregisteredQuery.call(include_cip: false)

      return query.count if dry_run

      email_count = 0

      query
        .eager_load(:user)
        .find_each do |induction_record|
          ect_name = induction_record.user.full_name
          school = induction_record.school
          lead_provider_name = induction_record.lead_provider_name
          delivery_partner_name = induction_record.delivery_partner_name

          school.induction_coordinator_profiles.each do |induction_coordinator|
            email_count += 1

            SchoolMailer
              .with(school:, induction_coordinator:, ect_name:, lead_provider_name:, delivery_partner_name:)
              .remind_sit_to_appoint_ab_for_unregistered_ect
              .deliver_later(wait: get_waiting_time(email_count))
          end
        end

      email_count
    end

    def contact_sits_that_need_to_assign_mentors
      query = Schools::WithEctsWithNoMentorQuery.call(cohort:, school_type_codes: SCHOOL_TYPES_TO_INCLUDE)

      query = query.joins(:induction_coordinator_profiles)

      return query.count if dry_run

      email_count = 0

      query
        .eager_load(:induction_coordinator_profiles)
        .find_each do |school|
          school.induction_coordinator_profiles.each do |induction_coordinator|
            email_count += 1

            SchoolMailer.with(school:, induction_coordinator:, email_schedule:).remind_sit_to_assign_mentors_to_ects_email.deliver_later(wait: get_waiting_time(email_count))
          end
        end

      email_count
    end

    def contact_sits_that_have_not_added_participants
      query = Schools::ThatHaveNotAddedParticipantsQuery.call(cohort:, school_type_codes: SCHOOL_TYPES_TO_INCLUDE)

      query = query.joins(:induction_coordinator_profiles)

      return query.count if dry_run

      email_count = 0

      # this could send a lot of email at the cohort start and may break Notify limits
      # numbers should be checked before running this (dry_run = true) and maybe changes made/different approach to batch these
      query
        .eager_load(:induction_coordinator_profiles)
        .find_each do |school|
          school.induction_coordinator_profiles.each do |induction_coordinator|
            email_count += 1

            SchoolMailer.with(school:, induction_coordinator:, email_schedule:).remind_sit_to_add_ects_and_mentors_email.deliver_later(wait: get_waiting_time(email_count))
          end
        end

      email_count
    end

    def contact_sits_that_have_not_engaged
      query = Schools::ThatRanFipLastYearButHaveNotEngagedQuery.call(cohort:, school_type_codes: SCHOOL_TYPES_TO_INCLUDE)

      query = query.joins(:induction_coordinator_profiles)

      return query.count if dry_run

      email_count = 0

      # this could send a lot of email at the cohort start and may break Notify limits
      # numbers should be checked before running this (dry_run = true) and maybe changes made/different approach to batch these
      query
        .eager_load(:induction_coordinator_profiles)
        .find_each do |school|
          school.induction_coordinator_profiles.each do |induction_coordinator|
            email_count += 1

            sit_user = induction_coordinator.user
            SchoolMailer.with(sit_user:, nomination_link: nomination_url(email: sit_user.email, school:))
              .launch_ask_sit_to_report_school_training_details
              .deliver_later(wait: get_waiting_time(email_count))
          end
        end

      email_count
    end

    def contact_schools_without_a_sit_that_have_not_engaged
      query = Schools::ThatRanFipLastYearButHaveNotEngagedQuery.call(cohort:, school_type_codes: SCHOOL_TYPES_TO_INCLUDE)

      query = query.where.missing(:induction_coordinator_profiles)

      return query.count if dry_run

      email_count = 0

      query.find_each do |school|
        gias_contact_email = school.primary_contact_email || school.secondary_contact_email

        if gias_contact_email.blank?
          Rails.logger.info("No GIAS contact for #{school.name_and_urn}")
          next
        end

        email_count += 1
        next if dry_run

        SchoolMailer.with(school:, gias_contact_email:, opt_in_out_link: opt_in_out_url(email: gias_contact_email, school:))
          .launch_ask_gias_contact_to_report_school_training_details
          .deliver_later(wait: get_waiting_time(email_count))
      end

      email_count
    end

    def contact_sits_that_have_chosen_fip_but_not_partnered_at_year_start
      query = Schools::UnpartneredLastYearAndHaveNotPartneredThisYearQuery.call(cohort:, school_type_codes: SCHOOL_TYPES_TO_INCLUDE)

      query = query.joins(:induction_coordinator_profiles)

      return query.count if dry_run

      email_count = 0

      # we don't email those that partnered last year but havent this year
      # as yet
      query.find_each do |school|
        email_count += 1
        next if dry_run

        SchoolMailer.with(school:).sit_needs_to_chase_partnership.deliver_later(wait: get_waiting_time(email_count))
      end

      email_count
    end

    def contact_sits_that_have_chosen_fip_but_not_partnered
      query = Schools::UnpartneredQuery.call(cohort:, school_type_codes: SCHOOL_TYPES_TO_INCLUDE)

      query = query.joins(:induction_coordinator_profiles)

      return query.count if dry_run

      email_count = 0

      # in year we want to email if they haven't partnered regardless
      # of whether they partnered last year or not
      query.find_each do |school|
        email_count += 1
        next if dry_run

        SchoolMailer.with(school:, email_schedule:).sit_needs_to_chase_partnership.deliver_later(wait: get_waiting_time(email_count))
      end

      email_count
    end

    def contact_sits_pre_term_to_report_any_changes
      query = Schools::PreTermReminderToReportAnyChangesQuery.call(cohort:, school_type_codes: SCHOOL_TYPES_TO_INCLUDE)

      query = query.joins(:induction_coordinator_profiles)

      return query.count if dry_run

      email_count = 0

      # this could send a lot of email at the cohort start and may break Notify limits
      # numbers should be checked before running this (dry_run = true) and maybe changes made/different approach to batch these
      query
        .eager_load(:induction_coordinator_profiles)
        .find_each do |school|
        school.induction_coordinator_profiles.each do |induction_coordinator|
          email_count += 1
          nomination_url = nomination_url(email: induction_coordinator.user.email, school:)

          SchoolMailer.with(induction_coordinator:, nomination_url:).sit_pre_term_reminder_to_report_any_changes.deliver_later(wait: get_waiting_time(email_count))
        end
      end

      email_count
    end

  private

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

    def appropriate_body_name(induction_record)
      induction_record.appropriate_body&.name || induction_record.school_cohort.appropriate_body&.name
    end

    # 5 minutes every 2500 emails
    def get_waiting_time(email_count)
      email_count / 2500 * 5.minutes
    end
  end
end
