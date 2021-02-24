import accessibleAutocomplete from "accessible-autocomplete";

const searchEl = document.querySelector("#network-autocomplete");

function inputValueTemplate(result) {
  return result && result.name;
}

function suggestionTemplate(result) {
  return result && `<strong>${result.name}</strong>`;
}

function suggest(query, populateResults) {
  fetch(`/api/network_search?search_key=${query}`)
    .then((response) => response.json())
    .then((data) => populateResults(data));
}

if (searchEl) {
  accessibleAutocomplete({
    element: searchEl,
    id: "autocomplete-network-name-field",
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
