#!/bin/bash
CONFIGFILE=${OPENMCT_CONFIG:=eva.js}
OPENMCT_ROOT=${OPENMCT_ROOT:=node_modules/openmct/dist}
echo "Starting OpenMCT with config $OPENMCT_CONFIG at $OPENMCT_ROOT"
node config/${OPENMCT_CONFIG}
