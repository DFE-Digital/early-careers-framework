# Technical Documentation

This project uses the [Tech Docs Template][template], which is a [Middleman template][mmt] that you can use to build technical documentation using a GOV.UK style.

You’re welcome to use the template even if your service isn’t considered part of GOV.UK, but your site or service must not:

- identify itself as being part of GOV.UK
- use the crown or GOV.UK logotype in the header
- use the GDS Transport typeface
- suggest that it’s an official UK government website if it’s not

👉 To find out more about setting up and managing content for a website using this template, see the [Tech Docs Template documentation][tdt-docs].

## Before you start

To use the Tech Docs Template you need:

- [Ruby][install-ruby]
- [Middleman][install-middleman]

## Making changes

To make changes to the documentation for the Tech Docs Template website, edit files in the `source` folder of this repository.

You can add content by editing the `.html.md.erb` files. These files support content in:

- Markdown
- HTML
- Ruby

👉 You can use Markdown and HTML to [generate different content types][example-content] and [Ruby partials to manage content][partials].

👉 Learn more about [producing more complex page structures][multipage] for your website.

## Build

To build the HTML pages from content in your `source` folder, run:

```
bundle exec middleman build --build-dir=../public/api-reference
```

This will place all the built static assets into the public folder ofthe rails app in the parent directory. This site will then be available at `/api-reference`. Attempting to build this site alone will not work as it relies on other assets being served by rails under the `/api-reference` path.

## Troubleshooting

Run `bundle update` to make sure you're using the most recent Ruby gem versions.

Run `bundle exec middleman build --verbose` to get detailed error messages to help with finding the problem.

## Licence

Unless stated otherwise, the codebase is released under [the MIT License][mit].
This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright][copyright] and available under the terms of the [Open Government 3.0][ogl] licence.

[mit]: LICENCE
[copyright]: http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
[mmt]: https://middlemanapp.com/advanced/project_templates/
[tdt-docs]: https://tdt-documentation.london.cloudapps.digital
[config]: https://tdt-documentation.london.cloudapps.digital/configuration-options.html#configuration-options
[frontmatter]: https://tdt-documentation.london.cloudapps.digital/frontmatter.html#frontmatter
[multipage]: https://tdt-documentation.london.cloudapps.digital/multipage.html#build-a-multipage-site
[example-content]: https://tdt-documentation.london.cloudapps.digital/content.html#content-examples
[partials]: https://tdt-documentation.london.cloudapps.digital/single_page.html#add-partial-lines
[install-ruby]: https://tdt-documentation.london.cloudapps.digital/install_macs.html#install-ruby
[install-middleman]: https://tdt-documentation.london.cloudapps.digital/install_macs.html#install-middleman
[gem]: https://github.com/alphagov/tech-docs-gem
[template]: https://github.com/alphagov/tech-docs-template
