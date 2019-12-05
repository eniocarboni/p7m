#! /bin/bash
# Test Lang messages

T_dir=$(dirname $(realpath $0))
source ${T_dir}/../lib/p7mtestlib.sh
T_descr="File management"
T_TOT=9

T_Start
source ${T_dir}/../../bin/p7m -t
inizialize
# Test rotate_file()
ROTATE_NUMBER=2
tmp_dir=$(mktemp -d --tmpdir "p7m_tmp.XXXXXXXXXX")
touch ${tmp_dir}/test_rotate
rotate_file "${tmp_dir}/test_rotate"
test ! -f "${tmp_dir}/test_rotate" -a -f "${tmp_dir}/test_rotate.1"
T_Test "$?" "rotate_file() 1/3 (ROTATE_NUMBER=$ROTATE_NUMBER)"
touch ${tmp_dir}/test_rotate
rotate_file "${tmp_dir}/test_rotate"
test ! -f "${tmp_dir}/test_rotate" -a -f "${tmp_dir}/test_rotate.1" -a -f "${tmp_dir}/test_rotate.2"
T_Test "$?" "rotate_file() 2/3 (ROTATE_NUMBER=$ROTATE_NUMBER)"
rotate_file "${tmp_dir}/test_rotate"
test ! -f "${tmp_dir}/test_rotate" -a -f "${tmp_dir}/test_rotate.1" -a -f "${tmp_dir}/test_rotate.2" -a ! -f "${tmp_dir}/test_rotate.3"
T_Test "$?" "rotate_file() 3/3 (ROTATE_NUMBER=$ROTATE_NUMBER)"
rm -f "${tmp_dir}/test_rotate.3" "${tmp_dir}/test_rotate.2" "${tmp_dir}/test_rotate.1" "${tmp_dir}/test_rotate"
rmdir ${tmp_dir}

# Test find_command()
find_command "command_err1" "command_err2" "bash" "command_err3" | grep -q bash
T_Test "$?" "find_command() bash - several parameters"
find_command "bash" | grep -q bash
T_Test "$?" "find_command() bash - single parameter"

# Test del_oldtmp_file()
f1_1=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
f1_2=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
f2_1=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
f2_2=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
f3=$(mktemp --tmpdir "p7m-ops_tmp.XXXXXXXXXX")
file=$f1_1
p7m_attach=$f2_1
del_oldtmp_file "$f1_1" "$f1_2"
test -f "$f1_1" -a ! -f "$f1_2"
T_Test "$?" "del_oldtmp_file() 2 file and first in \$file global var"
del_oldtmp_file "$f2_1" "$f2_2"
test -f $f2_1 -a ! -f "$f2_2"
T_Test "$?" "del_oldtmp_file() 2 file and first in \$p7m_attach global var"
del_oldtmp_file "$f3"
test -f "$f3"
T_Test "$?" "del_oldtmp_file() template not p7m_"
rm -f "$f1_1" "$f1_2" "$f2_1" "$f2_2" "$f3"

# Test download()
CONF_DIR=$(mktemp -d --tmpdir "p7m_tmp.XXXXXXXXXX")
download "https://raw.githubusercontent.com/eniocarboni/p7m/master/VERSION" "$CONF_DIR/VERSION"
r="$?"
if [ ${DWN} = 'wget' -a "$r" -eq 4 ]; then
  T_Skip "download() VERSION: Network error"
elif [ ${DWN} = 'curl' -a "$r" -eq 6 ]; then
  T_Skip "download() VERSION: Network error"
elif [ ${DWN} = 'GET' -a "$r" -eq 1 ]; then
  T_Skip "download() VERSION: Network error"
else
  test "$r" -eq 0 -a -f "$CONF_DIR/VERSION"
  T_Test "$?" "download() VERSION file from p7m project on GitHub"
fi
rm -f "$CONF_DIR/VERSION" "$CONF_DIR/.dwn.log"
rmdir "$CONF_DIR" 
T_End
