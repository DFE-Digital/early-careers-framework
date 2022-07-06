# frozen_string_literal: true

module AppropriateBodySelection
  module Controller
    extend ActiveSupport::Concern

    included do
      before_action :load_appropriate_body_form

      helper_method :appropriate_body_from_path, :appropriate_body_school_name
    end

    def appropriate_body_appointed
      render "/appropriate_body_selection/body_appointed"
    end

    def update_appropriate_body_appointed
      if @appropriate_body_form.valid? :body_appointed
        store_appropriate_body_form
        if @appropriate_body_form.body_appointed?
          redirect_to action: :body_type
        else
          method(appropriate_body_submit_action).call
        end
      else
        render "/appropriate_body_selection/body_appointed"
      end
    end

    def appropriate_body_type
      render "/appropriate_body_selection/body_type"
    end

    def update_appropriate_body_type
      if @appropriate_body_form.valid? :body_type
        store_appropriate_body_form
        redirect_to action: :body_selection
      else
        render "/appropriate_body_selection/body_type"
      end
    end

    def appropriate_body_selection
      render "/appropriate_body_selection/body_selection"
    end

    def update_appropriate_body
      if @appropriate_body_form.valid? :body
        store_appropriate_body_form
        # TODO: end
      else
        render "/appropriate_body_selection/body_selection"
      end
    end

  private

    def start_appropriate_body_selection(from_path:, submit_action:, school_name:, ask_appointed: true)
      session.delete(:appropriate_body_selection_form)

      session[:appropriate_body_selection] = {
        from_path:,
        submit_action:,
        school_name:,
        ask_appointed:,
      }

      if ask_appointed
        redirect_to action: :appropriate_body_appointed
      else
        redirect_to action: :appropriate_body_type
      end
    end

    def load_appropriate_body_form
      @appropriate_body_form = AppropriateBodySelectionForm.new(session[:appropriate_body_selection_form])
      @appropriate_body_form.assign_attributes(appropriate_body_form_params)
    end

    def appropriate_body_form_params
      return {} unless params.key?(:appropriate_body_selection_form)

      params.require(:appropriate_body_selection_form)
            .permit(:body_appointed,
                    :body_type,
                    :body_id)
    end

    def store_appropriate_body_form
      session[:appropriate_body_selection_form] = @appropriate_body_form.serializable_hash
    end

    def session_data
      session[:appropriate_body_selection]
    end

    def appropriate_body_from_path
      session_data[:from_path]
    end

    def appropriate_body_submit_action
      session_data[:submit_action]
    end

    def appropriate_body_school_name
      session_data[:school_name]
    end
  end
end
