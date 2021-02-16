# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindSchoolForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:search_type).with_message("Please select an option") }
    [
      %i[name_url_postcode uses_name_url_postcode?],
      %i[local_authority uses_local_authority?],
      %i[network uses_network?],
      %i[geography uses_geography?],
    ].each do |field, method|
      context "when searching by #{field}" do
        before { allow(subject).to receive(method).and_return(true) }

        %i[name_url_postcode local_authority network geography].each do |validated_field|
          if validated_field == field
            it { is_expected.to validate_presence_of(field).with_message("Please enter a value") }
          else
            it { is_expected.not_to validate_presence_of(validated_field) }
          end
        end
      end
    end
  end
end
