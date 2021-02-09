## Rails secrets management
We are using rails credentials to manage secrets. If you need to modify secrets for one of the deployed environments,
you can get the encryption keys from another developer on the team.

Once you have the keys, run `rails credentials:edit --environment <env>`. Full instructions can be found by running `rails credentials:help`