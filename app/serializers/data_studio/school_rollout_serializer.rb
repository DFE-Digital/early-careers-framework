# frozen_string_literal: true

module DataStudio
  class SchoolRolloutSerializer
    include JSONAPI::Serializer

    set_id :id
    attributes :urn,
               :name,
               :sent_at,
               :opened_at,
               :notify_status,
               :induction_tutor_nominated,
               :tutor_nominated_time,
               :induction_tutor_signed_in,
               :induction_programme_choice,
               :programme_chosen_time,
               :in_partnership,
               :partnership_time
  end
end
