# frozen_string_literal: true

class ChooseRolesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_choose_role_form, only: %i[show create]

  def show
    if @choose_role_form.only_one_role || @choose_role_form.has_no_role
      redirect_to @choose_role_form.redirect_path(helpers:)
    end
  end

  def create
    @choose_role_form.assign_attributes(choose_role_form_params)

    if @choose_role_form.valid?
      redirect_to @choose_role_form.redirect_path(helpers:)
    else
      render :show
    end
  end

  def contact_support; end

private

  def set_choose_role_form
    @choose_role_form = ChooseRoleForm.new(user: current_user)
  end

  def choose_role_form_params
    params.fetch(:choose_role_form, {}).permit(
      :role,
    )
  end
end
