PrivacyPolicy.find_or_initialize_by(major_version: 1, minor_version: 0)
  .tap { |pp| pp.html = Rails.root.join("data/privacy_policy.html").read }
  .save!
