# frozen_string_literal: true

class ChooseRolesController < ApplicationController
  before_action :authenticate_user!

  def show
    @choose_role_form = ChooseRoleForm.new
    @choose_role_form.user = current_user

    if @choose_role_form.only_one_role? or @choose_role_form.has_no_role?
      redirect_to @choose_role_form.redirect_path(helpers:)
    end
  end

  def create
    @choose_role_form = ChooseRoleForm.new(choose_role_form_params)
    @choose_role_form.user = current_user

    if @choose_role_form.valid?
      redirect_to @choose_role_form.redirect_path(helpers:)
    else
      render :show
    end
  end

  def contact_support; end

private

  def choose_role_form_params
    params.fetch(:choose_role_form, {}).permit(
      :role,
    )
  end
end
