#!/bin/bash

source ./config
source ./functions

function usage {
  cat <<EOF
Usage: $(basename $0) <option>

Options:
  create_rg
  delete_rg
  create_cluster
  delete_cluster
  create_acr
  delete_acr
  setup_credentials

EOF
}

case $1 in
  create_rg)
    create_rg;;
  delete_rg)
    delete_rg;;
  create_cluster)
    create_cluster;;
  delete_cluster)
    delete_cluster;;
  create_acr)
    create_acr;;
  delete_acr)
    delete_acr;;
  setup_credentials)
    setup_credentials;;
  *)
    usage;;
esac
