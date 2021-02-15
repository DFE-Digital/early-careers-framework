import accessibleAutocomplete from "accessible-autocomplete";
import "whatwg-fetch";

const element = document.querySelector("#school-search-form-autocomplete");
const id = "school-search-form-input";

function inputValueTemplate(result) {
  return result && result.name;
}

function suggestionTemplate(result) {
  return result && `<strong>${result.name}</strong> (${result.full_address_formatted})`;
}

function suggest(query, populateResults) {
  fetch(`/api/school_search?search_key=${query}`)
    .then((response) => response.json())
    .then((data) => populateResults(data));
}

accessibleAutocomplete({
  element,
  id,
  source: suggest,
  showNoOptionsFound: false,
  minLength: 1,
  name: "school_search_form[school_name]",
  templates: {
    inputValue: inputValueTemplate,
    suggestion: suggestionTemplate,
  },
});
