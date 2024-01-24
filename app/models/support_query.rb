# frozen_string_literal: true

class SupportQuery < ApplicationRecord
  VALID_SUBJECTS = %w[
    unspecified
    change-participant-lead-provider
    change-participant-date-of-birth
    change-participant-trn
    change-cohort-lead-provider
    change-cohort-delivery-partner
    change-cohort-induction-programme-choice
    trouble-nominating-induction-coordinator
    add-participant-requires-manual-transfer-ect
    add-participant-requires-manual-transfer-mentor
    add-participant-dqt-mismatch-ect
    add-participant-dqt-mismatch-mentor
    partnership-issue
  ].freeze

  belongs_to :user

  validates :user, presence: true
  validates :subject, presence: true, inclusion: { in: VALID_SUBJECTS }
  validates :message, presence: true

  def enqueue_support_query_sync_job
    SupportQuerySyncJob.perform_later(self)
  end

  def sync_to_support_queue
    return zendesk_ticket_id if zendesk_ticket_id.present?

    # If we can assign it to a user for the submitter then the first message
    # should be public, as if its from them
    # Otherwise, we should make it private to make it clear that the user
    # attached to it is not the user making the request since it will fallback
    # to the API's logged in user
    initial_comment_from_user = zendesk_user.present?

    ticket = ZendeskAPI::Ticket.create!(
      client,
      submitter_id: zendesk_user&.id,
      requester_id: zendesk_user&.id,
      subject: localised_subject,
      comment: {
        body: comment_body,
        public: initial_comment_from_user,
      },
      tags: ["ecf-web-form-support-query", "ecf-web-form-support-query-#{subject}"],
    )

    update!(zendesk_ticket_id: ticket.id)
    zendesk_ticket_id
  end

  def comment_body
    <<~BODY
      #{message}

      ---

      #{expanded_additional_information}
    BODY
  end

  def expanded_additional_information
    additional_information_string = <<~BODY
      #{user_additional_information.strip}

      #{school_additional_information&.strip}

      #{participant_profile_additional_information&.strip}

      #{cohort_additional_information&.strip}
    BODY

    additional_information_string.strip
  end

private

  def client
    Rails.application.config.zendesk_client
  end

  def zendesk_user
    @zendesk_user ||= begin
      searched_user = client.users.search(query: "email:#{user.email}").first
      return searched_user if searched_user.present? && searched_user.email == user.email

      client.users.create!(name: user.full_name, email: user.email)
    rescue StandardError
      nil
    end
  end

  def school_id
    additional_information["school_id"]
  end

  def school
    @school ||= School.find_by(id: school_id) if school_id.present?
  end

  def participant_profile_id
    additional_information["participant_profile_id"]
  end

  def cohort_year
    additional_information["cohort_year"]
  end

  def participant_profile
    @participant_profile ||= ParticipantProfile.find_by(id: participant_profile_id) if participant_profile_id.present?
  end

  def localised_subject
    I18n.t("support_query.subjects.#{subject}")
  end

  def user_additional_information
    <<~BODY
      Ticket Created By:
      User ID: #{user.id}
      Name: #{user.full_name}
      Email: #{user.email}
    BODY
  end

  def school_additional_information
    return if school.blank?

    <<~BODY
      School:
      URN: #{school.urn}
      Name: #{school.name}
    BODY
  end

  def participant_profile_additional_information
    return if participant_profile.blank?

    latest_induction_record = participant_profile.latest_induction_record

    current_information = {
      name: participant_profile.full_name,
      email: participant_profile.user.email,
      lead_provider: participant_profile.lead_provider&.name,
      delivery_partner: participant_profile.delivery_partner&.name,
      cohort: participant_profile.cohort_start_year,
      induction_status: latest_induction_record&.induction_status,
      training_status: latest_induction_record&.training_status,
      type: participant_profile.participant_type,
    }

    <<~BODY
      Participant Profile:
      User ID: #{participant_profile.user.id}
      Participant Profile ID: #{participant_profile.id}
      #{current_information.map { |key, value| "Current #{key.to_s.titleize}: #{value}" }.join("\n")}
    BODY
  end

  def cohort_additional_information
    return if cohort_year.blank?

    <<~BODY
      Cohort:
      Start Year: #{cohort_year}
    BODY
  end
end
