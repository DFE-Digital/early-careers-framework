# frozen_string_literal: true

class Participants::BaseController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  before_action :ensure_participant
  before_action :set_paper_trail_whodunnit

private

  def ensure_participant
    redirect_to participants_no_access_path unless current_user.participant_profiles.active_record.ecf.any?
  end
end
