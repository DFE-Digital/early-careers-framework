class Migration::NPQRegistration::Source::Course < Migration::NPQRegistration::Source::BaseRecord
  class << self
    def npqeyl
      find_by(identifier: NPQ_EARLY_YEARS_LEADERSHIP)
    end

    def npqltd
      find_by(identifier: NPQ_LEADING_TEACHING_DEVELOPMENT)
    end

    def ehco
      find_by(identifier: NPQ_EARLY_HEADSHIP_COACHING_OFFER)
    end
  end

  def supports_targeted_delivery_funding?
    !ehco?
  end

  def npqh?
    identifier == NPQ_HEADSHIP
  end

  def npqsl?
    identifier == NPQ_SENIOR_LEADERSHIP
  end

  def ehco?
    identifier == NPQ_EARLY_HEADSHIP_COACHING_OFFER
  end

  def eyl?
    identifier == NPQ_EARLY_YEARS_LEADERSHIP
  end

  def npqltd?
    identifier == NPQ_LEADING_TEACHING_DEVELOPMENT
  end

  def npqlpm?
    identifier == NPQ_LEADING_PRIMARY_MATHEMATICS
  end

  NPQ_HEADSHIP = "npq-headship".freeze
  NPQ_SENIOR_LEADERSHIP = "npq-senior-leadership".freeze
  NPQ_EARLY_HEADSHIP_COACHING_OFFER = "npq-early-headship-coaching-offer".freeze
  NPQ_EARLY_YEARS_LEADERSHIP = "npq-early-years-leadership".freeze
  NPQ_LEADING_TEACHING_DEVELOPMENT = "npq-leading-teaching-development".freeze
  NPQ_LEADING_PRIMARY_MATHEMATICS = "npq-leading-primary-mathematics".freeze
end
