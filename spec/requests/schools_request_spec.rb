require 'rails_helper'

RSpec.describe "Schools", type: :request do

  describe "Creating a school" do
    it "successfully creates a school" do
      # Given
      expected_name = "Test School"
      expected_date = Date.new(2020, 1, 2)

      post "/schools", params: { school:
                                   { name: expected_name,
                                     "opened(1i)": expected_date.year.to_s,
                                     "opened(2i)": expected_date.month.to_s,
                                     "opened(3i)": expected_date.day.to_s,
                                   } }

      expect(response).to redirect_to assigns(:school)
      expect(School.find_by(name: expected_name)).not_to be_nil
      expect(School.find_by(name: expected_name).opened).to eq(expected_date)
    end

    it "successfully creates a school with a type" do
      # Given
      expected_name = "Test School 2"
      expected_date = Date.new(2020, 1, 3)
      expected_school_type = "Primary"

      post "/schools", params: { school:
                                   {
                                     name: expected_name,
                                     "opened(1i)": expected_date.year.to_s,
                                     "opened(2i)": expected_date.month.to_s,
                                     "opened(3i)": expected_date.day.to_s,
                                     school_type: expected_school_type,
                                   } }

      expect(response).to redirect_to assigns(:school)
      expect(School.find_by(name: expected_name)).not_to be_nil
      expect(School.find_by(name: expected_name).opened).to eq(expected_date)
      expect(School.find_by(name: expected_name).school_type).to eq(expected_school_type)
    end

    it "will not create a school without a name" do
      post "/schools", params: { school:
                                   { name: "",
                                     "opened(1i)": "2020",
                                     "opened(2i)": "1",
                                     "opened(3i)": "1",
                                   } }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
      expect(assigns(:school).errors.empty?).to be false
    end

    it "will not create a school without an opened date" do
      post "/schools", params: { school:
                                   { name: "test school",
                                     "opened(1i)": "",
                                     "opened(2i)": "",
                                     "opened(3i)": "",
                                   } }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
      expect(assigns(:school).errors.empty?).to be false
    end

    [
      [2020, 2, 30],
      [2020, 1, 32],
    ].each do |invalid_date|
      it "will not create a school with an invalid opened date: #{invalid_date}" do
        post "/schools", params: { school:
                                     { name: "test school",
                                       "opened(1i)": invalid_date[0],
                                       "opened(2i)": invalid_date[1],
                                       "opened(3i)": invalid_date[2],
                                     } }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:school).errors.empty?).to be false
      end
    end
  end

end
