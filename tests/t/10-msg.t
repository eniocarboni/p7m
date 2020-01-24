#! /bin/bash
# Test Lang messages

T_dir=$(dirname $(realpath $0))
source ${T_dir}/../lib/p7mtestlib.sh
T_descr="Lang messages"
T_TOT=13

T_Start
source ${T_dir}/../../bin/p7m -t
populate_msg
test ${#msgKey[@]} -gt 0
T_Test "$?" "msgKey 1/2"
test ${#msgVal[@]} -gt 0
T_Test "$?" "msgVal 1/3"
# test get_msg_key()
test $(get_msg_key 'titolo:p7m') -eq 0
T_Test "$?" "get_msg_key()"
# Test populate_msg()
unset L
msgVal=()
LANG="es"
msgVal_es[100]="ola ola"
msgVal_es[600]='ola2%s ola2%p1'
populate_msg
test ${#msgKey[@]} -gt 0
T_Test "$?" 'msgKey 2/2' 'when set LANG="es"'
test ${#msgVal[@]} -gt 0
T_Test "$?" 'msgVal 2/3' 'when set LANG="es"'
test "${msgVal[100]}" = "${msgVal_es[100]}" -a "${msgVal[600]}" = "${msgVal_es[600]}"
T_Test "$?" 'msgVal 3/3' 'msgVal[100] when set LANG="es"' 

# test get_lang_message()
LANG="it_IT.UTF-8" LL=$(get_lang_message)
test "$LL" = 'it'
T_Test "$?" "get_lang_message 1/3" "it_IT.UTF-8"
LANG="C" LL=$(get_lang_message)
test "$LL" = 'en'
T_Test "$?" "get_lang_message 2/3" "C"
LANG="" LL=$(get_lang_message)
test "$LL" = 'it'
T_Test "$?" "get_lang_message 3/3" "<null>"

# Test _msg()
key=${msgKey[100]}
msg=$(_msg $key)
test "${msg}" = 'ola ola'
T_Test "$?" "_msg() 1/2" "without params"
key=${msgKey[600]}
msg=$(_msg $key "test1" "test2")
test "${msg}" = 'ola2test1 ola2test2'
T_Test "$?" "_msg() 2/2" "with param 1 and 2"

# Test call_echo()
call_echo "text" "text to display" "title" | grep -q "title"
T_Test "$?" "call_echo() 1/2" "title"
call_echo "text" "text to display" "title" | grep -q 'text to'
T_Test "$?" "call_echo() 2/2" "text"


T_End
