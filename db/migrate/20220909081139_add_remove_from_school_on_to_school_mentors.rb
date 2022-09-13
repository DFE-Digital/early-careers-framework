# frozen_string_literal: true

class AddRemoveFromSchoolOnToSchoolMentors < ActiveRecord::Migration[6.1]
  def change
    add_column :school_mentors, :remove_from_school_on, :date, null: true
  end
end
