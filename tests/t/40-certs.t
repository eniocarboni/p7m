#! /bin/bash
# Test p7m function

T_dir=$(dirname $(realpath $0))
source ${T_dir}/../lib/p7mtestlib.sh
T_descr="P7M function"
T_TOT=22

T_Start
source ${T_dir}/../../bin/p7m -t
inizialize
TEST_SERVER="github.com"
TEST_P7M_FILE="p7m_test_der.p7m"
FAKE_P7M=0
ROTATE_NUMBER=2
NO_CA=0
CONF_DIR=$(mktemp -d --tmpdir "p7m_tmp.XXXXXXXXXX")
tmp_pem=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
sample_der_p7m=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
sample_pem_p7m=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
if [ -s ${T_dir}/../test_files/${TEST_P7M_FILE} ]; then
  cp ${T_dir}/../test_files/${TEST_P7M_FILE} "${sample_der_p7m}"
elif [ -s ${T_dir}/../test_files/private_${TEST_P7M_FILE} ]; then
  cp ${T_dir}/../test_files/private_${TEST_P7M_FILE} "${sample_der_p7m}"
elif [ "$P7M_TEST_SKIP_NET" != "1" ]; then
  # Get fake p7m: is only a pem converted in pkcs so neither data nor signed part is present
  FAKE_P7M=1
  openssl s_client -servername ${TEST_SERVER} -connect ${TEST_SERVER}:443 -showcerts </dev/null 2>/dev/null >${tmp_pem}
  ret=$?
  if [ $ret -eq 0 ]; then
    openssl crl2pkcs7 -nocrl -certfile "${tmp_pem}" -outform DER -out "${sample_der_p7m}"
  fi
fi
if [ -s "${sample_der_p7m}" ]; then
  openssl pkcs7 -inform der -outform pem -in "${sample_der_p7m}" -out "${sample_pem_p7m}" >/dev/null 2>&1
fi
ERR_SKIP_NET="see P7M_TEST_SKIP_NET global var"
ERR_NET="Network error"
if [ $FAKE_P7M -eq 1 ]; then
  ERR=$ERR_NET
else 
  ERR=$ERR_SKIP_NET
fi
# Test opensslTextStruct()
P7MTYPE="smime"
if [ ! -s "${sample_der_p7m}" ] ; then
  T_Skip "opensslTextStruct() smime - $ERR"
  T_Skip "opensslTextStruct() cms   - $ERR"
else
  opensslTextStruct "${sample_der_p7m}" | grep cert_info: >/dev/null
  T_Test "$?" "opensslTextStruct() 1/2" "smime"
  P7MTYPE="cms"
  opensslTextStruct "${sample_der_p7m}" | grep cert_info: >/dev/null
  T_Test "$?" "opensslTextStruct() 2/2" "cms"
fi

# Test getIssuerTimestamps()
if [ $FAKE_P7M = "1" ]; then
  T_Skip "getIssuerTimestamps() because of fake p7m file used (no file 'p7m_test_der.p7m' in tests/test_files/)"
elif [ ! -s "${sample_der_p7m}" ] ; then
  T_Skip "getIssuerTimestamps() $ERR_SKIP_NET"
else
  P7MTYPE="smime"
  l=$(getIssuerTimestamps "${sample_der_p7m}" | wc -l)
  mod=$(( $l % 2 ))
  T_Test "$mod" "getIssuerTimestamps()" "- must return 2 fields for each serial (serial and utctime)"
fi

# Test getCertsFields()
if [ ! -s "${sample_der_p7m}" ] ; then
  T_Skip "getCertsFields() - $ERR"
else
  P7MTYPE="smime"
  l=$(getCertsFields "${sample_der_p7m}" | wc -l)
  mod=$(( $l % 5 ))
  T_Test "$mod" "getCertsFields()" ": must return 5 fields for each serial"
fi

# Test getTs()
if [ ! -s "${sample_der_p7m}" ]; then
  T_Skip "getCertsFields() - $ERR"
