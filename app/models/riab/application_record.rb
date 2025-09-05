# frozen_string_literal: true

module RIAB
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    if Rails.env.test?
      connects_to database: { reading: :riab_test, writing: :riab_test }
    else
      connects_to database: { reading: :riab, writing: :riab }
    end

    def readonly?
      !Rails.env.test? # allow factories in test
    end
  end
end
