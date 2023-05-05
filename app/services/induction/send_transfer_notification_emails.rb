# frozen_string_literal: true

module Induction
  # This service assumes that all transfers are requested by the incoming school for now. There
  # are three paths here:
  #
  # 1) Moving schools but lead provider is same at both schools:
  #
  #   a. Send email to existing lead provider notifying them that an internal
  #      transfer is happening.
  #   b. Send email to participant to notify them.
  #
  # 2) Moving to target schools lead provider and programme:
  #
  #   a. Send email to incoming lead provider.
  #   b. Send email to outgoing lead provider, requesting that they withdraw them.
  #   c. Send email to participant to notify them.
  #
  # 3) Moving to target school, but continuing with current lead provider.
  #
  #   a. Send email to current lead provider, notifying them to expect a new school.
  #   b. Send email to participant to notify them.
  #
  class SendTransferNotificationEmails < BaseService
    attr_reader :induction_record,
                :was_withdrawn_participant,
                :same_delivery_partner,
                :same_provider,
                :switch_to_schools_programme,
                :lead_provider_profiles_in,
                :lead_provider_profiles_out

    alias_method :was_withdrawn_participant?, :was_withdrawn_participant
    alias_method :same_delivery_partner?, :same_delivery_partner
    alias_method :same_provider?, :same_provider
    alias_method :switch_to_schools_programme?, :switch_to_schools_programme

    def initialize(
      induction_record:,
      was_withdrawn_participant:,
      same_delivery_partner:,
      same_provider:,
      switch_to_schools_programme:,
      lead_provider_profiles_in: [],
      lead_provider_profiles_out: []
    )
      @induction_record            = induction_record
      @was_withdrawn_participant   = was_withdrawn_participant
      @same_delivery_partner       = same_delivery_partner
      @same_provider               = same_provider
      @switch_to_schools_programme = switch_to_schools_programme
      @lead_provider_profiles_in   = lead_provider_profiles_in
      @lead_provider_profiles_out  = lead_provider_profiles_out
    end

    def call
      send_provider_notifications!
      send_participant_notification!
    end

  private

    def send_provider_notifications!
      if was_withdrawn_participant?
        send_provider_transfer_in_notifications
      elsif matching_lead_provider_and_delivery_partner?
        send_provider_existing_school_transfer_notifications
      elsif switch_to_schools_programme?
        send_provider_transfer_in_notifications
        send_provider_transfer_out_notifications
      else
        send_provider_new_school_transfer_notifications
      end
    end

    def matching_lead_provider_and_delivery_partner?
      same_provider? && same_delivery_partner?
    end

    def send_participant_notification!
      ParticipantTransferMailer.with(induction_record:).participant_transfer_in_notification.deliver_later
    end

    # emails to current lead provider profiles

    def send_provider_transfer_in_notifications
      lead_provider_profiles_in.each do |lead_provider_profile|
        ParticipantTransferMailer.with(induction_record:, lead_provider_profile:).provider_transfer_in_notification.deliver_later
      end
    end

    def send_provider_existing_school_transfer_notifications
      lead_provider_profiles_in.each do |lead_provider_profile|
        ParticipantTransferMailer.with(induction_record:, lead_provider_profile:).provider_existing_school_transfer_notification.deliver_later
      end
    end

    # emails to target lead provider profiles

    def send_provider_transfer_out_notifications
      lead_provider_profiles_out.each do |lead_provider_profile|
        ParticipantTransferMailer.with(induction_record:, lead_provider_profile:).provider_transfer_out_notification.deliver_later
      end
    end

    def send_provider_new_school_transfer_notifications
      lead_provider_profiles_out.each do |lead_provider_profile|
        ParticipantTransferMailer.with(induction_record:, lead_provider_profile:).provider_new_school_transfer_notification.deliver_later
      end
    end
  end
end
