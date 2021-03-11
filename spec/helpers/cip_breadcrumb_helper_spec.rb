# frozen_string_literal: true

require "rails_helper"

describe CipBreadcrumbHelper, type: :helper do
  before :each do
    @user = FactoryBot.create(:user, :admin)
    @course_year = FactoryBot.create(:course_year)
    @course_year_crumb = [@course_year.title, "/years/#{@course_year.id}"]
  end

  describe "#year_breadcrumb" do
    let(:course_year_breadcrumb) { helper.course_year_breadcrumbs(@user, @course_year) }
    it "returns an array for the course year breadcrumb" do
      expect(course_year_breadcrumb).to eq([["Home", "/dashboard"], @course_year_crumb])
    end

    it "returns a url for the end crumb when the action_name is edit" do
      allow(helper).to receive(:action_name) { "edit" }
      expect(course_year_breadcrumb).to eql([["Home", "/dashboard"], @course_year_crumb])
    end

    it "returns just the title for the end crumb when the action_name is show" do
      allow(helper).to receive(:action_name) { "show" }
      expect(course_year_breadcrumb).to eql([["Home", "/dashboard"], @course_year.title])
    end
  end

  describe "#module_breadcrumb" do
    let(:course_module) { create(:course_module, course_year: @course_year) }
    let(:course_module_crumb) { [course_module.title, "/years/#{@course_year.id}/modules/#{course_module.id}"] }
    let(:course_module_breadcrumb) { helper.course_module_breadcrumbs(@user, course_module) }

    it "returns an array for the course module breadcrumb" do
      expect(course_module_breadcrumb).to eq([["Home", "/dashboard"], @course_year_crumb, course_module_crumb])
    end

    it "returns a url for the end crumb when the action_name is edit" do
      allow(helper).to receive(:action_name) { "edit" }
      expect(course_module_breadcrumb).to eq([["Home", "/dashboard"], @course_year_crumb, course_module_crumb])
    end

    it "returns just the title for the end crumb when the action_name is show" do
      allow(helper).to receive(:action_name) { "show" }
      expect(course_module_breadcrumb).to eql([["Home", "/dashboard"], @course_year_crumb, course_module.title])
    end
  end

  describe "#lesson_breadcrumb" do
    let(:course_module) { create(:course_module, course_year: @course_year) }
    let(:course_lesson) { create(:course_lesson, course_module: course_module) }
    let(:course_module_crumb) { [course_module.title, "/years/#{@course_year.id}/modules/#{course_module.id}"] }
    let(:course_lesson_crumb) { [course_lesson.title, "/years/#{@course_year.id}/modules/#{course_module.id}/lessons/#{course_lesson.id}"] }
    let(:course_lesson_breadcrumb) { helper.course_lesson_breadcrumbs(@user, course_lesson) }

    it "returns an array for the course lesson breadcrumb" do
      expect(course_lesson_breadcrumb).to eq([["Home", "/dashboard"], @course_year_crumb, course_module_crumb, course_lesson_crumb])
    end

    it "returns the url for the end crumb when the action_name is edit" do
      allow(helper).to receive(:action_name) { "edit" }
      expect(course_lesson_breadcrumb).to eq([["Home", "/dashboard"], @course_year_crumb, course_module_crumb, course_lesson_crumb])
    end

    it "returns just the title for the end crumb when the action_name is show" do
      allow(helper).to receive(:action_name) { "show" }
      expect(course_lesson_breadcrumb).to eq([["Home", "/dashboard"], @course_year_crumb, course_module_crumb, course_lesson.title])
    end
  end
end
