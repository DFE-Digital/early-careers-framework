# frozen_string_literal: true

namespace :finance do
  desc "Contact schools about errors with the NQT+1 grant"
  task :send_finance_errors_with_the_nqt_plus_one_grant, [:path_to_csv] => :environment do |_task, args|
    rows = CSV.read(args.path_to_csv, headers: true)

    rows.each do |row|
      urn = row["urn"]
      school = School.find_by(urn:)
      emails = get_the_recipients_emails(school)

      emails.each do |email|
        logger.info "Processing #{urn}: #{email}"
        if Email.tagged_with(:finance_errors_with_the_nqt_plus_one_grant).associated_with(school).where(to: [email]).any?
          logger.info "Email request already submitted for #{urn}: #{email}"
          next
        end

        logger.info "Submitting email request for #{urn}: #{email}"
        SchoolMailer.with(recipient_email: email, school:)
          .finance_errors_with_the_nqt_plus_one_grant
          .deliver_later
      end
    end
  end

  desc "Contact schools about the errors with the ECF Year 2 grant"
  task :send_finance_errors_with_the_ecf_year_2_grant, [:path_to_csv] => :environment do |_task, args|
    rows = CSV.read(args.path_to_csv, headers: true)

    rows.each do |row|
      urn = row["urn"]
      school = School.find_by(urn:)
      emails = get_the_recipients_emails(school)

      emails.each do |email|
        logger.info "Processing #{urn}: #{email}"
        if Email.tagged_with(:finance_errors_with_the_ecf_year_2_grant).associated_with(school).where(to: [email]).any?
          logger.info "Email request already submitted for #{urn}: #{email}"
          next
        end

        logger.info "Submitting email request for #{urn}: #{email}"
        SchoolMailer.with(recipient_email: email, school:)
          .finance_errors_with_the_ecf_year_2_grant
          .deliver_later
      end
    end
  end

  desc "Contact schools about the errors with both the NQT+1 and ECF Year 2 grants"
  task :send_finance_errors_with_nqt_plus_one_and_ecf_year_2_schools_version, [:path_to_csv] => :environment do |_task, args|
    rows = CSV.read(args.path_to_csv, headers: true)

    rows.each do |row|
      urn = row["urn"]
      school = School.find_by(urn:)
      emails = get_the_recipients_emails(school)

      emails.each do |email|
        logger.info "Processing #{urn}: #{email}"
        if Email.tagged_with(:finance_errors_with_nqt_plus_one_and_ecf_year_2_schools_version).associated_with(school).where(to: [email]).any?
          logger.info "Email request already submitted for #{urn}: #{email}"
          next
        end

        logger.info "Submitting email request for #{urn}: #{email}"
        SchoolMailer.with(recipient_email: email, school:)
          .finance_errors_with_nqt_plus_one_and_ecf_year_2_schools_version
          .deliver_later
      end
    end
  end

  desc "Contact local authorities about the errors with both the NQT+1 and ECF Year 2 grants"
  task :send_error_emails_to_local_authorities, [:path_to_csv] => :environment do |_task, args|
    rows = CSV.read(args.path_to_csv, headers: true)

    rows.each do |row|
      local_authority_email = row["email_address"]
      local_authority_name = row["local_authority_name"]

      logger.info "Processing #{local_authority_name}: #{local_authority_email}"
      if Email.tagged_with(:finance_errors_with_nqt_plus_one_and_ecf_year_2_local_authority_version).where(to: [local_authority_email]).any?
        logger.info "Email request already submitted for #{local_authority_name}: #{local_authority_email}"
        next
      end

      logger.info "Submitting email request for #{local_authority_name}: #{local_authority_email}"
      SchoolMailer.with(local_authority_email:, local_authority_name:)
        .finance_errors_with_nqt_plus_one_and_ecf_year_2_local_authority_version
        .deliver_later
    end
  end
end

# We want to contact the schools' SITs first and fallback
# to the GIAS contants if there aren't any
def get_the_recipients_emails(school)
  if school.induction_coordinators.any?
    school.induction_coordinators.pluck(:email)
  else
    [school.primary_contact_email, school.secondary_contact_email]
  end.compact
end

def logger
  @logger = Logger.new($stdout)
end
