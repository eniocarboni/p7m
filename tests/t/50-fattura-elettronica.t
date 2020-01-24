#! /bin/bash
# Test Lang messages

T_dir=$(dirname $(realpath $0))
source ${T_dir}/../lib/p7mtestlib.sh
T_descr="Fatture elettroniche"
T_TOT=6

T_Start
source ${T_dir}/../../bin/p7m -t
inizialize
# test getxslenvs()
getxslenvs "fpr12"
test "${xsl_file}" = "${XSL_V12}" -a "${xsl_url}" = "${XSL_V12_URL}"
T_Test "$?" "versione fpr12" ""
getxslenvs "1.1"
test "${xsl_file}" = "${XSL_V11}" -a "${xsl_url}" = "${XSL_V11_URL}"
T_Test "$?" "versione 1.1" ""
getxslenvs "not_valid"
test -z "${xsl_file}" -a -z "${xsl_url}"
T_Test "$?" "versione inesistente" ""

# test copyxslfile()
CONF_DIR=$(mktemp -d --tmpdir "p7m_tmp.XXXXXXXXXX")
output_dir=$(mktemp -d --tmpdir "p7m_tmp.XXXXXXXXXX")
copyxslfile "fpr12" "$output_dir" >/dev/null 2>&1
if [ ! -f "${CONF_DIR}/$xsl_file" -o ! -s "${CONF_DIR}/$xsl_file" ]; then
  T_Skip "versione fpr12: download error"
else
  test -f "${output_dir}/$xsl_file"
  T_Test "$?" "versione fpr12" ""
fi
rm -f "${output_dir}/$xsl_file"
copyxslfile "1.1" "$output_dir" >/dev/null 2>&1
if [ ! -f "${CONF_DIR}/$xsl_file" -o ! -s "${CONF_DIR}/$xsl_file" ]; then
  T_Skip "versione 1.1: download error"
else
  test -f "${output_dir}/$xsl_file"
  T_Test "$?" "versione 1.1" ""
fi
rm -f "${output_dir}/$xsl_file"
copyxslfile "not_valid" "$output_dir" >/dev/null 2>&1
test ! -f "${output_dir}/$xsl_file"
T_Test "$?" "versione inesistente" ""
rm -rf "${output_dir}"
rm -rf "${CONF_DIR}"
T_End

