# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class NPQ < ::Participants::Base
      include Participants::NPQ
      include ValidateAndChangeSchedule
    end
  end
end
