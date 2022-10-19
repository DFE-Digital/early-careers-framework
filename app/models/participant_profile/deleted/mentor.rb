# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  module Deleted
    class Mentor < ParticipantProfile
    end
  end
end
