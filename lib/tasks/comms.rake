# frozen_string_literal: true

require "csv"

namespace :comms do
  desc "Send the comms to the schools in the pilot"
  task :send_pilot, [:path_to_csv] => :environment do |_task, args|
    logger = Logger.new($stdout)

    rows = CSV.read(args.path_to_csv, headers: true)

    rows.each do |school|
      logger.info "Processing school with URN: #{school['urn']}"

      school = School.find_by_urn(school["urn"])

      if school.nil?
        logger.error "Unable to find school"
        next
      end

      if school.induction_coordinators.any?
        school.induction_coordinators.each do |sit_user|
          if Email.tagged_with(:pilot_ask_sit_to_report_school_training_details_for_2024).associated_with(sit_user).where.not(status: Email::FAILED_STATUSES).any?
            logger.info "The user with id #{sit_user.id} has been already contacted"
            next
          end

          logger.info "Sending comms to the school's SIT with user id: #{sit_user.id}"
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
        if Email.tagged_with(:pilot_ask_gias_contact_to_report_school_training_details_for_2024).associated_with(school).where.not(status: Email::FAILED_STATUSES).any?
          logger.info "The school's primary GIAS has been already contacted"
          next
        end

        gias_contact_email = school.primary_contact_email || school.secondary_contact_email
        unless gias_contact_email
          logger.error "No GIAS contacts found for this school"
          next
        end

        logger.info "Sending launch email to the school's GIAS contact"
        nomination_token = create_nomination_token(school, gias_contact_email)
        SchoolMailer
          .with(
            school:,
            gias_contact_email: school.primary_contact_email,
            opt_in_out_link: get_opt_in_out_url(token: nomination_token),
          )
          .pilot_ask_gias_contact_to_report_school_training_details
          .deliver_later
      end
    end
  end

  desc "Chase pilot schools"
  task :send_pilot_chaser, [:path_to_csv] => :environment do |_task, args|
    logger = Logger.new($stdout)

    rows = CSV.read(args.path_to_csv, headers: true)

    rows.each do |school|
      logger.info "Processing school with URN: #{school['urn']}"

      school = School.find_by_urn(school["urn"])

      if school.nil?
        logger.error "Unable to find the school"
        next
      end

      if school.induction_coordinators.any?
        # Do not chase the school if there is a 2024 training programme
        if school.school_cohorts.for_year(2024).first&.induction_programme_choice
          logger.info "School has reported the training programme"
          next
        end

        school.induction_coordinators.each do |sit_user|
          if Email.tagged_with(:pilot_chase_sit_to_report_school_training_details_for_2024).associated_with(sit_user).where.not(status: Email::FAILED_STATUSES).any?
            logger.info "The user has been already contacted"
            next
          end

          logger.info "Sending chaser email to the school's SIT with user id: #{sit_user.id}"
          nomination_token = create_nomination_token(school, sit_user.email)
          SchoolMailer
            .with(
              sit_user:,
              nomination_link: get_sit_nomination_url(token: nomination_token),
            )
            .pilot_chase_sit_to_report_school_training_details
            .deliver_later
        end
      else
        if Email.tagged_with(:pilot_chase_gias_contact_to_report_school_training_details_for_2024).associated_with(school).where.not(status: Email::FAILED_STATUSES).any?
          logger.info "The school's primary GIAS has been already contacted"
          next
        end

        gias_contact_email = school.primary_contact_email || school.secondary_contact_email
        unless gias_contact_email
          logger.error "No GIAS contacts found for this school"
          next
        end

        logger.info "Sending chaser email to the school's GIAS contact"
        nomination_token = create_nomination_token(school, gias_contact_email)
        SchoolMailer
          .with(
            school:,
            gias_contact_email: school.primary_contact_email,
            opt_in_out_link: get_opt_in_out_url(token: nomination_token),
          )
          .pilot_chase_gias_contact_to_report_school_training_details
          .deliver_later
      end
    end
  end

  desc "Send launch comms to SITs"
  task :send_sit_launch_comms, [:path_to_csv] => :environment do |_task, args|
    logger = Logger.new($stdout)

    rows = CSV.read(args.path_to_csv, headers: true)

    rows.each do |school|
      logger.info "Processing school with URN: #{school['urn']}"

      school = School.find_by_urn(school["urn"])

      if school.school_cohorts.for_year(2024).first&.induction_programme_choice
        logger.info "School has reported the training programme"
        next
      end

      school.induction_coordinators.each do |sit_user|
        if Email.tagged_with(:launch_ask_sit_to_report_school_training_details_for_2025).associated_with(sit_user).where.not(status: Email::FAILED_STATUSES).any?
          logger.info "The SIT has been already contacted"
          next
        end

        logger.info "Sending launch email to the school's SIT with user id: #{sit_user.id}"
        nomination_token = create_nomination_token(school, sit_user.email)
        SchoolMailer
          .with(
            sit_user:,
            nomination_link: get_sit_nomination_url(token: nomination_token),
          )
          .launch_ask_sit_to_report_school_training_details
          .deliver_later
      end
    end
  end

  desc "Send launch comms to GIAS contacts"
  task :send_gias_launch_comms, [:path_to_csv] => :environment do |_task, args|
    logger = Logger.new($stdout)

    rows = CSV.read(args.path_to_csv, headers: true)

    rows.each do |school|
      logger.info "Processing school with URN: #{school['urn']}"

      school = School.find_by_urn(school["urn"])

      if school.induction_coordinators.any?
        logger.info "The GIAS contact has already nominated a SIT"
        next
      end

      if Email.tagged_with(:launch_ask_gias_contact_to_report_school_training_details_for_2024).associated_with(school).where.not(status: Email::FAILED_STATUSES).any?
        logger.info "The school's GIAS contact has been already contacted"
        next
      end

      gias_contact_email = school.primary_contact_email || school.secondary_contact_email
      unless gias_contact_email
        logger.error "No GIAS contacts found for this school"
        next
      end

      logger.info "Sending launch email to the school's GIAS contact"
      nomination_token = create_nomination_token(school, gias_contact_email)
      SchoolMailer
        .with(
          school:,
          gias_contact_email:,
          opt_in_out_link: get_opt_in_out_url(token: nomination_token),
        )
        .launch_ask_gias_contact_to_report_school_training_details
        .deliver_later
    end
  end

  desc "Send comms to SITs from Best Practice Network partnered schools"
  task :contact_bpn_school_sits, [:path_to_csv] => :environment do |_task, args|
    logger = Logger.new($stdout)

    rows = CSV.read(args.path_to_csv, headers: true)

    rows.each do |row|
      school_urn = row["urn"]
      logger.info "Processing school with URN: #{school_urn}"

      school = School.includes(:induction_coordinators).find_by_urn(school_urn)

      if school.nil?
        logger.error "Unable to find school"
        next
      end

      if school.induction_coordinators.empty?
        logger.error "Unable to find a SIT"
        next
      end

      school.induction_coordinators.each do |sit_user|
        if Email.tagged_with(:ask_bpn_school_sit_to_report_school_training_details).associated_with(sit_user).where.not(status: Email::FAILED_STATUSES).any?
          logger.info "The SIT with user id #{sit_user.id} has been already contacted"
          next
        end

        logger.info "Sending comms to SIT with user id: #{sit_user.id}"
        nomination_token = create_nomination_token(school, sit_user.email)
        SchoolMailer
          .with(
            sit_user:,
            nomination_link: get_sit_nomination_url(token: nomination_token),
          )
          .ask_bpn_school_sit_to_report_school_training_details
          .deliver_now
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

def get_opt_in_out_url(token:)
  Rails
    .application
    .routes
    .url_helpers
    .choose_how_to_continue_url(token:, host: Rails.application.config.domain)
end

def create_nomination_token(school, email_address)
  NominationEmail.create_nomination_email(
    sent_at: Time.zone.now,
    sent_to: email_address,
    school:,
  ).token
end
