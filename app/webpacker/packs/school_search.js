import accessibleAutocomplete from "accessible-autocomplete";

const searchEl = document.querySelector("#school-search-form-autocomplete");

function inputValueTemplate(result) {
  return result && result.name;
}

function suggestionTemplate(result) {
  return (
    result &&
    `<strong>${result.name}</strong> (${result.full_address_formatted})`
  );
}

function suggest(query, populateResults) {
  fetch(`/api/school_search?search_key=${query}`)
    .then((response) => response.json())
    .then((data) => populateResults(data));
}

if (searchEl) {
  accessibleAutocomplete({
    element: searchEl,
    id: "school-search-form-input",
    source: suggest,
    showNoOptionsFound: false,
    minLength: 1,
    name: "school_search_form[school_name]",
    templates: {
      inputValue: inputValueTemplate,
      suggestion: suggestionTemplate,
    },
  });
}

function getCheckedSchools() {
  const checkedSchools = sessionStorage.getItem("school-search-checked");
  if (checkedSchools) {
    try {
      return JSON.parse(checkedSchools);
    } catch (err) {
      // @todo is there a way of monitoring this?
      // eslint-disable-next-line no-console
      console.warn("Error getting saved data", err);
      return [];
    }
  }

  return [];
}

function getSubmitButton() {
  return document.querySelector(".partnerships-submit");
}

function getClearButton() {
  return document.querySelector("#clear-button");
}

function schoolCount(numberSchools) {
  return `${numberSchools} school${numberSchools === 1 ? "" : "s"}`;
}

function updateButtons(checkedSchools) {
  const submitButton = getSubmitButton();
  const clearButton = getClearButton();

  if (checkedSchools.length === 0) {
    submitButton.disabled = true;
    submitButton.value = "Add partnerships";
    clearButton.classList.add("govuk-!-display-none");
  } else {
    submitButton.disabled = false;
    submitButton.value = `Add partnerships with ${schoolCount(
      checkedSchools.length
    )}`;
    clearButton.classList.remove("govuk-!-display-none");
    clearButton.innerText = `Remove all ${schoolCount(checkedSchools.length)}`;
  }
}

const editSchoolFormEl = document.querySelector("form.new_partnership_form");

const onCheckboxClicked = (event) => {
  const { target } = event;

  if (target.name !== "partnership_form[schools][]") {
    return;
  }

  const checkedSchools = getCheckedSchools();

  if (target.checked) {
    checkedSchools.push(target.value);
  } else if (checkedSchools.includes(target.value)) {
    checkedSchools.splice(checkedSchools.indexOf(target.value), 1);
  }

  updateButtons(checkedSchools);

  const checkedSchoolsString = JSON.stringify(checkedSchools);
  sessionStorage.setItem("school-search-checked", checkedSchoolsString);
};

function clearCheckedSchools() {
  const checkedSchools = getCheckedSchools();
  checkedSchools.forEach((id) => {
    const checkboxEl = document.querySelector(`[value="${id}"]`);
    if (checkboxEl?.type === "hidden") {
      checkboxEl.parentElement.removeChild(checkboxEl);
    } else if (checkboxEl) {
      checkboxEl.checked = false;
    }
    sessionStorage.setItem("school-search-checked", "[]");
    updateButtons([]);
  });
}

if (editSchoolFormEl) {
  const initialData = getCheckedSchools();

  initialData.forEach((id) => {
    const checkboxEl = document.querySelector(`[value="${id}"]`);

    if (checkboxEl) {
      checkboxEl.checked = true;
    } else {
      const hiddenInputEl = document.createElement("input");

      hiddenInputEl.type = "hidden";
      hiddenInputEl.value = id;
      hiddenInputEl.name = "partnership_form[schools][]";

      editSchoolFormEl.appendChild(hiddenInputEl);
    }
  });

  updateButtons(initialData);

  editSchoolFormEl.addEventListener("input", onCheckboxClicked);

  getClearButton()?.addEventListener("click", (event) => {
    event.preventDefault();
    clearCheckedSchools();
  });
}
