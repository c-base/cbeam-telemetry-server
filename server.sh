#!/bin/bash
CONFIGFILE=${OPENMCT_CONFIG:=eva.js}
echo "Starting OpenMCT with config $OPENMCT_CONFIG"
node config/${OPENMCT_CONFIG}
