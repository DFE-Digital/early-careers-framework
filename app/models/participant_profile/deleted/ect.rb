# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  module Deleted
    class ECT < ECF
    end
  end
end
