# frozen_string_literal: true

class MentorCallOffContract < ApplicationRecord
  belongs_to :lead_provider
  belongs_to :cohort
end
