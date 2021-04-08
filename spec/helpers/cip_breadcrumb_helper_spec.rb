# frozen_string_literal: true

require "rails_helper"

describe CipBreadcrumbHelper, type: :helper do
  before :each do
    @user = FactoryBot.create(:user, :admin)
    @course_year = FactoryBot.create(:course_year)
    @programme = FactoryBot.create(:core_induction_programme, course_year_one: @course_year)
    @programme_crumb = [@programme.name, "/core-induction-programmes/#{@programme.id}"]
  end

  describe "#programme_breadcrumbs" do
    let(:programme_breadcrumbs) { helper.programme_breadcrumbs(@user, @programme) }
    it "returns an array for the course year breadcrumb" do
      expect(programme_breadcrumbs).to eq([["Home", "/dashboard"], @programme_crumb])
    end

    it "returns a url for the end crumb when the action_name is edit" do
      allow(helper).to receive(:action_name) { "edit" }
      expect(programme_breadcrumbs).to eql([["Home", "/dashboard"], @programme_crumb])
    end

    it "returns just the title for the end crumb when the action_name is show" do
      allow(helper).to receive(:action_name) { "show" }
      expect(programme_breadcrumbs).to eql([["Home", "/dashboard"], @programme.name])
    end
  end

  describe "#module_breadcrumbs" do
    let(:course_module) { create(:course_module, course_year: @course_year) }
    let(:course_module_crumb) { [course_module.title, "/years/#{@course_year.id}/modules/#{course_module.id}"] }
    let(:course_module_breadcrumb) { helper.course_module_breadcrumbs(@user, course_module) }

    it "returns an array for the course module breadcrumb" do
      expect(course_module_breadcrumb).to eq([["Home", "/dashboard"], @programme_crumb, course_module_crumb])
    end

    it "returns a url for the end crumb when the action_name is edit" do
      allow(helper).to receive(:action_name) { "edit" }
      expect(course_module_breadcrumb).to eq([["Home", "/dashboard"], @programme_crumb, course_module_crumb])
    end

    it "returns just the title for the end crumb when the action_name is show" do
      allow(helper).to receive(:action_name) { "show" }
      expect(course_module_breadcrumb).to eql([["Home", "/dashboard"], @programme_crumb, course_module.title])
    end
  end

  describe "#lesson_breadcrumbs" do
    let(:course_module) { create(:course_module, course_year: @course_year) }
    let(:course_lesson) { create(:course_lesson, course_module: course_module) }
    let(:course_module_crumb) { [course_module.title, "/years/#{@course_year.id}/modules/#{course_module.id}"] }
    let(:course_lesson_crumb) { [course_lesson.title, "/years/#{@course_year.id}/modules/#{course_module.id}/lessons/#{course_lesson.id}"] }
    let(:course_lesson_breadcrumb) { helper.course_lesson_breadcrumbs(@user, course_lesson) }

    it "returns an array for the course lesson breadcrumb" do
      expect(course_lesson_breadcrumb).to eq([["Home", "/dashboard"], @programme_crumb, course_module_crumb, course_lesson_crumb])
    end

    it "returns the url for the end crumb when the action_name is edit" do
      allow(helper).to receive(:action_name) { "edit" }
      expect(course_lesson_breadcrumb).to eq([["Home", "/dashboard"], @programme_crumb, course_module_crumb, course_lesson_crumb])
    end

    it "returns just the title for the end crumb when the action_name is show" do
      allow(helper).to receive(:action_name) { "show" }
      expect(course_lesson_breadcrumb).to eq([["Home", "/dashboard"], @programme_crumb, course_module_crumb, course_lesson.title])
    end
  end
end
