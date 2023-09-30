# dns_azure2
An acme.sh Azure DNS API that doesn't require installing dependencies

UNDER DEVELOPMENT

What is working:
* Authentication requires bearer token. You can get one here: https://learn.microsoft.com/en-us/rest/api/dns/record-sets/create-or-update
* Create or update TXT record to verify domain ownership

What is not working
* Delete TXT record. This is not a priority because we create-or-update, so the old TXT records get replaced instead of appended to.
* Configuration variables outside of the script. You need to modify the script source at the top to change the config variables for now.

What do we need
* Rename the config variable prefix to start with something nicer than MY_
* A better authentication than bearer token.
