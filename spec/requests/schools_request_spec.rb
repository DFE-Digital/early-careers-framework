require "rails_helper"

RSpec.describe "Schools", type: :request do

  describe "GET /schools/new" do
    before do
      get '/schools/new'
    end

    it 'renders the correct view' do
      expect(response).to render_template :new
    end
  end

  describe "Creating a school - POST /schools" do
    let(:expected_name) { "Test School" }
    let(:expected_date) { Date.new(2020, 1, 2) }
    let(:expected_school_type) { "Primary" }


    it "successfully creates a school" do
      # When
      post "/schools", params: { school: {
        name: expected_name,
        "opened_at(1i)": expected_date.year.to_s,
        "opened_at(2i)": expected_date.month.to_s,
        "opened_at(3i)": expected_date.day.to_s,
      } }

      # Then
      expect(response).to redirect_to assigns(:school)
      expect(School.find_by(name: expected_name)).not_to be_nil
      expect(School.find_by(name: expected_name).opened_at).to eq(expected_date)
    end

    it "successfully creates a school with a type" do
      expect {
        # When
        post "/schools", params: { school:
                                     {
                                       name: expected_name,
                                       "opened_at(1i)": expected_date.year.to_s,
                                       "opened_at(2i)": expected_date.month.to_s,
                                       "opened_at(3i)": expected_date.day.to_s,
                                       school_type: expected_school_type,
                                     } }

        # Then
        expect(response).to redirect_to assigns(:school)
        expect(School.find_by(name: expected_name)).not_to be_nil
        expect(School.find_by(name: expected_name).opened_at).to eq(expected_date)
        expect(School.find_by(name: expected_name).school_type).to eq(expected_school_type)
      }.to change { School.count }.by(1)
    end

    it "will not create a school without a name" do
      expect {
        # When
        post "/schools", params: { school: {
          name: "",
          "opened_at(1i)": "2020",
          "opened_at(2i)": "1",
          "opened_at(3i)": "1",
        } }

        # Then
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:school).errors.empty?).to be false
      }.not_to(change { School.count })
    end

    it "will not create a school without an opened_at date" do
      expect {
        # When
        post "/schools", params: { school: {
          name: "test school",
          "opened_at(1i)": "",
          "opened_at(2i)": "",
          "opened_at(3i)": "",
        } }

        # Then
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:school).errors.empty?).to be false
      }.not_to(change { School.count })
    end

    [
      [2020, 2, 32],
      [2020, 1, 32],
    ].each do |invalid_date|
      it "will not create a school with an invalid opened_at date: #{invalid_date}" do
        expect {
          # When
          post "/schools", params: { school: {
            name: "test school",
            "opened_at(1i)": invalid_date[0],
            "opened_at(2i)": invalid_date[1],
            "opened_at(3i)": invalid_date[2],
          } }

          # Then
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:new)
          expect(assigns(:school).errors.empty?).to be false
        }.not_to(change { School.count })
      end
    end
  end

end
