# frozen_string_literal: true

module Admin
  class BaseForm
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Model

    def self.permitted_params
      %i[]
    end
  end
end
