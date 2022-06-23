require 'rails_helper'

# TODO: appropriate body spec
RSpec.describe AppropriateBody, type: :model do
  it "is valid with name and body type" do
    expect(create(:ab_local_authority)).to be_valid
    expect(create(:ab_teaching_school_hub)).to be_valid
  end

  it "has name unique per body type" do
    create(:ab_local_authority, name: "not unique one")
    not_valid_ab = build(:ab_local_authority, name: "not unique one")
    expect(not_valid_ab).to_not be_valid
  end
end
