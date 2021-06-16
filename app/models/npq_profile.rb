# frozen_string_literal: true

class NpqProfile < ApplicationRecord
  belongs_to :user
  belongs_to :npq_lead_provider
  belongs_to :npq_course
end
