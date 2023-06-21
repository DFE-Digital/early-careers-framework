# frozen_string_literal: true

require "csv"

namespace :comms do
  desc "Chase pilot schools"
  task :send_pilot_chaser, %i[from_date to_date] => :environment do |_task, args|
    logger = Logger.new($stdout)

    from_date = Time.zone.parse(args.from_date).beginning_of_day
    to_date = Time.zone.parse(args.to_date).end_of_day

    unless from_date && to_date
      logger.info "Can't parse the dates provided. Try again with this format: dd/mm/yyyy"
      exit
    end

    dates = from_date..to_date

    # SIT
    sit_email_addresses = Email
                            .tagged_with(:pilot_ask_sit_to_report_school_training_details)
                            .where(created_at: dates)
                            .select(:to)
                            .flat_map(&:to)

    sit_email_addresses.each do |email_address|
      sit_user = User.find_by_email(email_address)

      if sit_user.nil?
        logger.error "Unable to find the SIT"
        next
      end

      school = sit_user.induction_coordinator_profile.schools.first

      # skip if the school has already reported a training programme for 2023
      next if school.school_cohorts.for_year(2023).first&.induction_programme_choice

      if Email.tagged_with(:pilot_chase_sit_to_report_school_training_details).associated_with(sit_user).any?
        logger.info "The user with id #{sit_user.id} has been already contacted"
        next
      end

      logger.info "Sending comms to the school's SIT with user id: #{sit_user.id}"
      nomination_token = create_nomination_token(school, email_address)
      SchoolMailer
        .with(
          sit_user:,
          nomination_link: get_sit_nomination_url(token: nomination_token),
        )
        .pilot_chase_sit_to_report_school_training_details
        .deliver_later
    end

    # GIAS
    gias_email_addresses = Email
                            .tagged_with(:pilot_ask_gias_contact_to_report_school_training_details)
                            .where(created_at: dates)
                            .select(:to)
                            .flat_map(&:to)

    gias_email_addresses.each do |email_address|
      school = School.find_by_primary_contact_email(email_address)

      if school.nil?
        logger.error "Unable to find the school"
        next
      end

      # Skip if the GIAS contact has already nominated a SIT
      next if school.induction_coordinators.any?

      if Email.tagged_with(:pilot_chase_gias_contact_to_report_school_training_details).associated_with(school).any?
        logger.info "The school's primary GIAS has been already contacted"
        next
      end
      logger.info "Sending comms to the school's primary GIAS contact"

      nomination_token = create_nomination_token(school, email_address)

      SchoolMailer
        .with(
          school:,
          gias_contact_email: email_address,
          nomination_link: get_gias_nomination_url(token: nomination_token),
        )
        .pilot_chase_gias_contact_to_report_school_training_details
        .deliver_later
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

def create_nomination_token(school, email_address)
  NominationEmail.create_nomination_email(
    sent_at: Time.zone.now,
    sent_to: email_address,
    school:,
  ).token
end
