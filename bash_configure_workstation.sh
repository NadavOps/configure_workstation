#!/bin/bash
set -e
source "bash_import_functions.sh"
set +e

# bash bash_edit_shell_rc.sh "additional_rc_configuration_files"
bash bash_edit_shell_rc.sh
# bash bash_install_packages.sh "additional_packages_lists for example ./packages_lists/unused.example.conf"
bash bash_install_packages.sh
