/* eslint-disable no-param-reassign */

const setPageTitle = (target) => {
  if (!("filename" in target.dataset)) return;

  target.dataset.document_title = document.title;
  document.title = target.dataset.filename;
};

const restorePageTitle = (target) => {
  if (!("document_title" in target.dataset)) return;

  document.title = target.dataset.document_title;
};

const formatSummaryDetails = () => {
  document.querySelectorAll("details").forEach((detail) => {
    detail.open = true;

    const summaryText = detail.querySelector(".govuk-details__summary");
    summaryText.style.display = "none";

    const heading = document.createElement("h3");
    heading.textContent = summaryText.textContent;
    detail.prepend(heading);
  });
};

const restoreSummaryDetails = () => {
  document.querySelectorAll("details").forEach((detail) => {
    detail.open = false;

    const summaryText = detail.querySelector(".govuk-details__summary");
    summaryText.style.display = "inline-block";

    detail.querySelector("h3").remove();
  });
};

document.querySelectorAll(".print-link").forEach((link) => {
  link.onclick = () => {
    formatSummaryDetails();
    setPageTitle(link);

    window.print();

    restorePageTitle(link);
    restoreSummaryDetails();
  };
});
