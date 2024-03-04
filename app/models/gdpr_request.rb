# frozen_string_literal: true

class GDPRRequest < ApplicationRecord
  has_paper_trail

  belongs_to :cpd_lead_provider
  belongs_to :teacher_profile

  enum type: {
    restrict_processing: "restrict_processing",
  }
end
