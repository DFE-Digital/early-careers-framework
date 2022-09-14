# frozen_string_literal: true

ActiveRecord::Base.transaction { Importers::AppropriateBodies.call }
