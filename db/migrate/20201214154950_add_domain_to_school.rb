class AddDomainToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :domain, :string, null: false, default: "education.go.uk"
  end
end
