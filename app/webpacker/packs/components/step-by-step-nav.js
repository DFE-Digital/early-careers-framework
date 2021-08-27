// Adapted from https://raw.githubusercontent.com/alphagov/govuk_publishing_components/master/app/assets/javascripts/govuk_publishing_components/components/step-by-step-nav.js

/* eslint-disable */
const stepByStep = document.getElementById("step-by-step-navigation");

stepByStep.actions = {}; // stores text for JS appended elements 'show' and 'hide' on steps, and 'show/hide all' button
stepByStep.rememberShownStep = false;
stepByStep.stepNavSize = false;
stepByStep.sessionStoreLink = "govuk-step-nav-active-link";
stepByStep.activeLinkClass = "gem-c-step-nav__list-item--active";
stepByStep.activeStepClass = "gem-c-step-nav__step--active";
stepByStep.activeLinkHref = "#content";
stepByStep.uniqueId = false;

// Indicate that js has worked
stepByStep.classList.add("app-step-nav--active");

// Prevent FOUC, remove class hiding content
stepByStep.classList.remove("js-hidden");

stepByStep.stepNavSize = stepByStep.classList.contains("app-step-nav--large")
  ? "Big"
  : "Small";
stepByStep.rememberShownStep =
  !!stepByStep.hasAttribute("data-remember") &&
  stepByStep.stepNavSize === "Big";

stepByStep.steps = stepByStep.querySelectorAll(".js-step");
stepByStep.stepHeaders = stepByStep.querySelectorAll(".js-toggle-panel");
stepByStep.totalSteps = stepByStep.querySelectorAll(".js-panel").length;
stepByStep.totalLinks = stepByStep.querySelectorAll(
  ".app-step-nav__link"
).length;
stepByStep.showOrHideAllButton = false;

stepByStep.uniqueId = stepByStep.getAttribute("data-id") || false;

if (stepByStep.uniqueId) {
  stepByStep.sessionStoreLink = `${stepByStep.sessionStoreLink}_${stepByStep.uniqueId}`;
}

stepByStep.upChevronSvg =
  '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">' +
  '<path class="app-step-nav__chevron-stroke" d="M19.5 10C19.5 15.2467 15.2467 19.5 10 19.5C4.75329 19.5 0.499997 15.2467 0.499998 10C0.499999 4.7533 4.7533 0.500001 10 0.500002C15.2467 0.500003 19.5 4.7533 19.5 10Z" stroke="#1D70B8"/>' +
  '<path class="app-step-nav__chevron-stroke" d="M6.32617 12.3262L10 8.65234L13.6738 12.3262" stroke="#1D70B8" stroke-width="2"/>' +
  "</svg>";
stepByStep.downChevronSvg =
  '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">' +
  '<path class="app-step-nav__chevron-stroke" d="M0.499997 10C0.499998 4.75329 4.75329 0.499999 10 0.499999C15.2467 0.5 19.5 4.75329 19.5 10C19.5 15.2467 15.2467 19.5 10 19.5C4.75329 19.5 0.499997 15.2467 0.499997 10Z" stroke="#1D70B8"/>' +
  '<path class="app-step-nav__chevron-stroke" d="M13.6738 8.67383L10 12.3477L6.32617 8.67383" stroke="#1D70B8" stroke-width="2"/>' +
  "</svg>";

function getTextForInsertedElements() {
  stepByStep.actions.showText = stepByStep.getAttribute("data-show-text");
  stepByStep.actions.hideText = stepByStep.getAttribute("data-hide-text");
  stepByStep.actions.showAllText = stepByStep.getAttribute(
    "data-show-all-text"
  );
  stepByStep.actions.hideAllText = stepByStep.getAttribute(
    "data-hide-all-text"
  );
}

function addShowHideAllButton() {
  const showall = document.createElement("div");
  showall.className = "app-step-nav__controls govuk-!-display-none-print";
  showall.innerHTML =
    `${
      '<button aria-expanded="false" class="app-step-nav__button app-step-nav__button--controls js-step-controls-button">' +
      '<span class="app-step-nav__button-text app-step-nav__button-text--all js-step-controls-button-text">'
    }${stepByStep.actions.showAllText}</span>` +
    `<span class="app-step-nav__chevron js-step-controls-button-icon">${stepByStep.downChevronSvg}</span>` +
    `</button>`;

  const steps = stepByStep.querySelectorAll(".app-step-nav__steps")[0];
  stepByStep.insertBefore(showall, steps);

  stepByStep.showOrHideAllButton = stepByStep.querySelectorAll(
    ".js-step-controls-button"
  )[0];
}

