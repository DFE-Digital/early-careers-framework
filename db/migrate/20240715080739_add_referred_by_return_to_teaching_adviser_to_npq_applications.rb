# frozen_string_literal: true

class AddReferredByReturnToTeachingAdviserToNPQApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :npq_applications, :referred_by_return_to_teaching_adviser, :string
  end
end
