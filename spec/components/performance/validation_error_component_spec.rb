# frozen_string_literal: true

RSpec.describe Admin::Performance::ValidationErrorComponent, type: :component do
  subject { described_class.new(error: validation_error) }

  let(:user) { create(:user, full_name: "Performance User") }
  let(:validation_error) do
    build(
      :validation_error,
      id: "0d8f4556-1c3d-4e3e-8e3e-3e3e3e3e3e3e",
      created_at: "2023-06-16 03:27:00",
      user:,
    )
  end

  describe "validation error with a user" do
    it "produces header_label with user info" do
      expect(subject.header_label).to eq(
        "Validation error #0d8f4556 – 16 June 2023 at 03:27 by user Performance User",
      )
    end
  end

  describe "validation error without a user" do
    let(:user) { nil }

    it "produces header_label without user info" do
      expect(subject.header_label).to eq(
        "Validation error #0d8f4556 – 16 June 2023 at 03:27",
      )
    end
  end
end
