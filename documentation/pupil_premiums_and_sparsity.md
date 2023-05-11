# Annual changes to pupil premiums and sparsity

Before each new academic year, as part of the readiness preparations, we need to add pupil premium and sparsity incentives for the coming year.  We should be given a CSV file from policy colleagues to upload.  The CSV file __must__ have the following columns:

- URN
- Pupil Premium Incentive
- Sparsity Incentive

The new CSV file will need to be added to the `data` folder at the root of the application and committed to the Github repository.

## Filename convention

The CSV file shouild be given the filename:

```shell
data/pupil_premium_and_sparsity_<academic year>.csv	
```

where `academic year` is the respective numeric year e.g. `2024` for the 2024 to 2025 academic year



## Importing the data

Once the PR with the new CSV data has been approved, merged and deployed, the data can be imported using a `rake` task from the console.

```shell
bundle exec rails pupil_premium:import
```