else
  t_date_test="May 18 00:00:05 2018 GMT"
  t_date=$(date --date="$t_date_test" "+%s")
  t_date2=$(getTs "$t_date_test")
  test "$t_date" = "$t_date2"
  T_Test "$?" "getTs()"
fi

# Test getCn()
t_exp="Test Service P7M CA"
t_str="issuer: C=IT, O=TestOu Inc, OU=www.test.it, CN=$t_exp"
t_found=$(getCn "$t_str")
test "$t_exp" = "$t_found"
T_Test "$?" "getCn()"

# Test getCf()
t_exp="CGNNMO69E25K471H"
t_str="Subject: C=IT, CN=NOME COGNOME, SN=NOME, GN=COGNOME/serialNumber=${t_exp}/dnQualifier=34526069, O=TestOu Inc"
t_found=$(getCf "$t_str")
test "$t_exp" = "$t_found"
T_Test "$?" "getCf()"

# Test getOu()
t_exp="TestOu Inc"
t_str="Subject: C=IT, CN=NOME COGNOME, SN=NOME, GN=COGNOME/serialNumber=CGNNMO69E25K471H/dnQualifier=34526069, O=${t_exp}/organizationIdentifier=yt535-0"
t_found=$(getOu "$t_str")
test "$t_exp" = "$t_found"
T_Test "$?" "getOu()"

# Test getcert()
if [ "$P7M_TEST_SKIP_NET" = "1" ]; then
  T_Skip "getcert() see P7M_TEST_SKIP_NET"
  NO_CA=1
else
  getcert >/dev/null 2>&1
  ret=$?
  if [ $ret -eq 2 ]; then
    T_Skip "getcert()" "- Network error"
    NO_CA=1
  else
    test $ret -eq 0 -a -s ${CONF_DIR}/ca.pem
    T_Test "$?" "getcert()"
  fi
  if [ ! -s ${CONF_DIR}/ca.pem ]; then
    NO_CA=1
  fi
fi
# Test getnewcert()
if [ "$P7M_TEST_SKIP_NET" = "1" ]; then
  T_Skip "getnewcert() 1/2 see P7M_TEST_SKIP_NET"
  T_Skip "getnewcert() 2/2 see P7M_TEST_SKIP_NET"
elif [ $NO_CA = "1" ]; then
  T_Skip "getnewcert() 1/2 because of getcert() test problems"
  T_Skip "getnewcert() 2/2 because of getcert() test problems"
else
  getnewcert >/dev/null 2>&1
  test ! -f ${CONF_DIR}/ca.pem.1
  T_Test "$?" "getnewcert() 1/2" "- CA_OLD_TIME_SEC problem 1"
  OLD_CA_OLD_TIME_SEC=${CA_OLD_TIME_SEC}
  CA_OLD_TIME_SEC=3
  sleep 4
  getnewcert >/dev/null 2>&1
  test -f ${CONF_DIR}/ca.pem.1
  T_Test "$?" "getnewcert() 2/2" "- CA_OLD_TIME_SEC problem 2"
fi

# Test opensslVerify()
if [ $FAKE_P7M = "1" ]; then
  T_Skip "opensslVerify() 1/2 because of fake p7m file used (no file 'p7m_test_der.p7m' in tests/test_files/)"
  T_Skip "opensslVerify() 1/2 because of fake p7m file used (no file 'p7m_test_der.p7m' in tests/test_files/)"
elif [ $NO_CA = "1" ]; then
  T_Skip "opensslVerify() 1/2 because of getcert() test problems"
  T_Skip "opensslVerify() 2/2 because of getcert() test problems"
elif [ ! -s "${sample_der_p7m}" ] ; then
  T_Skip "opensslVerify() 1/2 - $ERR"
  T_Skip "opensslVerify() 2/2 - $ERR"
