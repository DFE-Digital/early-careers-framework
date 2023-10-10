# frozen_string_literal: true

class ParticipantIdChange < ApplicationRecord
  belongs_to :user

  belongs_to :from_participant, class_name: "User"
  belongs_to :to_participant, class_name: "User"
end
