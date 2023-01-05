# Seed factories

This is a reimplementation of the original factories with the following rules in
place to keep them in order.

1. Files end in `_factory.rb` which makes them easier to find in the project
2. No callbacks except for logging
3. No relationships by default, they should be defined in traits (e.g., `with_user`)
4. Must implement a `:valid` trait that generates a valid object
5. Must have a corresponding spec in `spec/seeds/seed_factories/`
6. Don't call service objects from factories, if we can't generate records directly the schema is too complex
7. If you _really need_ to create a complex network of objects use a scenario, see `db/new_seeds/scenarios`
