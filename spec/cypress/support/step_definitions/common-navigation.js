import { Given, When, Then } from "cypress-cucumber-preprocessor/steps";
import OnRails from "../on-rails";

Given("I am logged in as a {string}", (user) => cy.login(user));
Given("I am logged in as an {string}", (user) => cy.login(user));
Given("I am logged in as an induction coordinator for created school", () => {
  const schoolId = OnRails.getCreatedRecord("school").id;
  cy.appFactories([
    ["create", "user", "induction_coordinator", { school_ids: [schoolId] }],
  ]).then(() => {
    cy.loginCreated("user");
  });
});

Given("scenario {string} has been run", (scenario) => cy.appScenario(scenario));

const pagePaths = {
  cookie: "/cookies",
  start: "/",
  privacy: "/privacy-policy",
  accessibility: "/accessibility-statement",
  dashboard: "/dashboard",
  "2021 cohort CIP materials info":
    "/schools/cohorts/2021/core-programme/materials/info",
  "2021 cohort CIP materials selection":
    "/schools/cohorts/2021/core-programme/materials/edit",
  "2021 cohort CIP materials success":
    "/schools/cohorts/2021/core-programme/materials/success",
  "2021 cohort CIP materials": "/schools/cohorts/2021/core-programme/materials",
  "check account": "/check-account",
  "admin schools": "/admin/schools",
  "admin school overview": "/admin/schools/:id",
  "new admin school induction coordinator":
    "/admin/schools/:id/induction-coordinators/new",
  "admin index": "/admin/administrators",
  "admin induction coordinator edit": "/admin/induction-coordinators/:id/edit",
  "admin creation": "/admin/administrators/new",
  "admin confirm creation": "/admin/administrators/new/confirm",
  "delivery partner index": "/admin/suppliers",
  "choose new delivery partner name":
    "/admin/suppliers/new/delivery-partner/choose-name",
  "choose new delivery partner lead providers":
    "/admin/suppliers/new/delivery-partner/choose-lps",
  "choose delivery partner cohorts":
    "/admin/suppliers/new/delivery-partner/choose-cohorts",
  "new delivery partner review": "/admin/suppliers/new/delivery-partner/review",
  "delivery partner edit": "/delivery-partners/:id/edit",
  "delivery partner delete": "/delivery-partners/:id/delete",
  "users sign in": "/users/sign_in",
  "resend nominations choose location": "nominations/choose-location",
  "resend nominations choose school": "nominations/choose-school",
  "resend nominations review": "nominations/review",
  "resend nominations success": "nominations/success",
  "resend nominations not eligible": "nominations/not-eligible",
  "resend nominations already nominated": "nominations/already-nominated",
  "resend nominations limit reached": "nominations/limit-reached",
  "resend nominations cip only": "nominations/cip-only",
  "start nominations with token": "/nominations/start?token=foo-bar-baz",
  "lead provider users index": "/admin/suppliers/users",
  "new lead provider user": "/admin/suppliers/users/new",
  "new lead provider user details": "/admin/suppliers/users/new/user-details",
  "new lead provider user review": "/admin/suppliers/users/new/review",
  "lead provider user delete": "/lead-providers/users/:id/delete",
  "choose programme": "/schools/choose-programme",
  "choose programme advisory": "/schools/choose-programme/advisory",
  "choose programme confirm": "/schools/choose-programme/confirm-programme",
  "choose programme success": "/schools/choose-programme/success",
  schools: "/schools",
  "2021 school cohorts": "/schools/cohorts/2021",
  "2021 school partnerships": "/schools/cohorts/2021/partnerships",
  "lead providers report schools start": "/lead-providers/report-schools/start",
  "lead providers your schools": "/lead-providers/your-schools",
  "challenge partnership": "/report-incorrect-partnership?token=:id",
  "challenge partnership (any token)": "/report-incorrect-partnership",
  "challenge partnership success": "/report-incorrect-partnership/success",
  "challenge link expired": "/report-incorrect-partnership/link-expired",
  "already challenged": "/report-incorrect-partnership/already-challenged",
  "not found": "/404",
  "internal server error": "/500",
  forbidden: "/403",
  "lead providers report schools choose delivery partner":
    "/lead-providers/report-schools/choose-delivery-partner",
  "partnership csv uploads":
    "/lead-providers/report-schools/partnership-csv-uploads/new",
  "csv errors": "/lead-providers/report-schools/partnership-csv-uploads/errors",
  "confirm partnerships": "/lead-providers/report-schools/confirm",
  "partnerships success": "/lead-providers/report-schools/success",
};

Given("I am on {string} page", (page) => {
  const path = pagePaths[page];
  cy.visit(path);
});

Given("I am on {string} error page", (page) => {
  const path = pagePaths[page];
  cy.visit({
    url: path,
    failOnStatusCode: false,
  });
});

Given("I am on {string} page with id {string}", (page, id) => {
  const path = pagePaths[page].replace(":id", id);
  cy.visit(path);
});

Given("I am on {string} page without JavaScript", (page) => {
  const path = pagePaths[page];
  cy.visit(`${path}?nojs=nojs`);
});

When("I navigate to {string} page", (page) => {
  const path = pagePaths[page];
  cy.visit(path);
});

const assertOnPage = (page) => {
  const path = pagePaths[page];

  if (!path) {
    throw new Error(`Path not found for ${page}`);
  }

  if (path.includes(":id")) {
    const pathRegex = new RegExp(
      path.replace(/\//g, "\\/").replace(":id", "[^/]+")
    );
    cy.location("pathname").should("match", pathRegex);
  } else {
    cy.location("pathname").should("equal", path);
  }
};

Then("I should be on {string} page", (page) => {
  assertOnPage(page);
});

Then("I should have been redirected to {string} page", (page) => {
  assertOnPage(page);
});
