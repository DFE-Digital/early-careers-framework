# frozen_string_literal: true

class SupplierDashboardController < ApplicationController
  def show
    @content = Govspeak::Document.new('

<!-- wp:paragraph -->

Cookies are small files saved on your phone, tablet or computer when you visit a website.

<!-- /wp:paragraph -->

<!-- wp:paragraph -->

We use cookies to make Google Analytics and Wordpress login work and collect information about how you use our service.

<!-- /wp:paragraph -->

<!-- wp:heading -->

## 1. Essential Cookies

<!-- /wp:heading -->

<!-- wp:paragraph -->

Essential cookies enable core functionality such as security, network management, and accessibility to work. Essential cookies keep your information secure while you use the National Early Roll-out of the Early Career Framework website. These cookies are essential to make this site work and we do not need to ask permission to use them.

<!-- /wp:paragraph -->

<!-- wp:paragraph -->

**_There are no essential cookies required for this website._**

<!-- /wp:paragraph -->

<!-- wp:heading -->

## 2. Optional Cookies

<!-- /wp:heading -->

<!-- wp:paragraph -->

Optional Cookies are sometimes known as non-essential cookies. This type of cookie is not essential to enable the site to work, but these cookies collect information about your choices and preferences and make using the website more practical. Without these cookies, certain functionality may become unavailable.

<!-- /wp:paragraph -->

<!-- wp:table -->

| Cookie name            | Purpose                                | Expires |
| ---------------------- | -------------------------------------- | ------- |
| wordpress\_\*_, wp-\*_ | Wordpress session and login management | 2 years |

<!-- /wp:table -->

<!-- wp:heading -->

## 3. Analytics Cookies

<!-- /wp:heading -->

<!-- wp:heading {"level":3} -->

### (a type of optional cookie)

<!-- /wp:heading -->

<!-- wp:paragraph -->

With your permission, we use Google Analytics to collect data about how you use the National Early Roll-out of the Early Career Framework website. This information helps us to improve our service.

<!-- /wp:paragraph -->

<!-- wp:paragraph -->

Google is not allowed to use or share our analytics data with anyone.

<!-- /wp:paragraph -->

<!-- wp:paragraph -->

Google Analytics stores anonymised information about:

<!-- /wp:paragraph -->

<!-- wp:list -->

- how you got to the National Early Roll-out of the Early Career Framework website
- the pages you visit on the National Early Roll-out of the Early Career Framework website and how long you spend on them
- any errors you see while using the National Early Roll-out of the Early Career Framework website

<!-- /wp:list -->

<!-- wp:table -->

| Cookie name   | Purpose                                                                                                                                                | Expires in |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- |
| CookieControl | Checks if you’ve visited the National Early Roll-out of the Early Career Framework website before. This helps us count how many people visit our site. | 2 years    |
| \_ga          | Checks if you’ve visited the National Early Roll-out of the Early Career Framework website before. This helps us count how many people visit our site. | 2 years    |
| \_gat\_\*     | Checks if you’ve visited the National Early Roll-out of the Early Career Framework website before. This helps us count how many people visit our site. | 2 years    |
| \_gid         | Checks if you’ve visited the National Early Roll-out of the Early Career Framework website before. This helps us count how many people visit our site. | 24 hours   |

<!-- /wp:table -->


    ').to_html
  end
end
