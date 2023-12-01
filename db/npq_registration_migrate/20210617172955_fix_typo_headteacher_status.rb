class FixTypoHeadteacherStatus < ActiveRecord::Migration[6.1]
  def change
    remove_column :applications, :headerteacher_over_two_years, :boolean
    add_column :applications, :headteacher_status, :text
  end
end
