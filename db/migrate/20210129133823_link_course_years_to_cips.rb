# frozen_string_literal: true

class LinkCourseYearsToCips < ActiveRecord::Migration[6.1]
  def change
    add_reference :course_years, :core_induction_programme, null: true, foreign_key: true, type: :uuid
    remove_reference :course_years, :lead_provider
  end
end
