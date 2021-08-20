# frozen_string_literal: true

class ParticipantStatusTagComponent < BaseComponent
  def initialize(profile:, admin: false)
    @profile = profile
    @admin = admin
  end

  def call
    if profile.npq?
      render Admin::Participants::NPQValidationStatusTag.new(profile: profile)
    else
      govuk_tag tag_attributes
    end
  end

private

  attr_reader :admin, :profile

  def tag_attributes
    return { text: "DfE to contact participant", colour: "grey" } unless FeatureFlag.active?(:participant_validation, for: profile.school_cohort.school)
    return { text: "Manual checks needed", colour: "turquoise" } if admin && profile.manual_check_needed?
    return { text: "DfE checking eligibility", colour: "blue" } if profile.ecf_participant_validation_data.present?

    { text: "DfE requested details from participant", colour: "yellow" }
  end
end
