import accessibleAutocomplete from "accessible-autocomplete";

const searchEl = document.querySelector("#school-search-form-autocomplete");

function inputValueTemplate(result) {
  return result && result.name;
}

function suggestionTemplate(result) {
  return (
    result
    && `<strong>${result.name}</strong> (${result.full_address_formatted})`
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

const editSchoolFormEl = document.querySelector("form.edit_school");

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
      hiddenInputEl.name = "school[id][]";

      editSchoolFormEl.appendChild(hiddenInputEl);
    }
  });

  editSchoolFormEl.addEventListener("input", (e) => {
    const { target } = e;

    if (target.name !== "school[id][]") {
      return;
    }

    const checkedSchools = getCheckedSchools();

    if (target.checked) {
      checkedSchools.push(target.value);
    } else if (checkedSchools.includes(target.value)) {
      checkedSchools.splice(checkedSchools.indexOf(target.value), 1);
    }

    const checkedSchoolsString = JSON.stringify(checkedSchools);
    sessionStorage.setItem("school-search-checked", checkedSchoolsString);
  });
}
