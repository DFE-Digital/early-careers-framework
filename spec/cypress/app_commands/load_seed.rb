# frozen_string_literal: true

Dir[Rails.root.join("db/seeds.rb")].each { |seed| load seed }
