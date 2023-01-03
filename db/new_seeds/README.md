# New seeds 🌱

This is a replacement for the old way of seeding data.

It uses special factories prefixed with `seed_` that by default don't create any
objects other than themselves. They all have a `:valid` trait that will create
the necessary associations for them to be valid.

## Nathan's wishlist:

I'd add in a few participants who:

- [x] I'd add in a few participants who have transferred to that school and
      continued with their original training provider (i.e. have a relationship
      rather than a partnership)
- [ ] have transferred to that school and now adopted the new school's training provision
- [ ] are mentoring >1 ECT and those ECTs are all being trained by the same provider
- [ ] are mentoring >1 ECT and those ECTs are not all being trained by the same provider
- [ ] is due to leave the school
- [ ] has left the school
- [ ] are representative of the main schedules as well the cohorts e.g.
      ecf-standard-september versus jan/apr and versus
      extended/reduced/replacement


