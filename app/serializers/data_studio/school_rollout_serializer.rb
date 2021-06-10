# frozen_string_literal: true

module DataStudio
  class SchoolRolloutSerializer
    include JSONAPI::Serializer

    set_id :id
    attributes :urn, :name, :sent_at, :opened_at, :notify_status

    attributes :induction_tutor_nominated do |record|
      record.tutor_nominated_time.present?
    end

    attributes :tutor_nominated_time

    attributes :induction_tutor_signed_in do |record|
      record.induction_tutor_signed_in.present?
    end

    attributes :induction_programme_choice, :programme_chosen_time

    attributes :in_partnership do |record|
      record.partnership_time.present?
    end

    attributes :partnership_time
  end
end