else 
  # test without p7m file
  opensslVerify "" "DER" "no_out"
  test "$?" -ne 0
  T_Test "$?" "opensslVerify() 1/2" "without p7m file as params"
  opensslVerify "${sample_der_p7m}" "DER" "no_out"
  T_Test "$?" "opensslVerify() 2/2"
fi

# Test from_base64_to_p7m()
base64=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
# char "^" is not a valid base64 char
t_str=$(printf "%0.s^" {1..1000})
# base64 multiline
echo $t_str | openssl base64 -out $base64
r_base64=$(from_base64_to_p7m "$base64")
r_str=$(<$r_base64)
test "$t_str" = "$r_str"
T_Test "$?" "from_base64_to_p7m() 1/3" "base64 multiline"
# base64 single line
echo $t_str | openssl base64 -A -out $base64
r_base64_2=$(from_base64_to_p7m "$base64")
r_str=$(<$r_base64_2)
test "$t_str" = "$r_str"
T_Test "$?" "from_base64_to_p7m() 2/3" "base64 single line"
# file not in base64
echo $t_str >$base64
r_base64_3=$(from_base64_to_p7m "$base64")
test "$base64" = "$r_base64_3"
T_Test "$?" "from_base64_to_p7m() 3/3" "not base64 file"
rm -f $r_base64 $r_base64_2 $r_base64_3 $base64

# Test is_p7m()
if [ ! -s "${sample_der_p7m}" ] ; then
  T_Skip "is_p7m() 1/2 - $ERR"
  T_Skip "is_p7m() 2/2- $ERR"
else
  is_p7m "${sample_der_p7m}" >/dev/null 2>&1
  T_Test "$?" "is_p7m() 1/2" "true p7m file"
  fake_p7m=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
  printf "%0.s^" {1..1000} >$fake_p7m
  is_p7m "${fake_p7m}" >/dev/null 2>&1
  test "$?" -ne 0
  T_Test "$?" "is_p7m() 2/2" "false p7m file"
  rm -f fake_p7m
fi

# Test getP7mType()
if [ ! -s "${sample_der_p7m}" ] ; then
  T_Skip "getP7mType() 1/2 - $ERR"
  T_Skip "getP7mType() 2/2 - $ERR"
else
  t_str=$(getP7mType "${sample_der_p7m}")
  test "$?" -eq 0 -a $t_str = "smime"
  T_Test "$?" "getP7mType() 1/2" "true smime p7m file"
  fake_p7m=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
  printf "%0.s^" {1..1000} >$fake_p7m
  t_str=$(getP7mType "${fake_p7m}")
  test "$?" -ne 0
  T_Test "$?" "getP7mType() 2/2" "fake smime p7m file"
  rm -f fake_p7m
fi

# Test from_pem_to_der()
if [ ! -s "${sample_pem_p7m}" ] ; then
  T_Skip "from_pem_to_der() 1/2 - $ERR"
  T_Skip "from_pem_to_der() 2/2 - $ERR"
else
  P7MTYPE="smime"
  t_str=$(from_pem_to_der "${sample_pem_p7m}")
  test "$t_str" != "${sample_pem_p7m}" -a -s "$t_str"
  T_Test "$?" "from_pem_to_der() 1/2" "true pem p7m file"
  fake_p7m=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
  printf "%0.s^" {1..1000} >$fake_p7m
  t_str2=$(from_pem_to_der "${fake_p7m}")
  test "$t_str2" = "${fake_p7m}"
  T_Test "$?" "from_pem_to_der() 2/2" "fake pem p7m file"
  rm -f $fake_p7m $t_str $t_str2
fi

rm -f "${sample_der_p7m}" "${tmp_pem}" "${sample_pem_p7m}"
rm -f ${CONF_DIR}/ca.pem ${CONF_DIR}/ca.pem.? ${CONF_DIR}/ca.pem.partial ${CONF_DIR}/cnipa_signed.xml ${CONF_DIR}/cnipa_signed.xml.? ${CONF_DIR}/.dwn.log ${CONF_DIR}/.dwn.log.?
rmdir ${CONF_DIR}

T_End
