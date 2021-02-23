import accessibleAutocomplete from "accessible-autocomplete";

const searchEl = document.querySelector("#school-autocomplete");

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
    id: "autocomplete-school-name-field",
    source: suggest,
    showNoOptionsFound: false,
    minLength: 1,
    name: searchEl.dataset.inputName,
    templates: {
      inputValue: inputValueTemplate,
      suggestion: suggestionTemplate,
    },
  });
}
