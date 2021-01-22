# frozen_string_literal: true

class CourseYear < ApplicationRecord
  belongs_to :lead_provider
  has_many :course_modules

  validates :title, presence: { message: "Enter a title" }
  validates :content, presence: { message: "Enter content" }

  def content_to_html
    Govspeak::Document.new(content, options: { allow_extra_quotes: true }).to_html
  end
end
