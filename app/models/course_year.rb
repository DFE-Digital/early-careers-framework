# frozen_string_literal: true

class CourseYear < ApplicationRecord
  include OrderHelper

  belongs_to :core_induction_programme, optional: true
  has_many :course_modules, dependent: :delete_all

  validates :title, presence: { message: "Enter a title" }, length: { maximum: 255 }
  validates :content, presence: { message: "Enter content" }, length: { maximum: 100_000 }

  def content_to_html
    Govspeak::Document.new(content, options: { allow_extra_quotes: true }).to_html
  end

  def course_modules_in_order
    preloaded_modules = course_modules.includes(:previous_module, :next_module)
    elements_in_order(elements: preloaded_modules, previous_method_name: :previous_module)
  end
end
