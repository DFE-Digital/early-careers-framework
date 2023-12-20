# frozen_string_literal: true

module Migration::NPQRegistration
  class BaseRecord < ApplicationRecord
    self.abstract_class = true

    connects_to database: { reading: :npq_registration, writing: :npq_registration }

    def readonly?
      !Rails.env.development?
    end

    def send_event(type, data)
      # We don't want to send any events for migration models!
    end
  end
end
