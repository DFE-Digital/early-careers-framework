# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  module Deleted
    class ECF < ParticipantProfile
    end
  end
end

require "participant_profile/deleted/ect"
require "participant_profile/deleted/mentor"
