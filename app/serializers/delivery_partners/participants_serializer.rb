# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module DeliveryPartners
  class ParticipantsSerializer
    include JSONAPI::Serializer
    include JSONAPI::Serializer::Instrumentation

    class << self
      def induction_record(participant_profile, delivery_partner)
        @induction_record ||= {}
        @induction_record["#{participant_profile.id},#{delivery_partner.id}"] ||= participant_profile.relevant_induction_record_for(delivery_partner:)
      end

      def status_name(participant_profile, delivery_partner)
        ParticipantProfileStatus.new(
          participant_profile:,
          induction_record: induction_record(participant_profile, delivery_partner),
        ).status_name
      end
    end

    set_type :participant

    attribute :full_name do |participant_profile|
      participant_profile.user.full_name
    end

    attribute :email_address do |participant_profile, params|
      induction_record(participant_profile, params[:delivery_partner])&.preferred_identity&.email ||
        participant_profile.user.email
    end

    attribute :trn do |participant_profile|
      participant_profile.teacher_profile.trn
    end

    attribute :role, &:role

    attribute :lead_provider do |participant_profile, params|
      induction_record(participant_profile, params[:delivery_partner])&.induction_programme&.partnership&.lead_provider&.name
    end

    attribute :school do |participant_profile, params|
      induction_record(participant_profile, params[:delivery_partner])&.school&.name
    end

    attribute :school_unique_reference_number do |participant_profile, params|
      induction_record(participant_profile, params[:delivery_partner])&.school&.urn
    end

    attribute :academic_year do |participant_profile|
      participant_profile.cohort&.start_year
    end

    attribute :training_status do |participant_profile, params|
      induction_record(participant_profile, params[:delivery_partner])&.training_status
    end

    attribute :status do |participant_profile, params|
      I18n.t("participant_profile_status.status.#{status_name(participant_profile, params[:delivery_partner])}.title")
    end
  end
end
