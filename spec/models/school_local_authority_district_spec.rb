# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolLocalAuthorityDistrict, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:local_authority_district) }
  end
end
