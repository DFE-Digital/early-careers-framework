# frozen_string_literal: true

require "csv"

class AdditionalEmailImporter
  attr_reader :logger
  attr_reader :source_file

  def initialize(logger, source_file = nil)
    @logger = logger
    @source_file = source_file
  end

  def run
    CSV.foreach(data_file, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
      import_email(row)
    end
  end

private

  def data_file
    source_file || Rails.root.join("data/emails.csv")
  end

  def import_email(row)
    urn = row.fetch("urn")
    school = School.find_by(urn: urn)
    logger.info "Could not find school with URN #{urn}" and return unless school

    email = row.fetch("email")
    email.downcase!
    email.gsub!(/[\/:]/, "")
    return unless email_good?(email)

    AdditionalSchoolEmail.find_or_create_by!(school: school, email: email)
  end

  def email_good?(email)
    return false if email.blank?

    return false unless matches_keywords(email)
    return false if matches_banned_words(email)

    true
  end

  def matches_keywords(email)
    keywords = %w[head info enquiries office admin hello principal secretary reception]
    keywords.any? { |keyword| email.include?(keyword) }
  end

  def matches_banned_words(email)
    banned_words = %w[covid corona emergency admissions recruitment absences officer mailto]
    banned_words.any? { |banned_word| email.include?(banned_word) }
  end
end
