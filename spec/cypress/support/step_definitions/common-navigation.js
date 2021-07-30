import { Given, When, Then } from "cypress-cucumber-preprocessor/steps";
import { parseArgs } from "./database";

Given("I am logged in as a {string}", (user) => cy.login(user));
Given("I am logged in as an {string}", (user) => cy.login(user));
Given("I am logged in as an induction coordinator for created school", () => {
  cy.appEval("School.all.first").then((school) => {
    cy.appFactories([
      ["create", "user", "induction_coordinator", { school_ids: [school.id] }],
    ]).then(() => {
      cy.loginCreated("user");
    });
  });
});

Given("scenario {string} has been run", (scenario) => cy.appScenario(scenario));

const pagePaths = {
  cookie: "/cookies",
  start: "/",
  sandbox: "/sandbox",
  privacy: "/privacy-policy",
  accessibility: "/accessibility-statement",
  dashboard: "/dashboard",
  "2021 cohort CIP materials info":
    "/schools/:id/cohorts/2021/core-programme/materials/info",
  "2021 cohort CIP materials selection":
    "/schools/:id/cohorts/2021/core-programme/materials/edit",
  "2021 cohort CIP materials success":
    "/schools/:id/cohorts/2021/core-programme/materials/success",
  "2021 cohort CIP materials":
    "/schools/:id/cohorts/2021/core-programme/materials",
  "check account": "/check-account",
  "admin schools": "/admin/schools",
  "admin school overview": "/admin/schools/:slug",
  "admin school cohorts": "/admin/schools/:slug/cohorts",
  "new admin school induction coordinator":
    "/admin/schools/:slug/induction-coordinators/new",
  "edit admin school induction coordinator":
    "/admin/schools/:slug/induction-coordinators/:id/edit",
  "choose replace or update induction tutor":
    "/admin/schools/:slug/replace-or-update-induction-tutor",
  "admin school participants": "/admin/schools/:slug/participants",
  "admin index": "/admin/administrators",
  "admin participant": "/admin/participants/:id",
  "admin delete participant": "/admin/participants/:id/remove",
  "admin participants": "/admin/participants",
  "admin participant identity": "/admin/participants/:id/validations/identity",
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
  "resend nominations start": "/nominations/resend-email",
  "resend nominations choose location": "/nominations/choose-location",
  "resend nominations choose school": "/nominations/choose-school",
  "resend nominations review": "/nominations/review",
  "resend nominations success": "/nominations/success",
  "resend nominations not eligible": "/nominations/not-eligible",
  "resend nominations already nominated": "/nominations/already-nominated",
  "resend nominations limit reached": "/nominations/limit-reached",
  "resend nominations cip only": "/nominations/cip-only",
  "choose how to continue nominations": "/nominations/choose-how-to-continue",
  "start nominations with token": "/nominations/start?token=foo-bar-baz",
  "lead provider users index": "/admin/suppliers/users",
  "new lead provider user": "/admin/suppliers/users/new",
  "new lead provider user details": "/admin/suppliers/users/new/user-details",
  "new lead provider user review": "/admin/suppliers/users/new/review",
  "lead provider user delete": "/lead-providers/users/:id/delete",
  "choose programme": "/schools/:id/choose-programme",
  "choose programme advisory": "/schools/:id/choose-programme/advisory",
  "choose programme confirm": "/schools/:id/choose-programme/confirm-programme",
  "choose programme success": "/schools/:id/choose-programme/success",
  "design your programme success":
    "/schools/:id/choose-programme/design-your-programme",
  "no early career teachers success":
    "/schools/:id/choose-programme/no-early-career-teachers",
  schools: "/schools",
  "school cohorts": "/schools/:id",
  "2021 school cohorts": "/schools/:id/cohorts/2021",
  "2021 school partnerships": "/schools/:id/cohorts/2021/partnerships",
  "2021 school participants": "/schools/:id/cohorts/2021/participants",
  "2021 school participant":
    "/schools/:school_id/cohorts/2021/participants/:id",
  "2021 school participant type":
    "/schools/:id/cohorts/2021/participants/:id/type",
  "2021 school participant details":
    "/schools/:id/cohorts/2021/participants/:id/details",
  "2021 school participant edit name":
    "/schools/:id/cohorts/2021/participants/:id/edit-name",
  "2021 school participant edit email":
    "/schools/:id/cohorts/2021/participants/:id/edit-email",
  "2021 school participant edit email used":
    "/schools/:school_slug/cohorts/2021/participants/:participant_id/email-used",
  "2021 school choose etc mentor":
    "/schools/:id/cohorts/2021/participants/add/choose-mentor",
  "2021 school edit ect mentor":
    "/schools/:school_slug/cohorts/2021/participants/:participant_id/edit-mentor",
  "2021 school participant confirm":
    "/schools/:id/cohorts/2021/participants/add/confirm",
  "lead providers report schools start": "/lead-providers/report-schools/start",
  "lead providers your schools": "/lead-providers/your-schools",
  "challenge partnership": "/report-incorrect-partnership?token=:id",
  "challenge partnership (any token)": "/report-incorrect-partnership",
  "challenge partnership success": "/report-incorrect-partnership/success",
  "challenge link expired": "/report-incorrect-partnership/link-expired",
  "already challenged": "/report-incorrect-partnership/already-challenged",
  "not found": "/404",
  "internal server error": "/500",
  pages: "/pages",
  "ambition year one induction tutor materials":
    "/induction-tutor-materials/ambition-institute/year-one",
  "ambition year two induction tutor materials":
    "/induction-tutor-materials/ambition-institute/year-two",
  "edt year one induction tutor materials":
    "/induction-tutor-materials/education-development-trust/year-one",
  "edt year two induction tutor materials":
    "/induction-tutor-materials/education-development-trust/year-two",
  "teach first year one and two induction tutor materials":
    "/induction-tutor-materials/teach-first/year-one",
  "ucl year one induction tutor materials":
    "/induction-tutor-materials/ucl-institute-of-education/year-one",
  "ucl year two induction tutor materials":
    "/induction-tutor-materials/ucl-institute-of-education/year-two",
  forbidden: "/403",
  "lead providers report schools choose delivery partner":
    "/lead-providers/report-schools/delivery-partner",
  "partnership csv uploads": "/lead-providers/report-schools/csv",
  "csv errors": "/lead-providers/report-schools/csv/errors",
  "confirm partnerships": "/lead-providers/report-schools/confirm",
  "partnerships success": "/lead-providers/report-schools/success",
  "the sandbox landing page": "/sandbox",
  "the Lead Provider landing page": "/lead-providers",
  "Partnership guidance": "/lead-providers/partnership-guide",
  "API Documentation": "/api-docs/index.html",
  "API guidance home": "/lead-providers/guidance/home",
  "ECF usage guide": "/lead-providers/guidance/ecf-usage",
  "NPQ usage guide": "/lead-providers/guidance/npq-usage",
  "API release notes": "/lead-providers/guidance/release-notes",
  "API guidance support": "/lead-providers/guidance/help",
  "2020 programme choice":
    "/schools/:school_id/year-2020/choose-induction-programme",
  "2020 cip choice":
    "/schools/:school_id/year-2020/choose-core-induction-programme",
  "2020 add teacher": "/schools/:school_id/year-2020/add-teacher",
  "2020 edit teacher": "/schools/:school_id/year-2020/edit-teacher",
  "2020 remove teacher": "/schools/:school_id/year-2020/remove-teacher",
  "2020 check your answers": "/schools/:school_id/year-2020/check-your-answers",
  "2020 success": "/schools/:school_id/year-2020/success",
};

Given("I am on {string} path", (path) => {
  cy.visit(path);
});

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

const ID_REGEX = /:([a-z_]+)/g;

Given("I am on {string} page with {}", (page, argsString) => {
  const args = parseArgs(argsString);
  const path = pagePaths[page].replace(ID_REGEX, (_, key) => args[key]);
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

When("I navigate to {string} page with {}", (page, argsString) => {
  const args = parseArgs(argsString);
  const path = pagePaths[page].replace(ID_REGEX, (_, key) => args[key]);
  cy.visit(path);
});

const assertOnPage = (page) => {
  const path = pagePaths[page];

  if (!path) {
    throw new Error(`Path not found for ${page}`);
  }

  if (path.includes(":")) {
    const pathRegex = new RegExp(
      path.replace(/\//g, "\\/").replace(ID_REGEX, "[^/]+")
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
