# frozen_string_literal: true

class AppropriateBody < ApplicationRecord
  enum body_type: {
    local_authority: "local_authority",
    teaching_school_hub: "teaching_school_hub",
  }

  validates :name, presence: true, uniqueness: { scope: :body_type }
end
