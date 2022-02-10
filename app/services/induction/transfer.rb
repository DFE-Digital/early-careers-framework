# frozen_string_literal: true

class Induction::Transfer < BaseService
  def call
    ActiveRecord::Base.transaction do
      participant_profiles.each do |participant_profile|
        current_programme = participant_profile.current_induction_record&.induction_programme
        if current_programme.present?
          Induction::Withdraw.call(
            participant_profile: participant_profile,
            induction_programme: current_programme,
            state: :transferred,
            end_date: end_date,
          )
        end

        Induction::Enrol.call(participant_profile: participant_profile,
                              induction_programme: induction_programme,
                              start_date: start_date)
      end
    end
  end

private

  attr_reader :participant_profiles, :induction_programme, :start_date, :end_date

  def initialize(participant_profiles:, end_date:, new_induction_programme:, start_date: Time.zone.now)
    @participant_profiles = Array(participant_profiles)
    @induction_programme = new_induction_programme
    @start_date = start_date
    @end_date = end_date
  end
end
