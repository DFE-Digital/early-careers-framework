# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ArTransactionChanges

  self.abstract_class = true
end
