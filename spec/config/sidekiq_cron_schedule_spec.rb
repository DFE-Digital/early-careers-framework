# frozen_string_literal: true

RSpec.describe "sidekiq_cron_schedule.yml" do
  it "references valid job classes in every entry" do
    YAML.load_file(Rails.root.join("config/sidekiq_cron_schedule.yml")).each do |key, task|
      klass_name = task["class"]
      next unless klass_name

      expect { klass_name.constantize }.not_to raise_error,
                                               "Cron task #{key.inspect} references missing class #{klass_name}"
    end
  end
end
