#! /bin/bash
# Test certs function

T_dir=$(dirname $(realpath $0))
source ${T_dir}/../lib/p7mtestlib.sh
T_descr="Certs function"
T_TOT=7

T_Start
source ${T_dir}/../../bin/p7m -t
inizialize
TEST_SERVER="github.com"
# Get fake p7m: is only a pem converted in pkcs so neither data nor signed part is present
tmp_pem=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
tmp_pem_pkcs=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
openssl s_client -servername ${TEST_SERVER} -connect ${TEST_SERVER}:443 -showcerts </dev/null 2>/dev/null >${tmp_pem}
ret=$?
if [ $ret -eq 0 ]; then
  openssl crl2pkcs7 -nocrl -certfile "${tmp_pem}" -outform DER -out "${tmp_pem_pkcs}"
fi
# Test opensslTextStruct()
P7MTYPE="smime"
if [ ! -f "${tmp_pem_pkcs}" -o ! -s "${tmp_pem_pkcs}" ]; then
  T_Skip "opensslTextStruct() smime - Network error"
  T_Skip "opensslTextStruct() cms - Network error"
else
  opensslTextStruct "${tmp_pem_pkcs}" | grep cert_info: >/dev/null
  T_Test "$?" "opensslTextStruct() smime"
  P7MTYPE="cms"
  opensslTextStruct "${tmp_pem_pkcs}" | grep cert_info: >/dev/null
  T_Test "$?" "opensslTextStruct() cms"
fi
# Test getCertsFields()
if [ ! -f "${tmp_pem_pkcs}" -o ! -s "${tmp_pem_pkcs}" ]; then
  T_Skip "getCertsFields() - Network error"
else
  P7MTYPE="smime"
  l=$(getCertsFields "${tmp_pem_pkcs}" | wc -l)
  mod=$(( $l % 5 ))
  T_Test "$mod" "getCertsFields(): must return 5 field for each serial"
fi

# Test getTs()
if [ ! -f "${tmp_pem_pkcs}" -o ! -s "${tmp_pem_pkcs}" ]; then
  T_Skip "getCertsFields() - Network error"
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

rm -f "${tmp_pem_pkcs}" "${tmp_pem}"

T_End
