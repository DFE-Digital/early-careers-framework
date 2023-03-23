# frozen_string_literal: true

Importers::CreateStatement.new(path_to_csv: Rails.root.join("db/data/statements/statements.csv")).call
