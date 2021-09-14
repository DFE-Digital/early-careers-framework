# frozen_string_literal: true

module Participants
  module Resume
    class ECF < ::Participants::Base
      include Participants::ECF
      include ValidateAndChangeState
    end
  end
end
