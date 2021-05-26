# frozen_string_literal: true

class ReplaceOrUpdateTutorForm
  include ActiveModel::Model

  attr_accessor :choice

  validates :choice, presence: true

  def replace_tutor?
    choice == "replace"
  end

  def update_tutor?
    choice == "update"
  end

  def choices
    [
      OpenStruct.new(id: "replace", name: "Replace induction tutor with someone new"),
      OpenStruct.new(id: "update", name: "Update induction tutor’s details"),
    ]
  end
end
