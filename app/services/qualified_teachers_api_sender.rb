# frozen_string_literal: true

class QualifiedTeachersApiSender
  include ActiveModel::Model
  include ActiveModel::Attributes

  SUCCESS_CODES = %w[204].freeze

  attribute :participant_outcome_id

  validates :participant_outcome_id, presence: { message: I18n.t("errors.participant_outcomes.missing_participant_outcome_id") }
  validates :participant_outcome, presence: { message: I18n.t("errors.participant_outcomes.missing_participant_outcome") }
  validate :not_already_successfully_sent
  validate :sent_with_trn_not_found

  def call
    return if invalid?

    set_sent_to_qualified_teachers_api_at
    create_participant_outcome_api_request!
    set_qualified_teachers_api_request_successful!
    participant_outcome
  end

  def participant_outcome
    @participant_outcome ||= ParticipantOutcome::NPQ.includes(participant_declaration: { participant_profile: :teacher_profile }).find_by(id: participant_outcome_id)
  end

private

  def not_already_successfully_sent
    return unless participant_outcome&.qualified_teachers_api_request_successful?

    errors.add(:participant_outcome, I18n.t("errors.participant_outcomes.already_successfully_sent_to_api"))
  end

  def sent_with_trn_not_found
    return unless participant_outcome&.participant_outcome_api_requests&.trn_not_found&.any?

    errors.add(:participant_outcome, I18n.t("errors.participant_outcomes.trn_not_found"))
  end

  def set_sent_to_qualified_teachers_api_at
    participant_outcome.update_column(
      :sent_to_qualified_teachers_api_at, Time.zone.now
    )
  end

  def create_participant_outcome_api_request!
    participant_outcome.participant_outcome_api_requests.create!(
      request_path: api_response.response.uri.to_s,
      status_code: api_response.response.code,
      request_headers: api_response.request.each_header.to_h.except("authorization"),
      request_body: request_body.stringify_keys,
      response_headers: api_response.response.each_header.to_h,
      response_body: response_body(api_response.response.body),
    )
  rescue StandardError => e
    Rails.logger.warn(e.message)
    Sentry.capture_exception(e)
  end

  def set_qualified_teachers_api_request_successful!
    participant_outcome.update!(
      qualified_teachers_api_request_successful: SUCCESS_CODES.include?(api_response.response.code),
    )
  end

  def qualified_teachers_client
    @qualified_teachers_client ||= QualifiedTeachers::Client.new
  end

  def request_body
    @request_body ||= {
      completionDate: participant_outcome.completion_date.to_s,
      qualificationType: participant_outcome.participant_declaration.qualification_type,
    }
  end

  def trn
    @trn ||= participant_outcome.participant_declaration&.participant_profile&.teacher_profile&.trn
  end

  def api_response
    @api_response ||= qualified_teachers_client.send_record(trn:, request_body:)
  end

  def response_body(response_data)
    return if response_data.blank?

    JSON.parse(response_data)
  rescue JSON::ParserError
    { error: "response data did not contain valid JSON" }
  end
end
