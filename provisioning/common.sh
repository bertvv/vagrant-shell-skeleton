#! /bin/bash
#
# Provisioning script common for all servers

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
# TODO: put all variable definitions here. Tip: make them readonly if possible.

#------------------------------------------------------------------------------
# Provisioning tasks
#------------------------------------------------------------------------------

log 'Starting common provisioning tasks'

# TODO: insert common provisioning code here, e.g. install EPEL repository, add
# users, enable SELinux, etc.
