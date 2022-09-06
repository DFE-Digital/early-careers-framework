# frozen_string_literal: true

# Given a list of participant email addresses, a source year and a target year,
# move the participants from the cohort starting the source year to the one
# starting the target year.
# Meant to be run after SITs enroll participants in the wrong school cohort:
#
#   emails = %w[email_1 email_2 email_3 email_4]
#   Induction::AmendParticipantsCohort.call(*emails,
#                                           source_cohort_start_year: 2021,
#                                           target_cohort_start_year: 2022)
#
#   Returns a hash like this:
#     {
#       success: [email_1, email_3],
#       fail: {
#         email_2 => "Error after processing email_2",
#         email_4 => "Error after processing email_4",
#       }
#     }
class Induction::AmendParticipantsCohort < BaseService
  attr_reader :emails, :result, :source_cohort_start_year, :target_cohort_start_year

  def call
    process_emails
    result
  end

private

  def initialize(*emails, source_cohort_start_year:, target_cohort_start_year:)
    @emails = emails.select(&:present?)
    @source_cohort_start_year = source_cohort_start_year
    @target_cohort_start_year = target_cohort_start_year
  end

  def failed(email:, error:)
    result[:fail].merge!(email => { error.attribute => error.message })
  end

  def process_emails
    setup
    emails.each do |email|
      form = Schools::AmendParticipantCohortForm.new(email:, source_cohort_start_year:, target_cohort_start_year:)
      form.save ? success(email:) : failed(email:, error: form.errors.first)
    end
  end

  def setup
    @result = { success: [], fail: {} }
  end

  def success(email:)
    result[:success] << email
  end
end
