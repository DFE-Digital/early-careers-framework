# frozen_string_literal: true

require "abstract_interface"

module Participants
  module ChangeSchedule
    class Base < Participants::Base
    private

      def initialize(params:)
        super(params: params)
        self.schedule_identifier = params[:schedule_identifier]
        self.cohort = params[:cohort]
      end
    end
  end
end
