#! /bin/bash
# Test compatibility with old bash version 

T_dir=$(dirname $(realpath $0))
source ${T_dir}/../lib/p7mtestlib.sh
T_descr="Bash compatibility to old versions"
T_TOT=6

T_Start

bash_version="${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}"
i=0
for c in 43 42 41 40 32 31; do
  i=$(( $i + 1 ))
  if [ ${bash_version} -le $c ]; then
	T_Skip "bash version less or equal to $c"
	continue
  fi
  (
  shopt -s compat$c
  set -e
  source ${T_dir}/../../bin/p7m -t
  )
  T_Test "$?" "compatibility $i/6" ": bash version $c"
done
T_End
