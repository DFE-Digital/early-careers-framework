# frozen_string_literal: true

class Schools::AddParticipants::RolesController < Schools::BaseController
  before_action :set_school
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show; end

private

  def set_school
    @school = active_school
  end
end
