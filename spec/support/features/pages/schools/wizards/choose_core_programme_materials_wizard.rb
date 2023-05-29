# frozen_string_literal: true

module Pages
  module Schools
    module Wizards
      class ChooseCoreProgrammeMaterialsWizard < ::Pages::BaseWizard
        set_start_page ::Pages::Schools::Pages::ChooseCoreProgrammeMaterialsStartPage

        def report_core_programme_materials(core_programme_materials:)
          start_page.loaded
                    .continue
                    .choose_core_programme_materials(name: core_programme_materials.name)
        end
      end
    end
  end
end
