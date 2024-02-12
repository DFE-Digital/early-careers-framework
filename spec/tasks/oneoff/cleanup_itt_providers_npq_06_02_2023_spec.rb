# frozen_string_literal: true

RSpec.describe "npq_applications:restore_itt_providers" do
  before :all do
    Rake.application.rake_require "tasks/oneoff/cleanup_itt_providers_npq_06_02_2023"
    Rake::Task.define_task(:environment)
    @csv_file_path = Rails.root.join("tmp/test.csv")
  end

  describe "restore_itt_providers" do
    it "should update the ITT provider for the application" do
      application = create :npq_application, itt_provider: "Old Provider"
      CSV.open(@csv_file_path, "w") { |csv| csv << [application.id, "New Provider"] }

      Rake::Task["npq_applications:restore_itt_providers"].reenable
      Rake.application.invoke_task "npq_applications:restore_itt_providers[#{@csv_file_path}]"

      expect(application.reload.itt_provider).to eq "New Provider"
    end

    after :all do
      File.delete(@csv_file_path) if File.exist?(@csv_file_path)
    end
  end
end
