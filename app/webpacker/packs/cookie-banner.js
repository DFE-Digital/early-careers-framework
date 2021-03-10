const cookieBannerEl = document.querySelector(".js-cookie-banner");

if (cookieBannerEl) {
  const cookieFormEl = document.querySelector(".js-cookie-form");

  cookieFormEl.addEventListener("click", (e) => {
    if (e.target.tagName !== "BUTTON") {
      return;
    }

    fetch(cookieFormEl.action, {
      method: "PUT",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        cookies_form: { analytics_consent: e.target.value },
      }),
    })
      .then((res) => res.json())
      .then(({ message }) => {
        const messageEl = cookieBannerEl.querySelector(".js-cookie-message");
        messageEl.textContent = message;

        cookieBannerEl
          .querySelector(".js-cookie-banner__form")
          .setAttribute("hidden", "");
        cookieBannerEl
          .querySelector(".js-cookie-banner__success")
          .removeAttribute("hidden");
      });

    e.preventDefault();
  });

  const hideBannerEl = document.querySelector(".js-hide-cookie-banner");
  hideBannerEl.addEventListener("click", (e) => {
    e.preventDefault();

    cookieBannerEl.setAttribute("hidden", "");
  });
}
