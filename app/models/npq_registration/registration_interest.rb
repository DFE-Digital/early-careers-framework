class NPQRegistration::RegistrationInterest < NPQRegistration::BaseRecord
  validates :email,
            presence: true,
            length: { maximum: 128 },
            uniqueness: { case_sensitive: false },
            notify_email: true

  scope :not_yet_notified, -> { where(notified: false) }
  scope :random_sample, ->(count) { order("RANDOM()").first(count) }

  # We did not originally valid email format so we need to check this before sending
  def valid_email?
    NotifyEmailValidator.valid?(value)
  end
end
