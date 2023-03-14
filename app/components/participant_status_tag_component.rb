# frozen_string_literal: true

class ParticipantStatusTagComponent < BaseComponent
  def initialize(profile:, induction_record: nil, has_mentees: false)
    @profile = profile
    @induction_record = induction_record
    @has_mentees = has_mentees
  end

  def call
    if profile.npq?
      render Admin::Participants::NPQValidationStatusTag.new(profile:)
    else
      govuk_tag(**tag_attributes)
    end
  end

  private

  attr_reader :profile, :induction_record, :has_mentees

  def status
    @status ||= ::Participants::StatusAtSchool.new(induction_record:, has_mentees:, profile:).call
  end

  def tag_attributes
    {
      text: t(:header, scope: translation_scope),
      colour: t(:colour, scope: translation_scope),
    }
  end

  def translation_scope
    @translation_scope ||= "schools.participants.status.#{status}"
  end
end
