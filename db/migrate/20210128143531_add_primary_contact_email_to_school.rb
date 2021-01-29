# frozen_string_literal: true

class AddPrimaryContactEmailToSchool < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :primary_contact_email, :string
  end
end
