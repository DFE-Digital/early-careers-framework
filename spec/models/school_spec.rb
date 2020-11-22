require "rails_helper"

RSpec.describe School, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:name).with_message("Enter the name of the school") }
    it { is_expected.to validate_presence_of(:opened_at).with_message("Enter the date the school was first opened") }
  end
end
