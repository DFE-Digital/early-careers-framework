# frozen_string_literal: true

module Migration::NPQRegistration::Source
  class BaseRecord < ApplicationRecord
    self.abstract_class = true

    connects_to database: { reading: :npq_registration, writing: :npq_registration }
  end
end
