module Finance
  module StatementHelper
    def statement_display_text(statement)
      statement.current? ? "#{statement.name} (Current)" : statement.name
    end
  end
end
