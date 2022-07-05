# frozen_string_literal: true

class AppropriateBody < ApplicationRecord
  enum body_type: {
    local_authority: "local_authority",
    teaching_school_hub: "teaching_school_hub",
    national: "national",
  }

  validates :name, presence: true, uniqueness: { scope: :body_type }

  default_scope { order(:name) }

  scope :local_authorities, -> { where(body_type: :local_authority) }
  scope :teaching_school_hubs, -> { where(body_type: :teaching_school_hub) }
  scope :nationals, -> { where(body_type: :national) }
end
