# frozen_string_literal: true

class SupportQuery < ApplicationRecord
  VALID_SUBJECTS = %w[
    unspecified
    change-participant-lead-provider
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

    ticket = ZendeskAPI::Ticket.create!(
      client,
      submitter_id: zendesk_user&.id,
      requester_id: zendesk_user&.id,
      subject: localised_subject,
      comment: {
        body: comment_body,
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
    <<~BODY
      Ticket Created By:
      #{user_additional_information.strip}

      School:
      #{school_additional_information.strip}

      Participant Profile:
      #{participant_profile_additional_information.strip}
    BODY
  end

private

  def client
    Rails.application.config.zendesk_client
  end

  def zendesk_user
    searched_user = client.users.search(query: "email:#{user.email}").first
    return searched_user if searched_user.email == user.email

    client.users.create!(name: user.full_name, email: user.email)
  rescue StandardError
    nil
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

  def participant_profile
    @participant_profile ||= ParticipantProfile.find_by(id: participant_profile_id) if participant_profile_id.present?
  end

  def localised_subject
    I18n.t("support_query.subjects.#{subject}")
  end

  def user_additional_information
    <<~BODY
      User ID: #{user.id}
      Name: #{user.full_name}
      Email: #{user.email}
    BODY
  end

  def school_additional_information
    return "No School Provided" if school.blank?

    <<~BODY
      URN: #{school.urn}
      Name: #{school.name}
    BODY
  end

  def participant_profile_additional_information
    return "No Participant profile Provided" if participant_profile.blank?

    <<~BODY
      ID: #{participant_profile.id}
      Current Name: #{participant_profile.full_name}
      Current Email: #{participant_profile.user.email}
    BODY
  end
end
