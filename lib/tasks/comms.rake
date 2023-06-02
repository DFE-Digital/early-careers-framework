# frozen_string_literal: true

require "csv"

namespace :comms do
  desc "Send the comms to the schools in the pilot"
  task :send_pilot, [:path_to_csv] => :environment do |_task, args|
    logger = Logger.new($stdout)

    rows ||= CSV.read(args.path_to_csv, headers: true)

    rows.each do |school|
      school_urn = school["urn"]
      school_name = school["name"]

      school = School.find_by_urn(school_urn)

      if school.nil?
        logger.error "Unable to find school with URN: #{school_urn}"
        next
      end

      if school.name != school_name
        logger.error "The school with URN #{school_urn} does not matches the school name: #{school_name}"
        next
      end

      logger.info "Adding school with urn #{school_urn} to the pilot"
      FeatureFlag.activate(:cohortless_dashboard, for: school)

      if school.induction_coordinators.any?
        school.induction_coordinators.each do |sit_user|
          logger.info "Sending comms to the school's SIT with user id: #{sit_user.id}"

          if Email.tagged_with(:pilot_ask_sit_to_report_school_training_details).associated_with(sit_user).any?
            logger.info "The user with id #{sit_user.id} has been already contacted"
          end

          nomination_token = create_nomination_token(school, sit_user.email)

          SchoolMailer
            .with(
              sit_user:,
              nomination_link: get_sit_nomination_url(token: nomination_token),
            )
            .pilot_ask_sit_to_report_school_training_details
            .deliver_later
        end
      else
        logger.info "Sending comms to the school's primary GIAS contact"

        if Email.tagged_with(:pilot_ask_gias_contact_to_report_school_training_details).associated_with(school).any?
          logger.info "The school's primary GIAS has been already contacted"
        end

        nomination_token = create_nomination_token(school, school.primary_contact_email)

        SchoolMailer
          .with(
            school:,
            gias_contact_email: school.primary_contact_email,
            nomination_link: get_gias_nomination_url(token: nomination_token),
          )
          .pilot_ask_gias_contact_to_report_school_training_details
          .deliver_later
      end
    end
  end
end

def get_sit_nomination_url(token:)
  Rails
    .application
    .routes
    .url_helpers
    .start_nominate_induction_coordinator_url(token:, host: Rails.application.config.domain)
end

def get_gias_nomination_url(token:)
  Rails
    .application
    .routes
    .url_helpers
    .start_nomination_nominate_induction_coordinator_url(token:, host: Rails.application.config.domain)
end

def create_nomination_token(school, user)
  NominationEmail.create_nomination_email(
    sent_at: Time.zone.now,
    sent_to: user,
    school:,
  ).token
end
