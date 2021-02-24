import accessibleAutocomplete from "accessible-autocomplete";

const searchEl = document.querySelector("#local-authority-autocomplete");

function inputValueTemplate(result) {
  return result && result.name;
}

function suggestionTemplate(result) {
  return result && `<strong>${result.name}</strong>`;
}

function suggest(query, populateResults) {
  fetch(`/api/local_authority_search?search_key=${query}`)
    .then((response) => response.json())
    .then((data) => populateResults(data));
}

if (searchEl) {
  accessibleAutocomplete({
    element: searchEl,
    id: "autocomplete-local-authority-name-field",
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
