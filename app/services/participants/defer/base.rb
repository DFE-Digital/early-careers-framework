# frozen_string_literal: true

require "abstract_interface"

module Participants
  module Defer
    class Base < Participants::Base
    private

      def initialize(params:)
        super(params: params)
        self.reason = params[:reason]
      end
    end
  end
end
