describe("Lead provider schools", () => {
  beforeEach(() => {
    cy.appScenario("schools");

    // Not sure why cypress isn't doing this…
    sessionStorage.clear();
  });

  it.only("should have an initial filter schools page", () => {
    cy.login("admin");

    cy.visit("/lead-provider/filter-schools");

    cy.get("#school-autocomplete").should("not.be.visible");
    cy.get("#location-autocomplete").should("not.be.visible");

    cy.get(
      'label[for="school-search-form-search-type-location-field"]'
    ).click();

    cy.get("#school-autocomplete").should("not.be.visible");
    cy.get("#location-autocomplete").should("be.visible");

    cy.get(
      'label[for="school-search-form-search-type-school-name-field"]'
    ).click();

    cy.get("#school-autocomplete").should("be.visible");
    cy.get("#location-autocomplete").should("not.be.visible");

    cy.get('#school-autocomplete [type="text"]').type("East");

    // @todo replace this with a visual test
    cy.contains("East Orn").should("be.visible");

    cy.get('.new_school_search_form [type="submit"]').click();

    cy.get("h2").should("contain", "14 results found");
    cy.get('[name="school_search_form[school_name]"]').should(
      "have.value",
      "East"
    );

    cy.go("back");

    cy.get('[for="school-search-form-search-type-all-field"]').click();
    cy.get(
      'label[for="school-search-form-partnership-in-a-partnership-field"]:visible'
    ).click();

    cy.get('.new_school_search_form [type="submit"]').click();

    cy.get("h2").should("contain", "49 results found");
    cy.get("#school-search-form-partnership-in-a-partnership-field").should(
      "be.checked"
    );
  });

  it("should support searching for schools", () => {
    cy.login("admin");

    cy.visit("/lead-provider/search-schools");

    cy.get("h2").should("contain", "49 results found");

    cy.get('[name="school_search_form[school_name]"]').type("east{enter}");

    cy.get("h2").should("contain", "14 results found");

    cy.contains("Clear filters").click();

    cy.get("h2").should("contain", "49 results found");

    cy.get(
      '[type="checkbox"][name="school_search_form[characteristics][]"][value="pupil_premium_above_40"]'
    ).click();

    cy.contains("Apply filters").click();

    cy.get("h2").should("contain", "10 results found");

    cy.get('[name="school_search_form[school_name]"]').type("east{enter}");

    cy.get("h2").should("contain", "3 results found");
  });

  it("should support adding partnerships", () => {
    cy.login("admin");

    // Unfiltered schools - first page
    cy.visit("/lead-provider/search-schools");

    cy.contains("49 results found");

    cy.get(".js-partnerships-submit").as("submit").should("be.disabled");
    cy.get(".js-partnerships-clear").should("not.be.visible");

    cy.get('[type="checkbox"][name="partnership_form[schools][]"]').as(
      "checkboxes"
    );

    cy.get("@checkboxes").eq(1).click();
    cy.get("@checkboxes").eq(3).click();
    cy.get("@checkboxes").eq(6).click();

    cy.get("@submit")
      .should("contain", "Add partnerships with 3 schools")
      .should("not.be.disabled");

    cy.get(".js-partnerships-clear").should("contain", "Remove all 3 schools");

    cy.reload();

    cy.get(".js-partnerships-submit")
      .should("contain", "Add partnerships with 3 schools")
      .should("not.be.disabled");

    cy.get(".js-partnerships-clear").should("contain", "Remove all 3 schools");

    cy.get('[type="checkbox"][name="partnership_form[schools][]"]').as(
      "checkboxes"
    );

    // @todo replace with a visual test
    cy.get("@checkboxes").eq(1).should("be.checked");
    cy.get("@checkboxes").eq(2).should("not.be.checked");
    cy.get("@checkboxes").eq(3).should("be.checked");
    cy.get("@checkboxes").eq(4).should("not.be.checked");
    cy.get("@checkboxes").eq(6).should("be.checked");

    // Unfiltered schools: second page
    cy.get('[rel="next"]:first').click();

    cy.get('[type="checkbox"][name="partnership_form[schools][]"]').as(
      "checkboxes"
    );

    cy.get("@checkboxes").eq(4).should("not.be.checked").click();
    cy.get("@checkboxes").eq(14).should("not.be.checked").click();

    cy.get(".js-partnerships-submit")
      .should("contain", "Add partnerships with 5 schools")
      .should("not.be.disabled");

    // Filtered schools
    cy.get('[name="school_search_form[school_name]"]').type("east{enter}");

    cy.get("h2").contains("14 results found");

    cy.get('[type="checkbox"][name="partnership_form[schools][]"]').as(
      "checkboxes"
    );

    cy.get("@checkboxes").eq(0).should("not.be.checked").click();
    cy.get("@checkboxes").eq(1).should("be.checked").click();
    cy.get("@checkboxes").eq(2).should("not.be.checked").click();
    cy.get("@checkboxes").eq(4).should("not.be.checked").click();

    cy.get(".js-partnerships-submit")
      .should("contain", "Add partnerships with 7 schools")
      .should("not.be.disabled")
      .click();

    cy.get("h1").contains("Add partnerships with these 7 schools");
  });

  it("should support removing all schools", () => {
    cy.login("admin");

    // Unfiltered schools - first page
    cy.visit("/lead-provider/search-schools");

    cy.contains("49 results found");

    cy.get('[type="checkbox"][name="partnership_form[schools][]"]').as(
      "checkboxes"
    );

    cy.get("@checkboxes").eq(5).click();
    cy.get("@checkboxes").eq(9).click();
    cy.get("@checkboxes").eq(16).click();

    cy.get(".js-partnerships-submit")
      .as("submit")
      .should("contain", "Add partnerships with 3 schools")
      .should("not.be.disabled");

    cy.get(".js-partnerships-clear")
      .as("clear")
      .should("contain", "Remove all 3 schools")
      .click();

    cy.get("@checkboxes").should("not.be.checked");

    cy.get("@submit")
      .should("contain", "Add partnerships")
      .should("be.disabled");

    cy.get("@clear").should("not.be.visible");
  });
});
