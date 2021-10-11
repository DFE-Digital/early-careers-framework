# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class ECF < Base
      include Participants::ECF
      include ValidateAndChangeSchedule
    end
  end
end
