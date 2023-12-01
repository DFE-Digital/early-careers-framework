class AddPostcodeWithoutSpaces < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :postcode_without_spaces, :text
  end
end
