# dns_azure2
An acme.sh Azure DNS API that doesn't require installing dependencies

UNDER DEVELOPMENT

What is not working
* Configuration variables outside of the script. You need to modify the script source at the top to change the config variables for now.

What do we need
* Rename the config variable prefix to start with something nicer than MY_.
* Move configuration away from the source code file.
* Consider a mechanism to rotate credentials.
* Consider a better authentication method than app secret.
* User-friendly instructions for Azure DNS, app registration, and which values to copy-paste from Azure portal to script config variables.
