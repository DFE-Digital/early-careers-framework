# frozen_string_literal: true

class RemoveDummySchools < ActiveRecord::Migration[6.1]
  def change
    School.where(local_authority: nil).delete_all
    School.where(local_authority_district: nil).delete_all
  end
end
