Feature:  Induction Tutor Materials
  All users should be able to view Induction Tutor materials for each cip provider.

  Scenario: Users should be able to view Induction Tutor materials
    Given I am on "ambition year one induction tutor materials" page
    Then the page should be accessible
    And percy should be sent snapshot called "ambition year one induction materials"

    Given I am on "ambition year two induction tutor materials" page
    Then the page should be accessible
    And percy should be sent snapshot called "ambition year two induction materials"

    Given I am on "edt year one induction tutor materials" page
    Then the page should be accessible
    And percy should be sent snapshot called "edt year one induction materials"

    Given I am on "edt year two induction tutor materials" page
    Then the page should be accessible
    And percy should be sent snapshot called "edt year two induction materials"

    Given I am on "teach first year one and two induction tutor materials" page
    Then the page should be accessible
    And percy should be sent snapshot called "teach first year one and two induction materials"

    Given I am on "ucl year one induction tutor materials" page
    Then the page should be accessible
    And percy should be sent snapshot called "ucl year one induction materials"

    Given I am on "ucl year two induction tutor materials" page
    Then the page should be accessible
    And percy should be sent snapshot called "ucl year two induction materials"