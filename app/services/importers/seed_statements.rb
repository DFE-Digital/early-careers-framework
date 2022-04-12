# frozen_string_literal: true

class Importers::SeedStatements
  def call
    LeadProvider.includes(:cpd_lead_provider).each do |lead_provider|
      cpd_lead_provider = lead_provider.cpd_lead_provider

      ecf_statements.each do |statement_data|
        statement = Finance::Statement::ECF.find_or_create_by!(
          name: statement_data.name,
          cpd_lead_provider: cpd_lead_provider,
          cohort: Cohort.find_by(start_year: 2021),
          contract_version: statement_data.contract_version,
        )
        statement.update!(
          deadline_date: statement_data.deadline_date,
          payment_date: statement_data.payment_date,
          cohort: Cohort.find_by(start_year: 2021),
          output_fee: statement_data.output_fee,
          type: class_for(statement_data, namespace: Finance::Statement::ECF),
        )
      end
    end

    NPQLeadProvider.includes(:cpd_lead_provider).each do |npq_lead_provider|
      cpd_lead_provider = npq_lead_provider.cpd_lead_provider

      npq_statements.each do |statement_data|
        statement = Finance::Statement::NPQ.find_or_create_by!(
          name: statement_data.name,
          cpd_lead_provider: cpd_lead_provider,
          cohort: cohort,
          contract_version: statement_data.contract_version,
        )

        statement.update!(
          deadline_date: statement_data.deadline_date,
          payment_date: statement_data.payment_date,
          cohort: cohort,
          output_fee: statement_data.output_fee,
          type: class_for(statement_data, namespace: Finance::Statement::NPQ),
        )
      end
    end
  end

