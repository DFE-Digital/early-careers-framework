class FindSchoolForm
  include ActiveModel::Model

  attr_accessor :search_type, :name_url_postcode, :local_authority, :network, :geography

  validates :search_type, presence: { message: "Please select an option" }

  validates :name_url_postcode, presence: { message: "Please enter a value" }, if: :uses_name_url_postcode?
  validates :local_authority, presence: { message: "Please enter a value" }, if: :uses_local_authority?
  validates :network, presence: { message: "Please enter a value" }, if: :uses_network?
  validates :geography, presence: { message: "Please enter a value" }, if: :uses_geography?

  def uses_name_url_postcode?
    search_type == "name_url_postcode"
  end

  def uses_local_authority?
    search_type == "local_authority"
  end

  def uses_network?
    search_type == "network"
  end

  def uses_geography?
    search_type == "geography"
  end

end
