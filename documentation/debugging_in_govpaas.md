## Debugging in GovPaaS
There situations in the dev environment where it would be useful to see server logs, have database access, or rails console access.
This should not be used in other environments.

### Setup
The following assumed you have the cloudfoundry CLI set up on your machine, and have logged in. 
When you log in, you should select the dev space. Instructions can be found [here](https://docs.cloud.service.gov.uk/get_started.html#set-up-the-cloud-foundry-command-line)

### View logs
To view logs, you will first need to know the service name. `cf a` will list services, but the service name will probably be `ecf-dev`.

To view recent logs:

```cf logs --recent <app_name>```

To tail logs (view them as they are generated)

```cf logs <app_name>```

### Get access to the database
You will need to have the `psql` command on your path for this to work. 
For a Debian/Ubuntu based system, this can be achieved with `sudo apt-get install postgresql-client-12`
On mac, installing through homebrew with `brew install postgres` is easiest.

The first time you try this, you will need to install the conduit plugin:

`cf install-plugin conduit`

You can list the services with `cf s`, but the service name will generally be `ecf-postgres-dev`. For interactive access, use:

`cf conduit ecf-postgres-dev -- psql`

### Rails console
First, ssh into the host instance

`cf ssh <app_name>`

Then, 

`cd /app`

and finally

`/usr/local/bin/bundle exec rails console`