private

  def class_for(statment_data, namespace:)
    return namespace::Paid    if statment_data[:payment_date] < Date.current
    return namespace::Payable if Date.current.between?(statment_data[:deadline_date], statment_data[:payment_date])

    namespace
  end

  def cohort
    @cohort ||= Cohort.find_by!(start_year: 2021)
  end

  def ecf_statements
    [
      { name: "November 2021",  deadline_date: Date.new(2021, 11, 30), payment_date: Date.new(2021, 11, 30), contract_version: "0.0.1", output_fee: true  },
      { name: "January 2022",   deadline_date: Date.new(2021, 12, 31), payment_date: Date.new(2022, 1, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "February 2022",  deadline_date: Date.new(2022, 1, 31),  payment_date: Date.new(2022, 2, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "March 2022",     deadline_date: Date.new(2022, 2, 28),  payment_date: Date.new(2022, 3, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "April 2022",     deadline_date: Date.new(2022, 3, 31),  payment_date: Date.new(2022, 4, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "May 2022",       deadline_date: Date.new(2022, 4, 30),  payment_date: Date.new(2022, 5, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "June 2022",      deadline_date: Date.new(2022, 5, 31),  payment_date: Date.new(2022, 6, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "July 2022",      deadline_date: Date.new(2022, 6, 30),  payment_date: Date.new(2022, 7, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "August 2022",    deadline_date: Date.new(2022, 7, 31),  payment_date: Date.new(2022, 8, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "September 2022", deadline_date: Date.new(2022, 8, 31),  payment_date: Date.new(2022, 9, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "October 2022",   deadline_date: Date.new(2022, 9, 30),  payment_date: Date.new(2022, 10, 25), contract_version: "0.0.1", output_fee: true  },
      { name: "November 2022",  deadline_date: Date.new(2022, 10, 31), payment_date: Date.new(2022, 11, 25), contract_version: "0.0.1", output_fee: false },
      { name: "December 2022",  deadline_date: Date.new(2022, 11, 30), payment_date: Date.new(2022, 12, 25), contract_version: "0.0.1", output_fee: false },
      { name: "January 2023",   deadline_date: Date.new(2023, 12, 31), payment_date: Date.new(2023, 1, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "February 2023",  deadline_date: Date.new(2023, 1, 31),  payment_date: Date.new(2023, 2, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "March 2023",     deadline_date: Date.new(2023, 2, 28),  payment_date: Date.new(2023, 3, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "April 2023",     deadline_date: Date.new(2023, 3, 31),  payment_date: Date.new(2023, 4, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "May 2023",       deadline_date: Date.new(2023, 4, 30),  payment_date: Date.new(2023, 5, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "June 2023",      deadline_date: Date.new(2023, 5, 31),  payment_date: Date.new(2023, 6, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "July 2023",      deadline_date: Date.new(2023, 6, 30),  payment_date: Date.new(2023, 7, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "August 2023",    deadline_date: Date.new(2023, 7, 31),  payment_date: Date.new(2023, 8, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "September 2023", deadline_date: Date.new(2023, 8, 31),  payment_date: Date.new(2023, 9, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "October 2023",   deadline_date: Date.new(2023, 9, 30),  payment_date: Date.new(2023, 10, 25), contract_version: "0.0.1", output_fee: false },
      { name: "November 2023",  deadline_date: Date.new(2023, 10, 31), payment_date: Date.new(2023, 11, 25), contract_version: "0.0.1", output_fee: true  },
      { name: "December 2023",  deadline_date: Date.new(2023, 11, 30), payment_date: Date.new(2023, 12, 25), contract_version: "0.0.1", output_fee: false },
      { name: "January 2024",   deadline_date: Date.new(2024, 12, 31), payment_date: Date.new(2024, 1, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "February 2024",  deadline_date: Date.new(2024, 1, 31),  payment_date: Date.new(2024, 2, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "March 2024",     deadline_date: Date.new(2024, 2, 29),  payment_date: Date.new(2024, 3, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "April 2024",     deadline_date: Date.new(2024, 3, 31),  payment_date: Date.new(2024, 4, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "May 2024",       deadline_date: Date.new(2024, 4, 30),  payment_date: Date.new(2024, 5, 25),  contract_version: "0.0.1", output_fee: true  },
    ].map { |hash| OpenStruct.new(hash) }
  end

  def npq_statements
    [
      { name: "January 2022",   deadline_date: Date.new(2021, 12, 25),  payment_date: Date.new(2022, 1, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "February 2022",  deadline_date: Date.new(2022, 1, 25),   payment_date: Date.new(2022, 2, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "March 2022",     deadline_date: Date.new(2022, 2, 25),   payment_date: Date.new(2022, 3, 25),  contract_version: "0.0.2", output_fee: true  },
      { name: "April 2022",     deadline_date: Date.new(2022, 3, 25),   payment_date: Date.new(2022, 4, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "May 2022",       deadline_date: Date.new(2022, 4, 25),   payment_date: Date.new(2022, 5, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "June 2022",      deadline_date: Date.new(2022, 5, 25),   payment_date: Date.new(2022, 6, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "July 2022",      deadline_date: Date.new(2022, 6, 25),   payment_date: Date.new(2022, 7, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "August 2022",    deadline_date: Date.new(2022, 7, 25),   payment_date: Date.new(2022, 8, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "September 2022", deadline_date: Date.new(2022, 9, 25),   payment_date: Date.new(2022, 9, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "October 2022",   deadline_date: Date.new(2022, 10, 25),  payment_date: Date.new(2022, 10, 25), contract_version: "0.0.1", output_fee: true  },
      { name: "November 2022",  deadline_date: Date.new(2022, 11, 25),  payment_date: Date.new(2022, 11, 25), contract_version: "0.0.1", output_fee: false },
      { name: "December 2022",  deadline_date: Date.new(2022, 12, 25),  payment_date: Date.new(2022, 12, 25), contract_version: "0.0.1", output_fee: true  },
      { name: "January 2023",   deadline_date: Date.new(2021, 12, 25),  payment_date: Date.new(2023, 1, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "February 2023",  deadline_date: Date.new(2023, 1, 25),   payment_date: Date.new(2023, 2, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "March 2023",     deadline_date: Date.new(2023, 2, 25),   payment_date: Date.new(2023, 3, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "April 2023",     deadline_date: Date.new(2023, 3, 25),   payment_date: Date.new(2023, 4, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "May 2023",       deadline_date: Date.new(2023, 4, 25),   payment_date: Date.new(2023, 5, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "June 2023",      deadline_date: Date.new(2023, 5, 25),   payment_date: Date.new(2023, 6, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "July 2023",      deadline_date: Date.new(2023, 6, 25),   payment_date: Date.new(2023, 7, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "August 2023",    deadline_date: Date.new(2023, 7, 25),   payment_date: Date.new(2023, 8, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "September 2023", deadline_date: Date.new(2023, 9, 25),   payment_date: Date.new(2023, 9, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "October 2023",   deadline_date: Date.new(2023, 10, 25),  payment_date: Date.new(2023, 10, 25), contract_version: "0.0.1", output_fee: true  },
      { name: "November 2023",  deadline_date: Date.new(2023, 11, 25),  payment_date: Date.new(2023, 11, 25), contract_version: "0.0.1", output_fee: false },
      { name: "December 2023",  deadline_date: Date.new(2023, 12, 25),  payment_date: Date.new(2023, 12, 25), contract_version: "0.0.1", output_fee: true  },
      { name: "January 2024",   deadline_date: Date.new(2021, 12, 25),  payment_date: Date.new(2024, 1, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "February 2024",  deadline_date: Date.new(2024, 1, 25),   payment_date: Date.new(2024, 2, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "March 2024",     deadline_date: Date.new(2024, 2, 25),   payment_date: Date.new(2024, 3, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "April 2024",     deadline_date: Date.new(2024, 3, 25),   payment_date: Date.new(2024, 4, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "May 2024",       deadline_date: Date.new(2024, 4, 25),   payment_date: Date.new(2024, 5, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "June 2024",      deadline_date: Date.new(2024, 5, 25),   payment_date: Date.new(2024, 6, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "July 2024",      deadline_date: Date.new(2024, 6, 25),   payment_date: Date.new(2024, 7, 25),  contract_version: "0.0.1", output_fee: true  },
      { name: "August 2024",    deadline_date: Date.new(2024, 7, 25),   payment_date: Date.new(2024, 8, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "September 2024", deadline_date: Date.new(2024, 9, 25),   payment_date: Date.new(2024, 9, 25),  contract_version: "0.0.1", output_fee: false },
      { name: "October 2024",   deadline_date: Date.new(2024, 10, 25),  payment_date: Date.new(2024, 10, 25), contract_version: "0.0.1", output_fee: true  },
      { name: "November 2024",  deadline_date: Date.new(2024, 11, 25),  payment_date: Date.new(2024, 11, 25), contract_version: "0.0.1", output_fee: false },
      { name: "December 2024",  deadline_date: Date.new(2024, 12, 25),  payment_date: Date.new(2024, 12, 25), contract_version: "0.0.1", output_fee: true  },
    ].map { |hash| OpenStruct.new(hash) }
  end
end
