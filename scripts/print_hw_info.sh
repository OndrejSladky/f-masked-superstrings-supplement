#! /usr/bin/env bash

set -e
set -o pipefail
set -u

echo
echo "HW Info"
echo "======="
echo
( hwinfo || echo "NA" ) 2>/dev/null
echo

echo
echo "OSX SPHardwareDataType"
echo "======================"
echo
( system_profiler SPHardwareDataType || echo "NA" ) 2>/dev/null
echo

echo
echo "Hostname"
echo "========"
echo
( hostname || echo "NA" ) 2>/dev/null


echo
echo "CPU info"
echo "========"
echo
(cat /proc/cpuinfo || true)

echo
echo "MEM info"
echo "========"
echo
(cat /proc/meminfo || true)