function addShowHideToggle() {
  for (let i = 0; i < stepByStep.stepHeaders.length; i++) {
    const thisel = stepByStep.stepHeaders[i];

    if (!thisel.querySelectorAll(".js-toggle-link").length) {
      const span = document.createElement("span");
      const showHideSpan = document.createElement("span");
      const showHideSpanText = document.createElement("span");
      const showHideSpanIcon = document.createElement("span");
      const commaSpan = document.createElement("span");
      const thisSectionSpan = document.createElement("span");

      showHideSpan.className =
        "app-step-nav__toggle-link js-toggle-link govuk-!-display-none-print";
      showHideSpanText.className =
        "app-step-nav__button-text js-toggle-link-text";
      showHideSpanIcon.className = "app-step-nav__chevron js-toggle-link-icon";
      commaSpan.className = "govuk-visually-hidden";
      thisSectionSpan.className = "govuk-visually-hidden";

      showHideSpan.appendChild(showHideSpanText);
      showHideSpan.appendChild(showHideSpanIcon);

      commaSpan.innerHTML = ", ";
      thisSectionSpan.innerHTML = " this section";

      span.appendChild(commaSpan);
      span.appendChild(showHideSpan);
      span.appendChild(thisSectionSpan);

      thisel.querySelectorAll(".js-step-title-button")[0].appendChild(span);
    }
  }
}

function addAriaControlsAttrForShowHideAllButton() {
  const ariaControlsValue = stepByStep
    .querySelectorAll(".js-panel")[0]
    .getAttribute("id");
  stepByStep.showOrHideAllButton.setAttribute(
    "aria-controls",
    ariaControlsValue
  );
}

// called by show all/hide all, sets all steps accordingly
function setAllStepsShownState(isShown) {
  const data = [];

  for (let i = 0; i < stepByStep.steps.length; i++) {
    const stepView = new StepView(stepByStep.steps[i], stepByStep);
    stepView.setIsShown(isShown);

    if (isShown) {
      data.push(stepByStep.steps[i].getAttribute("id"));
    }
  }

  if (isShown) {
    saveToSessionStorage(stepByStep.uniqueId, JSON.stringify(data));
  } else {
    removeFromSessionStorage(stepByStep.uniqueId);
  }
}

// called on load, determines whether each step should be open or closed
function showPreviouslyOpenedSteps() {
  const data = loadFromSessionStorage(stepByStep.uniqueId) || [];

  for (let i = 0; i < stepByStep.steps.length; i++) {
    const thisel = stepByStep.steps[i];
    const id = thisel.getAttribute("id");
    const stepView = new StepView(thisel, stepByStep);
    const shouldBeShown = thisel.hasAttribute("data-show");

    // show the step if it has been remembered or if it has the 'data-show' attribute
    if (
      (stepByStep.rememberShownStep && data.indexOf(id) > -1) ||
      (shouldBeShown && shouldBeShown !== "undefined")
    ) {
      stepView.setIsShown(true);
    } else {
      stepView.setIsShown(false);
    }
  }

  if (data.length > 0) {
    stepByStep.showOrHideAllButton.setAttribute("aria-expanded", true);
    setShowHideAllText();
  }
}

function addButtonstoSteps() {
  for (let i = 0; i < stepByStep.steps.length; i++) {
    const thisel = stepByStep.steps[i];
    const title = thisel.querySelectorAll(".js-step-title")[0];
    const contentId = thisel
      .querySelectorAll(".js-panel")[0]
      .getAttribute("id");
    const titleText = title.textContent || title.innerText; // IE8 fallback

    title.outerHTML =
      `${
        '<span class="js-step-title">' +
        "<button " +
        'class="app-step-nav__button app-step-nav__button--title js-step-title-button" ' +
        'aria-expanded="false" aria-controls="'
      }${contentId}">` +
      `<span class="app-step-nav__title-text js-step-title-text">${titleText}</span>` +
      `</button>` +
      `</span>`;
  }
}

