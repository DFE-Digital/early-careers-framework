# frozen_string_literal: true

Importers::NPQContracts.new(path_to_csv: Rails.root.join("db/data/npq_contracts/fake-2021.csv")).call
Importers::NPQContracts.new(path_to_csv: Rails.root.join("db/data/npq_contracts/fake-2022.csv")).call
Importers::NPQContracts.new(path_to_csv: Rails.root.join("db/data/npq_contracts/fake-2023.csv")).call
Importers::CreateCallOffContracts.new.call
