# frozen_string_literal: true

module Schools
  module ParticipantsHelper
    ALL_CAPITALS = /\A[A-Z]+\z/

    EDIT_NAME_TEMPLATE_BY_REASON = {
      name_has_changed: :edit_name,
      name_is_incorrect: :edit_name,
      should_not_have_been_registered: :should_not_have_been_registered,
      replace_with_a_different_person: :replace_with_a_different_person,
    }.freeze

    def edit_name_reasons
      EDIT_NAME_TEMPLATE_BY_REASON.keys.map do |id|
        OpenStruct.new(id:, name: t(id, scope: :reasons_to_edit_a_participants_name))
      end
    end

    def edit_name_template(reason)
      EDIT_NAME_TEMPLATE_BY_REASON[reason&.to_sym] || :reason_to_edit_name
    end

    def participant_not_started_validation?(profile, induction_record)
      profile.contacted_for_info? ||
        profile.ineligible_but_not_duplicated_or_previously_participated? ||
        induction_record.training_status_withdrawn? ||
        induction_record.transferred?
    end

    # Returns a display type from a ParticipantProfile instance:
    #    ParticipantProfile::ECT instances => 'ECT', 'ECT', :ect for default options, downcase and symbol respectively
    #    ParticipantProfile::Mentor instances => 'Mentor', 'mentor', :mentor
    def participant_type(profile, downcase: false, symbol: false)
      type = profile.class.name.demodulize
      type = type.downcase if downcase && ALL_CAPITALS !~ type
      symbol ? type.downcase.to_sym : type
    end
  end
end
