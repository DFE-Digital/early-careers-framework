# frozen_string_literal: true

class EligibilityPresenter < SimpleDelegator
  delegate :mentor?, :ect?, to: :participant_profile

  def eligibility
    eligibility_record.status.humanize.capitalize
  end

  def reason
    eligibility_record.reason.humanize.capitalize
  end

  def active_flags
    yes_no eligibility_record.active_flags?
  end

  def previous_induction
    yes_no eligibility_record.previous_induction?
  end

  def qts
    yes_no eligibility_record.qts?
  end

  def different_trn
    yes_no eligibility_record.different_trn?
  end

  def registered_induction
    yes_no !eligibility_record.no_induction?
  end

  def exempt_from_induction
    yes_no !eligibility_record.exempt_from_induction?
  end

  def duplicate_profile
    yes_no !eligibility_record.duplicate_profile?
  end

  def previous_participation
    yes_no eligibility_record.previous_participation?
  end

private

  def eligibility_record
    __getobj__
  end

  def yes_no(value)
    value.blank? ? "No" : "Yes"
  end
end
