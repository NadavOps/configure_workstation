#!/bin/bash
CURRENT_DIR=$(pwd)

back_to_original_dir() {
  echo """WARN: Exit was triggered
        Going back to orig dir for convenience"""
  cd $CURRENT_DIR
}
trap back_to_original_dir EXIT

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")
if [[ $(pwd) != "$SCRIPTS_DIR" ]]; then
  echo """INFO: Current dir is not script dir
      cd into script dir: \"$SCRIPTS_DIR\""""
  cd $SCRIPTS_DIR
fi

set -e
source "bash_import_functions.sh"
set +e

# bash bash_edit_shell_rc.sh "additional_rc_configuration_files"
echo "INFO: Edit shell RC"
bash bash_edit_shell_rc.sh
# bash bash_install_packages.sh "additional_packages_lists for example ./packages_lists/unused.example.conf"
echo "INFO: Install packages"
bash bash_install_packages.sh
