# frozen_string_literal: true

class SplitLessonPartForm
  include ActiveModel::Model

  attr_accessor :title, :content, :new_title, :new_content

  validates :title, presence: { message: "Enter a title" }, length: { maximum: 255 }
  validates :content, presence: { message: "Enter content" }, length: { maximum: 100_000 }
  validates :new_title, presence: { message: "Enter a title" }, length: { maximum: 255 }
  validates :new_content, presence: { message: "Enter content" }, length: { maximum: 100_000 }
end
