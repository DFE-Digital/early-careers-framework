# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ParticipantActions
    end
  end
end
