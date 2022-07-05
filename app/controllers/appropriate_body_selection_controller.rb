# frozen_string_literal: true

class AppropriateBodySelectionController < ApplicationController
  before_action :load_form
  helper_method :school_name

  def start; end

  def body_appointed; end

  def update_body_appointed
    if @form.valid? :body_appointed
      store_form
      redirect_to action: :body_type
    else
      render :body_appointed
    end
  end

  def body_type; end

  def update_body_type
    if @form.valid? :body_type
      store_form
      redirect_to action: :body_selection
    else
      render :body_type
    end
  end

  def body_selection; end

  def update_body
    if @form.valid? :body
      store_form
      # END
    else
      render :body_selection
    end
  end

private

  def load_form
    # session.delete(:appropriate_body_selection_form)
    @form = AppropriateBodySelectionForm.new(session[:appropriate_body_selection_form])
    @form.assign_attributes(appropriate_body_selection_form_params)
  end

  def appropriate_body_selection_form_params
    return {} unless params.key?(:appropriate_body_selection_form)

    params.require(:appropriate_body_selection_form)
          .permit(:body_appointed,
                  :body_type,
                  :body_id)
  end

  def store_form
    session[:appropriate_body_selection_form] = @form.serializable_hash
  end

  def school_name
    "SCHOOL NAME"
  end
end
