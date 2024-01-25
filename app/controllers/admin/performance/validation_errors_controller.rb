# frozen_string_literal: true

module Admin::Performance
  class ValidationErrorsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @validation_errors = ValidationError.list_of_distinct_errors_with_count
    end

    def show
      @form_object = params[:form]
      @attribute = params[:attribute]
      @validation_errors = ValidationError.search({ form_object: @form_object, attribute: @attribute })
    end
  end
end
