# frozen_string_literal: true

module Participants
  module Resume
    class ECF < Base
      include Participants::ECF
      include ValidateAndChangeState
    end
  end
end