function bindToggleForSteps() {
  const togglePanels = stepByStep.querySelectorAll(".js-toggle-panel");

  for (let i = 0; i < togglePanels.length; i++) {
    togglePanels[i].addEventListener("click", function (event) {
      const stepView = new StepView(this.parentNode, stepByStep);
      stepView.toggle();

      setShowHideAllText();
      rememberStepState(this.parentNode);
    });
  }
}

// if the step is open, store its id in session store
// if the step is closed, remove its id from session store
function rememberStepState(step) {
  if (stepByStep.rememberShownStep) {
    const data = JSON.parse(loadFromSessionStorage(stepByStep.uniqueId)) || [];
    const thisstep = step.getAttribute("id");
    const shown = step.classList.contains("step-is-shown");

    if (shown) {
      data.push(thisstep);
    } else {
      const i = data.indexOf(thisstep);
      if (i > -1) {
        data.splice(i, 1);
      }
    }
    saveToSessionStorage(stepByStep.uniqueId, JSON.stringify(data));
  }
}

// tracking click events on links in step content
function bindComponentLinkClicks() {
  const jsLinks = stepByStep.querySelectorAll(".js-link");
  const that = this;

  for (let i = 0; i < jsLinks.length; i++) {
    jsLinks[i].addEventListener("click", function (event) {
      const dataPosition = getAttribute("data-position");
      const linkClick = new that.ComponentLinkClick(
        event,
        dataPosition,
        stepByStep.stepNavSize
      );
      linkClick.trackClick();

      if (this.getAttribute("rel") !== "external") {
        that.saveToSessionStorage(stepByStep.sessionStoreLink, dataPosition);
      }

      if (this.getAttribute("href") === stepByStep.activeLinkHref) {
        that.setOnlyThisLinkActive(this);
        that.setActiveStepClass();
      }
    });
  }
}

function saveToSessionStorage(key, value) {
  window.sessionStorage.setItem(key, value);
}

function loadFromSessionStorage(key) {
  return window.sessionStorage.getItem(key);
}

function removeFromSessionStorage(key) {
  window.sessionStorage.removeItem(key);
}

function setOnlyThisLinkActive(clicked) {
  const allActiveLinks = stepByStep.querySelectorAll(
    `.${stepByStep.activeLinkClass}`
  );
  for (let i = 0; i < allActiveLinks.length; i++) {
    allActiveLinks[i].classList.remove(stepByStep.activeLinkClass);
  }
  clicked.parentNode.classList.add(stepByStep.activeLinkClass);
}

// if a link occurs more than once in a step nav, the backend doesn't know which one to highlight
// so it gives all those links the 'active' attribute and highlights the last step containing that link
// if the user clicked on one of those links previously, it will be in the session store
// this code ensures only that link and its corresponding step have the highlighting
// otherwise it accepts what the backend has already passed to the component
function ensureOnlyOneActiveLink() {
  const activeLinks = stepByStep.querySelectorAll(
    `.js-list-item.${stepByStep.activeLinkClass}`
  );

  if (activeLinks.length <= 1) {
    return;
  }

  const loaded = this.loadFromSessionStorage(stepByStep.sessionStoreLink);
  const activeParent = stepByStep.querySelectorAll(
    `.${stepByStep.activeLinkClass}`
  )[0];
  const activeChild = activeParent.firstChild;
  const foundLink = activeChild.getAttribute("data-position");
  let lastClicked = loaded || foundLink; // the value saved has priority

  // it's possible for the saved link position value to not match any of the currently duplicate highlighted links
  // so check this otherwise it'll take the highlighting off all of them
  const checkLink = stepByStep.querySelectorAll(
    `[data-position="${lastClicked}"]`
  )[0];

  if (checkLink) {
    if (!checkLink.parentNode.classList.contains(stepByStep.activeLinkClass)) {
      lastClicked = checkLink;
    }
  } else {
    lastClicked = foundLink;
  }

  this.removeActiveStateFromAllButCurrent(activeLinks, lastClicked);
  this.setActiveStepClass();
}

function removeActiveStateFromAllButCurrent(activeLinks, current) {
  for (let i = 0; i < activeLinks.length; i++) {
    const thisel = activeLinks[i];
    if (
      thisel
        .querySelectorAll(".js-link")[0]
        .getAttribute("data-position")
        .toString() !== current.toString()
    ) {
      thisel.classList.remove(stepByStep.activeLinkClass);
      const visuallyHidden = thisel.querySelectorAll(".visuallyhidden");
      if (visuallyHidden.length) {
        visuallyHidden[0].parentNode.removeChild(visuallyHidden[0]);
      }
    }
  }
}

