# frozen_string_literal: true

class Finance::Milestone < ApplicationRecord
  belongs_to :schedule
end
