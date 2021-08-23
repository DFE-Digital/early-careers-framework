# frozen_string_literal: true

class Participants::BaseController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  before_action :ensure_participant
  before_action :set_paper_trail_whodunnit

private

  def ensure_participant
    raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.participant_profiles.active_record.ecf.any?
  end
end
