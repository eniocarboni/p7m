# ----------------------------------------
# Include file for p7m tests file
# See: https://github.com/eniocarboni/p7m
# Author: Enio Carboni
# ----------------------------------------

TC_OK=''
TC_ERR=''
TC_INFO=''
TC_SKIP=''
TC_NC='' # No Color
if [ -t 1 ]; then
  TC_OK='\033[1;37m'
  TC_ERR='\033[1;31m'
  TC_INFO='\033[1;32m'
  TC_SKIP='\033[1;33m'
  TC_NC='\033[0m' # No Color
fi

T_name=$(basename $0 .t)
T_dir=$(dirname $(realpath $0))
T_descr="Test"
T_TOT=1
T_test=0
T_OK=0
T_ERR=0
T_SKIP=0

T_Start() {
	echo -e "${TC_INFO}Start test: $T_name:${TC_NC} - $T_descr ($T_TOT)"
}

T_End() {
	echo -e "${TC_INFO}End test: $T_name${TC_NC} (${TC_OK} OK: ${T_OK}/$T_TOT${TC_NC} , ${TC_ERR}ERR: $T_ERR/$T_TOT${TC_NC}, ${TC_SKIP}SKIP: $T_SKIP/$T_TOT${TC_NC})"
}

T_Test() {
	local check="$1"
	local msg_ok=""
	local msg_err=""
	if [ -n "$2" ]; then
		msg_ok=" $2"
		msg_err="$2"
	fi
	if [ -n "$3" ]; then
		msg_err="$msg_err $3"
	fi
	msg_err=" [$msg_err]"
	T_test=$(( $T_test + 1 ))
	if [ $check -eq '0' ]; then
	  T_OK=$(($T_OK + 1))
	  echo -e "\ttest $T_test/$T_TOT ${TC_OK}OK${TC_NC} ${msg_ok}"
	else
	  T_ERR=$(($T_ERR + 1))
	  echo -e "\ttest $T_test/$T_TOT ${TC_ERR}ERR${msg_err}${TC_NC}"
	fi
}

T_Skip() {
	local why_skip=''
	if [ -n "$1" ]; then
		why_skip="[$1]"
	fi
	T_test=$(( $T_test + 1 ))
	T_SKIP=$(( $T_SKIP + 1 ))
	echo -e "\ttest $T_test/$T_TOT ${TC_SKIP}SKIP ${why_skip}${TC_NC}"
}