function setActiveStepClass() {
  // remove the 'active/open' state from all steps
  const allActiveSteps = stepByStep.querySelectorAll(
    `.${stepByStep.activeStepClass}`
  );
  for (let i = 0; i < allActiveSteps.length; i++) {
    allActiveSteps[i].classList.remove(stepByStep.activeStepClass);
    allActiveSteps[i].removeAttribute("data-show");
  }

  // find the current page link and apply 'active/open' state to parent step
  const activeLink = stepByStep.querySelectorAll(
    `.${stepByStep.activeLinkClass}`
  )[0];
  if (activeLink) {
    const activeStep = activeLink.closest(".app-step-nav__step");
    activeStep.classList.add(stepByStep.activeStepClass);
    activeStep.setAttribute("data-show", "");
  }
}

function bindToggleShowHideAllButton() {
  stepByStep.showOrHideAllButton.addEventListener("click", function (event) {
    const textContent = this.textContent || this.innerText;
    const shouldShowAll = textContent === stepByStep.actions.showAllText;

    setAllStepsShownState(shouldShowAll);
    stepByStep.showOrHideAllButton.setAttribute("aria-expanded", shouldShowAll);
    setShowHideAllText();

    return false;
  });
}

function setShowHideAllText() {
  const shownSteps = stepByStep.querySelectorAll(".step-is-shown").length;

  // Find out if the number of is-opens == total number of steps
  const shownStepsIsTotalSteps = shownSteps === stepByStep.totalSteps;

  stepByStep.showOrHideAllButton.querySelector(
    ".js-step-controls-button-text"
  ).innerHTML = shownStepsIsTotalSteps
    ? stepByStep.actions.hideAllText
    : stepByStep.actions.showAllText;
  stepByStep.showOrHideAllButton.querySelector(
    ".js-step-controls-button-icon"
  ).innerHTML = shownStepsIsTotalSteps
    ? stepByStep.upChevronSvg
    : stepByStep.downChevronSvg;
}

class StepView {
  constructor(stepElement, $module) {
    this.stepElement = stepElement;
    this.stepContent = stepElement.querySelectorAll(".js-panel")[0];
    this.titleButton = stepElement.querySelectorAll(".js-step-title-button")[0];
    const textElement = stepElement.querySelectorAll(".js-step-title-text")[0];
    this.title = textElement.textContent || textElement.innerText;
    this.title = this.title.replace(/^\s+|\s+$/g, ""); // this is 'trim' but supporting IE8
    this.showText = $module.actions.showText;
    this.hideText = $module.actions.hideText;
    this.upChevronSvg = $module.upChevronSvg;
    this.downChevronSvg = $module.downChevronSvg;
  }

  show() {
    this.setIsShown(true);
  }

  hide() {
    this.setIsShown(false);
  }

  toggle() {
    this.setIsShown(this.isHidden());
  }

  setIsShown(isShown) {
    if (isShown) {
      this.stepElement.classList.add("step-is-shown");
      this.stepContent.classList.remove("js-hidden");
    } else {
      this.stepElement.classList.remove("step-is-shown");
      this.stepContent.classList.add("js-hidden");
    }

    this.titleButton.setAttribute("aria-expanded", isShown);
    const showHideText = this.stepElement.querySelectorAll(
      ".js-toggle-link"
    )[0];

    showHideText.querySelector(".js-toggle-link-text").innerHTML = isShown
      ? this.hideText
      : this.showText;
    showHideText.querySelector(".js-toggle-link-icon").innerHTML = isShown
      ? this.upChevronSvg
      : this.downChevronSvg;
  }

  isShown() {
    return this.stepElement.classList.contains("step-is-shown");
  }

  isHidden() {
    return !this.isShown();
  }

  numberOfContentItems() {
    return this.stepContent.querySelectorAll(".js-link").length;
  }
}

getTextForInsertedElements();
addButtonstoSteps();
addShowHideAllButton();
addShowHideToggle();
addAriaControlsAttrForShowHideAllButton();

ensureOnlyOneActiveLink();
showPreviouslyOpenedSteps();

bindToggleForSteps();
bindToggleShowHideAllButton();
bindComponentLinkClicks();
/* eslint-enable */
