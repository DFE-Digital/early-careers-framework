# frozen_string_literal: true

class CourseModule < ApplicationRecord
  belongs_to :course_year
  has_one :next_module, class_name: "CourseModule", foreign_key: :next_module_id
  belongs_to :previous_module, class_name: "CourseModule", inverse_of: :next_module, optional: true
  has_many :course_lessons, dependent: :delete_all

  validates :title, presence: { message: "Enter a title" }
  validates :content, presence: { message: "Enter content" }

  def content_to_html
    Govspeak::Document.new(content, options: { allow_extra_quotes: true }).to_html
  end
end
