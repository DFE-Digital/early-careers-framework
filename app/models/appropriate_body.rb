# frozen_string_literal: true

class AppropriateBody < ApplicationRecord
  enum body_type: {
    local_authority: "local_authority",
    teaching_school_hub: "teaching_school_hub",
  }

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :body_type
end
