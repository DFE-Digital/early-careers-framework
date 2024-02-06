# frozen_string_literal: true

module Admin::Performance
  class ValidationErrorsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @pagy, @validation_errors = pagy_array(ValidationError.list_of_distinct_errors_with_count, items: 50)
    end

    def show
      @form_object = params[:form]
      @attribute = params[:attribute]
      @pagy, @validation_errors = pagy(ValidationError.search({ form_object: @form_object, attribute: @attribute }), items: 50)
    end
  end
end
