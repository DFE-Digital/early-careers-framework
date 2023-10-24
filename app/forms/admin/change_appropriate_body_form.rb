class Admin::ChangeAppropriateBodyForm
  include ActiveModel::Model

  attr_accessor :appropriate_body, :teaching_school_hub_id

  validates :appropriate_body, presence: true
  validates :teaching_school_hub_id, presence: true, if: :teaching_school_hub?

private

  def teaching_school_hub?
    appropriate_body == "teaching_school_hub"
  end
end
