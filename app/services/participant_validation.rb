# frozen_string_literal: true

require "full_dqt/search"

class ParticipantValidation
  def initialize(date_of_birth:, trn: nil, nino: nil, full_name: nil)
    @given_date_of_birth = date_of_birth
    @given_full_name = full_name
    @given_nino = nino
    @given_trn = TeacherReferenceNumber.new(trn).formatted_trn
    @name_matches = dqt_record.name_matches?(given_full_name)
    @valid = dqt_record.valid? && (given_full_name.blank? || name_matches?)
  end

  delegate :active?,
           :active_alert?,
           :date_of_birth,
           :exempt_from_induction?,
           :induction_completion_date,
           :induction_start_date,
           :name,
           :nino,
           :no_induction?,
           :previous_induction?,
           :qts_date,
           :qts?,
           :trn,
           to: :dqt_record

  alias_method :active_alert, :active_alert?
  alias_method :no_induction, :no_induction?
  alias_method :previous_induction, :previous_induction?
  alias_method :qts, :qts?

  def name_matches?
    @name_matches
  end

  def previous_participation?
    return @previous_participation if instance_variable_defined?(:@previous_participation)

    @previous_participation = ECFIneligibleParticipant.participated.find_by(trn:).exists?
  end
  alias_method :previous_participation, :previous_participation?

  def valid?(skip_name_validation: false)
    skip_name_validation ? dqt_record.valid? : @valid
  end

private

  attr_reader :given_date_of_birth, :given_full_name, :given_nino, :given_trn

  def dqt_record
    @dqt_record ||= FullDQT::Search.new(date_of_birth: given_date_of_birth,
                                        trn: given_trn,
                                        nino: given_nino,
                                        full_name: given_full_name)
                                   .call
  end
end
