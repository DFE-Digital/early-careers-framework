# frozen_string_literal: false

module Participants
  class NoAccessController < BaseController
    skip_before_action :ensure_participant

    def show; end
  end
end
