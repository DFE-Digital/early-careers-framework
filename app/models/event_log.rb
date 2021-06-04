# frozen_string_literal: true

class EventLog < ApplicationRecord
  belongs_to :owner, polymorphic: true
end
