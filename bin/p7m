#! /bin/bash

# ----------------------------------------
# p7m: script for the management of files with digital signature in the CADES format.
# See: https://github.com/eniocarboni/p7m
# Author: Enio Carboni
# ----------------------------------------

# ---------------------------------------
# Main Global variables:
# You can modify these variables but I recommend doing this using the configuration file $CONF_DIR/p7m_config
# ---------------------------------------

# DWL_ORDER: Order to choose for download program
DWL_ORDER="wget curl GET"
# DIALOG_ORDER: Order to choose of x graphic dialog
DIALOG_ORDER="kdialog zenity xmessage"
# OPEN_ORDER: Order to choose for opening program
OPEN_ORDER="xdg-open gvfs-open gnome-open"
# CA_OLD_TIME_SEC: after that second the CA file will be download
CA_OLD_TIME_SEC=1296000
# XML_CERTS: url of cnipa xml certs
#XML_CERTS='https://applicazioni.cnipa.gov.it/TSL/_IT_TSL_signed.xml'
# See https://www.agid.gov.it/it/piattaforme/firma-elettronica-qualificata/certificati
XML_CERTS='https://eidas.agid.gov.it/TL/TSL-IT.xml'
# ROTATE_NUMBER: number of rotations (for same files)
ROTATE_NUMBER=10
# MIMETYPES: path of file mime.types
MIMETYPES=/etc/mime.types
CONF_DIR=${HOME}/.config/p7m
DOWN_RIGHT_ARROW="\u21b3"
# Terminal color
RED='\033[0;31m'
BWhite='\033[1;37m'
BPurple='\033[1;35m'
BRed='\033[1;31m'
NC='\033[0m' # No Color
# Fattura Elettronica PA
# La versione 1.1 non e' piu' presente su www.fatturapa.gov.it quindi uso un mio gist per ora
XSL_V11="fatturapa_v1.1.xsl"
XSL_V11_URL="https://gist.githubusercontent.com/eniocarboni/f9098a08abf03eefe632755aacf7f10b/raw/69f003ca80283f374aabaf42b3c4477941fa2bab/fatturapa_v1.1.xsl"
XSL_V12="fatturapa_v1.2.1.xsl"
XSL_V12_URL="https://www.fatturapa.gov.it/export/documenti/fatturapa/v1.2.1/Foglio_di_stile_fatturaPA_v1.2.1.xsl"
# XSL_OLD_TIME_SEC: after that second the xsl file will be download
XSL_OLD_TIME_SEC=1296000
# ------------------------------------------------------------------------

declare -a msgKey msgVal msgVal_it msgVal_en
declare -a msgKeyTitle msgValTitle_it msgValTitle_en 
declare -a msgKeyError msgValError_it msgValError_en
declare -a msgKeyOpenssl msgValOpenssl_it msgValOpenssl_en
declare -a msgKeyExec msgValExec_it msgValExec_en
declare -a msgKeyDownloadurl msgValDownloadurl_it msgValDownloadurl_en
declare -a msgKeyFile mgsValFile_it msgValFile_en
declare -a msgKeyUsage msgValUsage_it msgValUsage_en
msgKeyTitle=(
"titolo:p7m" "titolo:seleziona:p7m" "titolo:openssl" "titolo:openssl:verify" "titolo:openssl:cert" "titolo:openssl:asn1parse" "titolo:download" "titolo:cert" "titolo:errore" "titolo:attenzione" "titolo:dettagli" "titolo:copyxslfile")
msgValTitle_it=("P7M" "Seleziona un p7m" "Openssl" "Openssl verifica firma" "Openssl Certificato" "Openssl debug" "Download" "Cert" "Errore" "Attenzione" "Dettagli" "copyxslfile")
msgValTitle_en=("P7M" "Select a p7m file" "Openssl" "Openssl verifica firma" "Openssl Certificato" "Openssl debug" "Download" "Cert" "Error" "Warning" "Details" "copyxslfile")

msgKeyError=("errore:file:ext" "errore:file:ext:bad" "errore:file:non_esiste" "errore:file:conf_dir" "errore:fatturael:versione")
msgValError_it=("Bisogna passare un file con estensione .p7m come parametro" "Formato del file p7m non riconosciuto." "Non esiste il file. Controllare meglio" "Impossibile creare la directory .p7m nella tua HOME" "versione '%s' fattura elettronica: non riconosciuta")
msgValError_en=("You must pass a .p7m file as a parameter" "Bad file p7m format." "There is no file. Check better" "Unable to create the .p7m directory in your HOME" "version '%s' fattura elettronica: not recognized")

msgKeyOpenssl=("openssl:estrazione:errore" "openssl:verifica:errore:formato" "openssl:verifica:title:ok" "openssl:verifica:title:non_ok" "openssl:verifica:ok:ok" "openssl:verifica:non_ok:ok" "openssl:verifica:non_ok_scaduto:ok" "openssl:verifica:non_ok_scaduto:non_ok" "openssl:verifica:non_ok:non_ok" "openssl:verifica:errore:continuo" "openssl:verifica:timestamp:mancante" "openssl:cert:errore" "openssl:cert:validita" "openssl:asn1parse:error" "openssl:asn1parse:timestamp" "openssl:estrazione:percorso")
msgValOpenssl_it=(
"estrazione file terminata con errore" 
"Errore nel formato del file" 
"Verifica firme avvenuta con successo" 
"Verifica firme terminata con errore" 
"**Firmatario: %s**\n   Data e ora di firma: %p1\n   Ente: %p2\n   CF: %p3\n   Certificatore: %p4\n   Validità certificato: %p5 - %p6\n" 
"**Firmatario: %s**\n   Data e ora di firma: %p1\n   Ente: %p2\n   CF: %p3\n   Certificatore: %p4\n   ** Certificato non valido: %p5 - %p6\n"
"**Firmatario: %s**\n   Data e ora di firma: %p1\n   Ente: %p2\n   CF: %p3\n   Certificatore: %p4\n   ***Certificato scaduto: %p5 - %p6***\n"
"**Firmatario: %s**\n   *** Errore in data e ora di firma: %p1***\n   Ente: %p2\n   CF: %p3\n   Certificatore: %p4\n   *** Certificato scaduto: %p5 - %p6***\n"
"**Firmatario: %s**\n   *** Errore in data e ora di firma: %p1***\n   Ente: %p2\n   CF: %p3\n   Certificatore: %p4\n   *** Errore nel certificato validità: %p5 - %p6***\n"
"Verifica documento e/o firme errate! Provo comunque ad estrarre il contenuto?"
"Manca il timestamps nel p7m"
"Impossibile estrarre il certificato"
"Validità certificato: %s"
"Impossibile estrarre informazioni dal file"
"Riferimento temporale: %s"
"Estratto il file in "
)
msgValOpenssl_en=(
"File extraction ended with error"
"File format error"
"Signature verified correctly"
"Signature verification failed"
"**Signer: %s**\n   Date and time of signature: %p1\n   Organization: %p2\n   CF: %p3\n   Issuer: %p4\n   Certificate validity: %p5 - %p6\n" 
"**Signer: %s**\n   Date and time of signature: %p1\n   Organization: %p2\n   CF: %p3\n   Issuer: %p4\n   ** Invalid certificate: %p5 - %p6\n"
"**Signer: %s**\n   Date and time of signature: %p1\n   Organization: %p2\n   CF: %p3\n   Issuer: %p4\n   ***Certificate expired: %p5 - %p6***\n"
"**Signer: %s**\n   *** Error in date and time of signature: %p1***\n   Organization: %p2\n   CF: %p3\n   Issuer: %p4\n   *** Certificate expired: %p5 - %p6***\n"
"**Signer: %s**\n   *** Error in date and time of signature: %p1***\n   Organization: %p2\n   CF: %p3\n   Issuer: %p4\n   *** Error in Certificate validity: %p5 - %p6***\n"
"Verification document and/or signatures incorrect! Do I still try to extract the content?"
"Missed timestamps in p7m"
"Unable to extract the certificates"
"Certificate validity: %s"
"Unable to exact any info from this file"
"Timestamps: %s"
"Extract the file in "
)
msgKeyExec=("eseguibile:openssl:non_trovato" "eseguibile:open_file:non_trovato" "eseguibile:download_url:non_trovato")
msgValExec_it=(
"Devi installare 'openssl' prima di poter usare questo programma"
"Non trovo nessuno dei comandi:\n ${OPEN_ORDER}\nNon so come aprire il file estratto"
"Nessun programma di download trovato! Impossibile continuare."
) 
msgValExec_en=(
"You must install openssl first"
"Non trovo nessuno dei comandi:\n ${OPEN_ORDER}\nI don't know how to open the extracted file"
"No download program found! It is not possible to continue."
)

msgKeyDownloadurl=("download_url:ca:ok" "download_url:ca:non_ok" "download_url:ca:mancante" "download_url:ca:attendi" "download_url") 
msgValDownloadurl_it=(
"CA scaricato perfettamente in"
"Impossibile scaricare il CA in questo momento ... riprovare successivamente"
"Manca il CA, scaricarlo con l'opzione -p"
"Inizio scaricamento CA ... attendi un attimo"
"Inizio scaricamento %s ... attendi un attimo"
) 
msgValDownloadurl_en=(
"CA downloaded perfectly into"
"Unable to download the 'CA' at this time ... try again later"
"The CA is missing, download it with the -p option"
"Starting download the CA ... wait, please"
"Starting download %s ... wait, please"
)

msgKeyFile=("file:diritti:scrittura" "file:diritti:scrittura:alternativa" "file:sovrascivere") 
msgValFile_it=(
"Impossibile scrivere in "
"Estratto comunque il file in "
"Sovrascrivere il file "
) 
msgValFile_en=(
"Unable to write in "
"Extract the file in "
"Overwrite the file "
)

msgKeyUsage=("p7m:usage") 
msgValUsage_it=(
"***%s***

Usare:
  **p7m** [-x] [-g] [-h] <file.p7m> # Per estrarre il contenuto
  **p7m** -v [-g] [-h] <file.p7m>   # Per verificare il p7m
  **p7m** -c [-g] [-h] <file.p7m>   # Per i certificati
  **p7m** -d [-g] [-h] <file.p7m>   # Per il debug (esperti)
  **p7m** -p [-h]                   # Per scaricare la nuova CA

  Dove:
    **-h**: visualizza questo messaggio;
    **-x**: estrae il file e non tenta di visualizzarlo;
    **-v**: per verificare il p7m e la validita dei certificati e delle firme;
    **-c**: visualizza i certificati di firma sia come testuali che come certificati binari (in formato PEM);
    **-p**: per forzare lo scaricamento dei nuovi certificati;
    **-d**: utili per il debug del p7m (per esperti);
    **-g**: prova ad utilizzare finestre grafiche invece di scrivere in console.
"
) 
msgValUsage_en=(
"***%s***

Use:
  **p7m** [-x] [-g] [-h] <file.p7m> # To extract content
  **p7m** -v [-g] [-h] <file.p7m>   # To verify p7m
  **p7m** -c [-g] [-h] <file.p7m>   # Certificates
  **p7m** -d [-g] [-h] <file.p7m>   # To debug (expert only)
  **p7m** -p [-h]                   # To download the CA

  Where:
    **-h**: Display this help;
    **-x**: extract the content without display it;
    **-v**: verify p7m, certificates and the signs;
    **-c**: display certificates;
    **-p**: force CA download;
    **-d**: p7m debug (expert only);
    **-g**: try using graphical windows instead of writing in console.
"
)

idx=-1
for i in "${msgKeyTitle[@]}"; do
	idx=$(($idx + 1 ))
	msgKey[$idx]=${msgKeyTitle[$idx]}
	msgVal_it[$idx]=${msgValTitle_it[$id_x]}
	msgVal_en[$idx]=${msgValTitle_en[$id_x]}
done
idx=99
for i in "${msgKeyError[@]}"; do
	idx=$(($idx + 1 ))
	msgKey[$idx]=${msgKeyError[$(($idx - 100))]}
	msgVal_it[$idx]=${msgValError_it[$(($idx - 100))]}
	msgVal_en[$idx]=${msgValError_en[$(($idx - 100))]}

done
idx=199
for i in "${msgKeyOpenssl[@]}"; do
	idx=$(($idx + 1 ))
	msgKey[$idx]=${msgKeyOpenssl[$(($idx - 200))]}
	msgVal_it[$idx]=${msgValOpenssl_it[$(($idx - 200))]}
	msgVal_en[$idx]=${msgValOpenssl_en[$(($idx - 200))]}
done
idx=299
for i in "${msgKeyExec[@]}"; do
	idx=$(($idx + 1 ))
	msgKey[$idx]=${msgKeyExec[$(($idx - 300))]}
	msgVal_it[$idx]=${msgValExec_it[$(($idx - 300))]}
	msgVal_en[$idx]=${msgValExec_en[$(($idx - 300))]}
done
idx=399
for i in "${msgKeyDownloadurl[@]}"; do
	idx=$(($idx + 1 ))
	msgKey[$idx]=${msgKeyDownloadurl[$(($idx - 400))]}
	msgVal_it[$idx]=${msgValDownloadurl_it[$(($idx - 400))]}
	msgVal_en[$idx]=${msgValDownloadurl_en[$(($idx - 400))]}
done
idx=499
for i in "${msgKeyFile[@]}"; do
	idx=$(($idx + 1 ))
	msgKey[$idx]=${msgKeyFile[$(($idx - 500))]}
	msgVal_it[$idx]=${msgValFile_it[$(($idx - 500))]}
	msgVal_en[$idx]=${msgValFile_en[$(($idx - 500))]}
done
idx=599
for i in "${msgKeyUsage[@]}"; do
	idx=$(($idx + 1 ))
	msgKey[$idx]=${msgKeyUsage[$(($idx - 600))]}
	msgVal_it[$idx]=${msgValUsage_it[$(($idx - 600))]}
	msgVal_en[$idx]=${msgValUsage_en[$(($idx - 600))]}
done


# P7MTYPE: 
#   smime: use openssl smime
#   cms  : use new openssl cms
# Inizialized calling getP7mType() function
P7MTYPE=''
# ------------------------------------------------------------------------

# ============================= #
# From here the functions begin #
# ============================= #

# get_msg_key()
# --------------------------
# Description: Return the key of msgKey array based on the value in $1
# Input params: $1 - value in msgKey array
# Environment variables used: msgKey
# Output: index of array msgKey based on the value in $1
# Return value: 0
# --------------------------
get_msg_key() {
	value="$1"
	for i in "${!msgKey[@]}"; do
		if [[ "${msgKey[$i]}" = "${value}" ]]; then
			echo "${i}";
		fi
	done
}


# get_lang_message()
# --------------------------
# Description: Get 2 digit lang based on $LANG environment variable
# Input params: <none>
# Environment variables used: $LANG
# Output: 2 digit lang (default "it") 
# Return value: 0
# --------------------------
get_lang_message() {
	local L
	L=${LANG%.*}
	L=${L%_*}
	if [ "$L" = "C" ]; then 
		L='en'
	elif [ -z "$L" ]; then
		L='it'
	fi
	echo $L
}

populate_msg() {
	local m keys key val
	if [ ${#msgVal[@]} -eq 0 ]; then 
		if [ -z "$L" ];	then 
			L=$(get_lang_message)
		fi
		# we have to popolate it
		# default to lang "it"
		for key in "${!msgVal_it[@]}"; do
			msgVal[$key]=${msgVal_it[$key]}
		done
		m="msgVal_$L"
		eval "keys=\${!$m[@]}"
		for key in $keys; do
			eval "val=\${$m[$key]}"
			msgVal[$key]=$val
		done
	fi
}

# _msg()
# --------------------------
# Description: Display the message with the right language associated with the tag passed as a parameter
# Input params: 
#  $1: Key to obtain the phrase in the right language.
#  $2, ..., $10: Dynamic Parameters to replace some phrases.
# Global variables used: $msgVal
# Output: The phrase in the right language.
# Return value: 0
# --------------------------
_msg() {
	local value=''
	local key
	if [ -z "$1" ]; then
		return 0
	fi
	key=$(get_msg_key "$1")
	value=${msgVal[$key]}
	if [ -n "$2" ]; then
		value=$(echo "$value" | sed "s/\%s/$2/g")
		value=$(echo "$value" | sed "s/\%p1/$3/g")
		value=$(echo "$value" | sed "s/\%p2/$4/g")
		value=$(echo "$value" | sed "s/\%p3/$5/g")
		value=$(echo "$value" | sed "s/\%p4/$6/g")
		value=$(echo "$value" | sed "s/\%p5/$7/g")
		value=$(echo "$value" | sed "s/\%p6/$8/g")
		value=$(echo "$value" | sed "s/\%p7/$9/g")
		value=$(echo "$value" | sed "s/\%p8/$10/g")
	fi
	echo "$value"
}
# rotate_file()
# --------------------------
# Description: Rotate the file passed by parameter add to the name ".1", ".2", ... ".n" where "n" is at the most $ROTATE_NUMBER
# Input params: 
#  $1: The file to rotate the name
# Global variables used: $ROTATE_NUMBER
# External commans used: seq, mv
# Output: <none>
# Return value: the ret value of "mv" command (generally "0")
# --------------------------
rotate_file() {
	local rotate=0
	local r=''
	local rr=''
	if [ -z "$1" -o ! -f "$1" ]; then 
		return
	fi
	rotate=$((${ROTATE_NUMBER} -1))
	for r in `seq ${rotate} -1 1`; do
		rr=$(($r+1))
		if [ -f "$1.$r" ]; then
			mv "$1.$r" "$1.$rr"
		fi
	done
	mv "$1" "$1.1"
}

# find_command()
# --------------------------
# Description: Check if the command passed as a parameter actually exists.
# Input params: 
#  $1: command to verify
# External commans used: which
# Output: Complete command path or nothing if not existing.
# Return value: 0
# --------------------------
find_command() {
	local com=''
	local c=''
	for c in "$@"; do
		if [ `which ${c} 2>/dev/null` ]; then
			com=${c}
			break
		fi
	done
	echo $com
}

# del_oldtmp_file()
# --------------------------
# Description: Delete temporary files created previously
#   Before the cancellation there are security checks:
#   - do not delete the original file;
#   - the final extracted file must not be deleted;
#   - the file must exist;
#   - the file must be of the temporary type created by this script (must match "p7m_").
# Input params: 
#  $1, ..., $n: Names of files to be deleted.
# Global variables used: $p7m_attach, $file
# External commans used: rm
# Output: <none>
# Return value: 0
# --------------------------
del_oldtmp_file() {
	local f=''
	for f in $@; do
		if [ "$f" != "$file" -a "$f" != "${p7m_attach}" -a -e "$f" -a "$f" != "${f/p7m_}" ]; then
			rm -f "$f"
		fi
	done
	return 0
}

# download()
# --------------------------
# Description: Download $1 url and save it as $2
#   For download, either wget or curl or GET is used. The download log is located in ${CONF_DIR}/.dwn.log
# Input params: 
#  $1: url to download
#  $2: Name and path of downloaded url
# Global variables used: $msg, $CONF_DIR, $DWN
# External commans used: touch, wget, curl, GET
# Phrases key used: eseguibile:download_url:non_trovato, titolo:download
# Output: <none>
# Return value: Return value of either wget or curl or GET (0 if ok)
# --------------------------
download() {
	rotate_file "${CONF_DIR}/.dwn.log"
	touch "${CONF_DIR}/.dwn.log"
	if [ -z "${DWN}" ]; then 
		err "$(_msg "eseguibile:download_url:non_trovato")\n[${DWL_ORDER}]" "$(_msg "titolo:download")"
		exit 1
	fi
	if [ ${DWN} = 'wget' ]; then
	        wget --tries=2 -o ${CONF_DIR}/.dwn.log -O "$2" "$1"
	elif [ ${DWN} = 'curl' ]; then
		curl --progress-bar -v -o "$2" --retry 2 "$1" 2>${CONF_DIR}/.dwn.log
	elif [ ${DWN} = 'GET' ]; then
		GET "$1" >"$2"
	fi
	return $?
}

# call_kdialog()
# --------------------------
# Description: Use kdialog to view a message.
#   kdialog can display the text in html so the message is converted by replacing:
#   - spaces with & nbsp;
#   - a sentence enclosed between left and right by 3 '*' with <font color = "red"> ... </font>
#   - a sentence enclosed between left and right by 2 '*' with <b> ... </b>
#   - the end of line with <br>
# Input params: 
#  $1: Type of window: 
#    text      : --textbox if lenght $2 > 40960 characters else --msgbox
#    warn      : --sorry
#    err       : --error
#    err_detail: --detailederror
#    notify    : --passivepopup
#    warn_yesno: --warningyesno
#  $2: text to display
#  $3: title (for --detailederror and --warningyesno is detailed info of $2)
#  $4: title only for --detailederror and --warningyesno
# External commans used: kdialog, sed, mktemp
# Output: kdialog windows
# Return value: kdialog return
# --------------------------
call_kdialog() {
	local t='<html>'$(echo -e  "$2" | sed -e 's/ /\&nbsp;/g' -e 's/\*\*\*\(.*\)\*\*\*/<font color="red">\1<\/font>/g' -e 's/\*\*\(.*\)\*\*/<b>\1<\/b>/g' -e 's/$/<br>/g')'</html>'
	local t2='<html>'$(echo -e  "$2<br><br><i>$3</i>" | sed -e 's/ /\&nbsp;/g' -e 's/\*\*\*\(.*\)\*\*\*/<font color="red">\1<\/font>/g' -e 's/\*\*\(.*\)\*\*/<b>\1<\/b>/g' -e 's/$/<br>/g')'</html>'
	local log_file=''
	if [ $1 = 'text' ]; then
		if [ ${#2} -gt 40960 ]; then
			log_file=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
			echo -e  "$2" >$log_file
			kdialog --title "$3" --textbox "$log_file" --geometry 800x600 2>/dev/null
			rm -f $log_file
		else
			kdialog --title "$3" --msgbox "$t" 2>/dev/null
		fi
	elif [ $1 = 'warn' ]; then
		kdialog --title "$3" --sorry "$t" 2>/dev/null
	elif [ $1 = 'err' ]; then
		kdialog --title "$3" --error "$t" 2>/dev/null
	elif [ $1 = 'err_detail' ]; then
		kdialog --title "$4" --detailederror "$t" "$3" 2>/dev/null
	elif [ $1 = 'notify' ]; then
		kdialog --title "$3" --passivepopup "$1" 5 2>/dev/null
	elif [ $1 = 'warn_yesno' ]; then
		kdialog --title "$4" --warningyesno "$t2" 2>/dev/null
	fi
}
# call_zenity()
# --------------------------
# Description: Use zenity to view a message.
# Input params: 
#  $1: Type of window:
#    text      : --text-info if length $2 >= 150 else --info
#    warn      : --warning
#    err       : --error
#    err_detail: --error
#    notify    : --notification
#    warn_yesno: --question
#  $2: text to display
#  $3: title
#  $4: detailed text to display
# External commans used: zenity 
# Output: zenity windows
# Return value: zenity return
# --------------------------
call_zenity() {
	if [ $1 = 'text' ]; then
		if [ ${#2} -gt 150 ]; then 
			echo -e "$2" | zenity --text-info --width=600 --height=500 --title="$3" 2>/dev/null
		else
			zenity --info --title="$3" --text="$2" 2>/dev/null
		fi
	elif [ $1 = 'warn' ]; then
		zenity --warning --title="$3" --text="$2" 2>/dev/null
	elif [ $1 = 'err' ]; then
		zenity --error --title="$3" --text="$2" 2>/dev/null
	elif [ $1 = 'err_detail' ]; then
		zenity --error --title="$4" --text="$2\n\n$3" 2>/dev/null
	elif [ $1 = 'notify' ]; then
		zenity --notification --title="$3" --text="$2" 2>/dev/null
	elif [ $1 = 'warn_yesno' ]; then
		zenity --question --title="$4" --text="$2\n\n$3" 2>/dev/null
	fi
}
# call_xmessage()
# --------------------------
# Description: Use xmessage to view a message.
# Input params: 
#  $1: Type of window: text, warn, err, err_detail, notify, warn_yesno
#  $2: text to display
#  $3: for err_detail and warn_yesno is detailed info of $2
# External commans used: xmessage
# Output: xmessage windows
# Return value: xmessage return
# --------------------------
call_xmessage() {
	if [ $1 = 'text' ]; then
		echo -e "$2" | xmessage -nearmouse -file - 2>/dev/null
	elif [ $3 = 'warn' ]; then
		echo -e "$2" | xmessage -nearmouse -file - 2>/dev/null
	elif [ $1 = 'err' ]; then
		echo -e "$2" | xmessage -nearmouse -file - 2>/dev/null
	elif [ $1 = 'err_detail' ]; then
		echo -e "$2\n\n$3" | xmessage -nearmouse -file - 2>/dev/null
	elif [ $1 = 'notify' ]; then
		echo -e "$2"
	elif [ $1 = 'warn_yesno' ]; then
		echo -e "$2\n\n$3"
	fi
}
# call_echo()
# --------------------------
# Description: Use echo to view a message.
# Input params: 
#  $1: Type of window: text, warn, warn_yesno
#  $2: text to display
#  $3: title (for  err_detail and warn_yesno is detailed info of $2)
#  $4: detailed info of $2 for err_detail and warn_yesno
# External commans used: sed
# Output: echo message.
# Return value: 0 or 1 if warn_yesno and the answer is different from 's' or 'y'.
# --------------------------
call_echo() {
	# controllo se l'output va nel terminale o in una pipe
	local ret=0
	local t=''
	local answer=''
	if [ -t 1 ]; then
		t=$(echo -e "${BRed}$4${NC}\n$2" | sed -e "s/\*\*\*\(.*\)\*\*\*/\\\033[0;31m\1\\\033[0m/g" -e "s/\*\*\(.*\)\*\*/\\\033[1;37m\1\\\033[0m/g")
		# Title
		if [ -n "$3" ]; then 
			if [ $1 = 'text' ]; then
				echo -e "${BWhite}$3${NC}"
			elif [ $1 = 'warn' ]; then
				echo -e "${BPurple}$3${NC}"
			elif [ $1 = 'warn_yesno' ]; then
				echo -e "${BPurple}$3${NC}"
			else 
				echo -e "${BRed}$3${NC}"
			fi
		fi
		# Text
		if [ $1 = 'warn_yesno' ]; then
			read -s -n 1 -p "$t [s/n] " answer
			answer=$(echo ${answer} | tr '[A-Z]' '[a-z]')
			if [ -z "$answer" ]; then
				answer=" "
			fi
			if [ "$answer" = 's' -o "$answer" = 'y' ]; then
				ret=0
			else
				ret=1
			fi
		else 
			echo -e "$t"
		fi
		echo
	else
		if [ -n "$1" ]; then 
			echo -e "$3"
		fi
		echo -e  "$2"
	fi
	return $ret
}
# display()
# --------------------------
# Description: Display a text message using the right dialog message
# Input params: 
#  $1, ..., $n: parameters like in call_xyz function (see call_kdialog for example) 
# Global variables used: XDIALOG, $out
# Output: the dialog message
# Return value: the return from the dialog message
# --------------------------
display() {
	if [ "${out}" = 'g' -a -n "${XDIALOG}" ]; then
		call_${XDIALOG} "text" "$@"
	else
		call_echo "text" "$@"
	fi
}
# notify()
# --------------------------
# Description: Display a notify message using the right dialog message
# Input params: 
#  $1, ..., $n: parameters like in call_xyz function (see call_kdialog for example)
# Global variables used: XDIALOG, $out
# Output: the dialog message
# Return value: the return from the dialog message
# --------------------------
notify() {
	if [ "${out}" = 'g' -a -n "${XDIALOG}" ]; then
		call_${XDIALOG} "notify" "$@"
	else

		call_echo "text" "$@"
	fi
}
# warn()
# --------------------------
# Description: Display a warn message using the right dialog message
# Input params: 
#  $1, ..., $n: parameters like in call_xyz function (see call_kdialog for example)
# Global variables used: XDIALOG, $out
# Output: the dialog message
# Return value: the return from the dialog message
# --------------------------
warn() {
	if [ "${out}" = 'g' -a -n "${XDIALOG}" ]; then
		call_${XDIALOG} "warn" "$@"
	else
		call_echo "warn" "$@"
	fi
}
# err()
# --------------------------
# Description: Display a err message using the right dialog message
# Input params: 
#  $1, ..., $n: parameters like in call_xyz function (see call_kdialog for example)
# Global variables used: XDIALOG, $out
# Output: the dialog message
# Return value: the return from the dialog message
# --------------------------
err() {
	if [ "${out}" = 'g' -a -n "${XDIALOG}" ]; then
		call_${XDIALOG} "err" "$@"
	else
		call_echo "err" "$@"
	fi
}
# err_detail()
# --------------------------
# Description: Display a err_detail message using the right dialog message
# Input params: 
#  $1, ..., $n: parameters like in call_xyz function (see call_kdialog for example)
# Global variables used: XDIALOG, $out
# Output: the dialog message
# Return value: the return from the dialog message
# --------------------------
err_detail() {
	if [ "${out}" = 'g' -a -n "${XDIALOG}" ]; then
		call_${XDIALOG} "err_detail" "$@"
	else
		call_echo "err" "$1" "$3" "$2"
	fi
}
# warn_yesno()
# --------------------------
# Description: Display a warn_yesno message using the right dialog message
# Input params: 
#  $1, ..., $n: parameters like in call_xyz function (see call_kdialog for example)
# Global variables used: XDIALOG, $out
# Output: the dialog message
# Return value: the return from the dialog message
# --------------------------
warn_yesno() {
	if [ "${out}" = 'g' -a -n "${XDIALOG}" ]; then
		call_${XDIALOG} "warn_yesno" "$@"
	else
		call_echo "warn_yesno" "$1" "$3" "$2"
	fi
}
	

# opensslVerify()
# --------------------------
# Description: start openssl command to verify the p7m file either in smime or cms
# Input params: 
#  $1: p7m file to verify
#  $2: format (DER or PEM). Default to DER
#  $3: no_out (no output like -out /dev/null 2>&1)
# Global variables used: $P7MTYPE, $CONF_DIR
# Output: the output of openssl command used
# Return value: the return from the openssl command
# --------------------------
opensslVerify() {
	local format="DER"
	local noout='';
	if [ -n "$2" ]; then
		format="$2"
	fi
	if [ -n "$3" -a "$3" = "no_out" ]; then
		noout='-out /dev/null 2>/dev/null'
		openssl ${P7MTYPE} -verify ${P7MEXTRAOPT} -CAfile "${CONF_DIR}/ca.pem" -in "$1" -inform "$format" -out /dev/null 2>/dev/null
	else
		openssl ${P7MTYPE} -verify ${P7MEXTRAOPT} -CAfile "${CONF_DIR}/ca.pem" -in "$1" -inform "$format"
	fi
	return $?
}

# opensslTextStruct()
# --------------------------
# Description: Display text info of p7m struct
# Input params: 
#  $1: p7m file to info
# Global variables used: $P7MTYPE
# Output: the output of openssl command used
# Return value: the return from the openssl command
# --------------------------
opensslTextStruct() {
	local ret
	if [ "${P7MTYPE}" = "smime" ]; then
		# smime
		openssl pkcs7 -print -text -inform der -in "$1"
		ret=$?
	else
		# cms
		openssl cms -inform DER -verify -noverify ${P7MEXTRAOPT} -nosigs -cmsout -print -text -in "$1"
		ret=$?
	fi
	return "$ret"
}

# getIssuerTimestamps()
# --------------------------
# Description: Display the serials and timestamps of the signers
# Input params: 
#  $1: p7m file
# Global variables used: $P7MTYPE
# Output: For each signers display the cert's serial in the first line and the timestamp in the second line
#         the timestamp is normalized in your localtime
# Return value: the return from the openssl command
# --------------------------
getIssuerTimestamps() {
	local info=$(opensslTextStruct "$1")
	local ret=$?
	if [ "${P7MTYPE}" = "smime" ]; then
		# smime
		echo "$info" | sed -e 's/GENERALIZEDTIME/UTCTIME/g' | sed -n '/issuer_and_serial:/,/UTCTIME:/p'| grep -E ' serial:|UTCTIME:'| sed -e 's/^ *serial: *//' -e 's/^ *UTCTIME: *//'
	else
		# cms
		echo "$info" | sed -e 's/GENERALIZEDTIME/UTCTIME/g' | sed -n '/issuerAndSerialNumber:/,/UTCTIME:/p' | grep -E ' serialNumber:|UTCTIME:' | sed -e 's/^ *serialNumber: *//' -e 's/^ *UTCTIME: *//'
	fi
	return $ret
}

# getCertsFields()
# --------------------------
# Description: Display the main fields of the certs of the signers
# Input params: 
#  $1: p7m file
# Global variables used: $P7MTYPE
# Output: For each signers display the main cert's fields one for each line:
#         In 1st line display the serialNumber,
#         in 2nd line the issuer,
#         in 3rd line the notBefore date,
#         in 4th line the notAfter date,
#         in 5th line the subject
# Return value: the return from the openssl command
# --------------------------
getCertsFields() {
	local info=$(opensslTextStruct "$1")
	local ret=$?
	# smime and cms output are both ok
	echo "$info" | sed -n '/cert_info:/,/issuerUID:/p'| grep -E ' serialNumber:|issuer:|notBefore:|notAfter:|subject:' | grep -E ' serialNumber:|issuer:|notBefore:|notAfter:|subject:' | sed 's/^ *\(serialNumber:\|issuer:\|notBefore:\|notAfter:\|subject:\) *//'
	return $ret
}

# getTs()
# Description: return the second from origin based on date in $1
# Input params:
#  $1: the date to convert
# Output: The second from origin
# Return value: the return value of date command
# --------------------------
getTs() {
	local ts=$(date --date="$1" "+%s")
	local ret=$?
	echo "$ts"
	return $ret
}

# getCn()
# Description: return the CN from a cert subject field as $1
# Input params:
#  $1: the subject
# Output: The CN
# Return value: 0
# --------------------------
getCn() {
	echo "$1" |sed -e 's/^.*CN=//' -e 's/[\/,].*$//' 2>&1
	return 0
}

# getCf()
# Description: return the CF from a cert subject field as $1
# Input params:
#  $1: the subject
# Output: The CF (codice fiscale)
# Return value: 0
# --------------------------
getCf() {
	echo "$1" | sed -e 's/^.*serialNumber=//' -e 's/[\/,].*$//' -e 's/^.*://' 2>&1
	return 0
}

# getOu()
# Description: return the OU from a cert subject field as $1
# Input params:
#  $1: the subject
# Output: The OU
# Return value: 0
# --------------------------
getOu() {
	local subject=$1
	local ou="non presente"
	if [ "$subject" != "${subject/O=}" ]; then
		ou=$(echo $subject |sed -e 's/^.*O=//' -e 's/[\/,].*$//' -e 's/^.*://' 2>&1)
	fi
	echo "$ou"
	return 0
}

# getnewcert()
# --------------------------
# Description: Download the CA cert file if not exist or if its timestamp is too old
# Input params: <none>
# Global variables used: $CONF_DIR, $CA_OLD_TIME_SEC
# External commans used: date
# Output: as getcert functions
# Return value: as getcert functions
# --------------------------
getnewcert() {
	local sec_old=0
	local sec_now=0
	if [ ! -f ${CONF_DIR}/ca.pem ]; then
	       getcert notify
	else
 		sec_old=$(date -r ${CONF_DIR}/ca.pem +%s)
		sec_now=$(date +%s)
		if [ $(( $sec_now - $sec_old )) -gt ${CA_OLD_TIME_SEC} ]; then
			getcert notify
		fi
	fi
}
# getcert()
# --------------------------
# Description: Download the CA cert file if not exist
# Input params: <none>
# Global variables used: $CONF_DIR, $XML_CERTS
# External commans used: mkdir, sed, grep, openssl, mv, rm, cat
# Phrases key used: errore:file:conf_dir, titolo:cert, download_url:ca:attendi, download_url:ca:ok, download_url:ca:non_ok
# Output: information messages during the download
# Return value: 
#   0 : all ok
#   1 : Unable to create the .p7m directory
#   2 : Unable to download the 'CA' at this time
# --------------------------
getcert() {
  local i
  mkdir -p ${CONF_DIR}
  if [ ! -d "${CONF_DIR}" ]; then
	  err "$(_msg 'errore:file:conf_dir')" "$(_msg 'titolo:cert')"
	return 1
  fi
  notify "$(_msg 'download_url:ca:attendi')" "$(_msg 'titolo:cert')"
  rotate_file ${CONF_DIR}/cnipa_signed.xml
  download "${XML_CERTS}" "${CONF_DIR}/cnipa_signed.xml"
  # cnipa_signed.xml now is only one line long so we add e return value before start tag and after tag (X509Certificate)
  for i in `sed -e 's/<X509Certificate/\n<X509Certificate/g' -e s'#</X509Certificate>#</X509Certificate>\n#g' ${CONF_DIR}/cnipa_signed.xml | grep '<X509Certificate'`; do
	  echo -e "-----BEGIN CERTIFICATE-----"
	  echo $i| sed -e 's/<\/*X509Certificate>//g'| openssl base64 -d -A| openssl base64
	  echo -e "-----END CERTIFICATE-----"
  done >${CONF_DIR}/ca.pem.partial
if [ -s ${CONF_DIR}/ca.pem.partial ]; then
	rotate_file "${CONF_DIR}/ca.pem"
	mv "${CONF_DIR}/ca.pem.partial" "${CONF_DIR}/ca.pem"
	if [ "$1" ]; then
		notify "$(_msg 'download_url:ca:ok') ${CONF_DIR}/ca.pem" "$(_msg 'titolo:cert')"
	else
		display "$(_msg 'download_url:ca:ok') ${CONF_DIR}/ca.pem" "$(_msg 'titolo:cert')"
	fi
else
	rm -f ${CONF_DIR}/ca.pem.partial
	if [ "$1" ]; then
		notify "$(_msg 'download_url:ca:non_ok')\n\n[logs]:\n `cat "${CONF_DIR}/.dwn.log"`" "$(_msg 'titolo:cert')"
	else
		err_detail "$(_msg 'download_url:ca:non_ok')" "'[logs]:\n `cat "${CONF_DIR}/.dwn.log"`'" "$(_msg 'titolo:cert')"
	fi
	return 2
fi
return 0
}

# from_base64_to_p7m()
# --------------------------
# Description: Converts a p7m file encoded in base64 to standard p7m
#    check if reverse decoded file as same md5 (base64 false positive)
# Input params: 
#  $1: path of the file to convert
# External commans used: mktemp, openssl
# Output: path of the converted file
# Return value: 0
# --------------------------
from_base64_to_p7m() {
	local file_pem=$1
	local newp7m=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
	# check if in base64 format to convert in original p7m
	# base64 one line:
	# - cat "${file_pem} # cat file as is;
	# - sed '$ s/$/\n/'  # Add '\n' (new line) only on last line 
	#                    # (some base64 don'have '\n' on last line and "read line" don't read last chars after last '\n' on the b64 file)
	# - sed 's/\r//g'    # remove all '\r' (carriage ret) or ^M 
	# - while read line; do echo -n "$line"; done
	#                    # read all line an output their without '\n' (all in one long line)
	# - openssl md5 -r   # output the md5
	read -d ' ' md5orig <<< $(cat "${file_pem}" | sed '$ s/$/\n/' | sed 's/\r//g'|  while read line; do echo -n "$line"; done | openssl md5 -r)
	openssl base64 -A -d -in "$file_pem" -out "$newp7m" 2>&1
	read -d ' ' md5after <<< $(openssl base64 -A -in "$newp7m" -out - | sed '$ s/$/\n/' | sed 's/\r//g'|  while read line; do echo -n "$line"; done | openssl md5 -r)
	if [ -s "$newp7m" -a "${md5orig}" = "${md5after}" ]; then
		echo "$newp7m"
	else
		# base64 multiline
		openssl base64 -d -in "$file_pem" -out "$newp7m" 2>&1
		read -d ' ' md5after <<< $(openssl base64 -in "$newp7m" -out - | sed '$ s/$/\n/' | sed 's/\r//g'|  while read line; do echo -n "$line"; done | openssl md5 -r)
		if [ -s "$newp7m" -a "${md5orig}" = "${md5after}" ]; then
			echo "$newp7m"
		else
			del_oldtmp_file "$newp7m"
			echo "$file_pem"
		fi
	fi
	return 0
}


# is_p7m()
# --------------------------
# Description: Check if the p7m file passed as a parameter is a true p7m
# Input params: 
#  $1: path of the file to check
# External commans used: openssl
# Output: 
#   0: all check is ok
#   1: $1 is not a p7m file
# Return value: 
#   0: all check is ok
#   1: $1 is not a p7m file
# --------------------------
is_p7m() {
	local file_test=$1
	local real_file_test=$(from_base64_to_p7m "$file_test")
	# check if in pem format
	openssl pkcs7 -print_certs -text -noout -inform pem -in "$real_file_test" >/dev/null 2>&1
	if [ $? == 0 ]; then
		echo "0"
		return 0
	fi
	# check if in der format
	openssl pkcs7 -print_certs -text -noout -inform der -in "$real_file_test" >/dev/null 2>&1
	if [ $? == 0 ]; then
		echo "0"
		return 0
	fi
	# check if CMS (and no SMIME) in pem format
	openssl cms -inform PEM -verify -noverify ${P7MEXTRAOPT} -nosigs -cmsout -noout -in "$real_file_test" >/dev/null 2>&1
	if [ $? == 0 ]; then
		echo "0"
		return 0
	fi
	# check if CMS (and no SMIME) in der format
	openssl cms -inform DER -verify -noverify ${P7MEXTRAOPT} -nosigs -cmsout -noout -in "$real_file_test" >/dev/null 2>&1
	if [ $? == 0 ]; then
		echo "0"
		return 0
	fi
	if [ "$real_file_test" != "$file_test" ]; then
		del_oldtmp_file "$real_file_test"
	fi
	echo "1"
	return 1
}

# getP7mType()
# --------------------------
# Description: Check if the p7m file passed as a parameter id smime or cms p7m type
# Input params: 
#  $1: path of the file to check
# External commans used: openssl
# Output: 
#   smime: smime file
#   cms: cms file
# Return value: 
#   0: smime or cms file
#   1: $1 is not a p7m file
# --------------------------
getP7mType() {
	local file_test=$1
	local real_file_test=$(from_base64_to_p7m "$file_test")
	# check if CMS (and no SMIME) in pem format
	openssl cms -inform PEM -verify -noverify ${P7MEXTRAOPT} -nosigs -cmsout -noout -in "$real_file_test" >/dev/null 2>&1
	if [ $? == 0 ]; then
		echo "cms"
		return 0
	fi
	# check if CMS (and no SMIME) in der format
	openssl cms -inform DER -verify -noverify ${P7MEXTRAOPT} -nosigs -cmsout -noout -in "$real_file_test" >/dev/null 2>&1
	if [ $? == 0 ]; then
		echo "cms"
		return 0
	fi
	if [ "$real_file_test" != "$file_test" ]; then
		del_oldtmp_file "$real_file_test"
	fi
	# check if in pem format
	openssl pkcs7 -print_certs -text -noout -inform pem -in "$real_file_test" >/dev/null 2>&1
	if [ $? == 0 ]; then
		echo "smime"
		return 0
	fi
	# check if in der format
	openssl pkcs7 -print_certs -text -noout -inform der -in "$real_file_test" >/dev/null 2>&1
	if [ $? == 0 ]; then
		echo "smime"
		return 0
	fi
	return 1
}

# from_pem_to_der()
# --------------------------
# Description: Converts from PEM to DER format
# Input params: 
#  $1: path of the file to convert
# External commans used: mktemp, openssl
# Output: path of the converted file
# Return value: 0
# --------------------------
from_pem_to_der() {
	local file_pem=$1
	local der=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
	# check if in pem format to convert in der
	if [ "$P7MTYPE" = 'smime' ]; then
		# smime
		openssl pkcs7 -outform der -in "$file_pem" -out "$der" >/dev/null 2>&1
	else
		# cms
		openssl cms -inform PEM -verify -noverify ${P7MEXTRAOPT} -nosigs -cmsout -outform DER -out "$der" -in "$file_pem" >/dev/null 2>&1
	fi
	if [ $? != 0 ]; then
		del_oldtmp_file "$der"
		der="$file_pem"
	fi
	echo "$der"
	return 0
}

# verify()
# --------------------------
# Description: Check the correctness of the p7m file including the signatures
# Input params: 
#  $1: path of the file to verify
# Global variables used: $CONF_DIR
# External commans used: openssl, sed, grep, date
# Phrases key used: download_url:ca:mancante, openssl:verifica:errore:formato, titolo:openssl:verify, openssl:verifica:timestamp:mancante,
#   openssl:verifica:ok:ok, openssl:verifica:non_ok_scaduto:ok, openssl:verifica:non_ok_scaduto:non_ok, openssl:verifica:non_ok:ok,
#   openssl:verifica:non_ok:non_ok
# Output: Verification status messages
# Return value: 
#  0: p7m file is ok
#  1: The CA is missing, download it first
#  2: File format error
#  8: missed timestamps in p7m
# 10: Signature verification failed (certificate expired) and timestamps failed
# 11: Signature verification failed and timestamps failed, outside the validity of the certificate
# --------------------------
verify() {
	local i idx id_utc OLD_IFS R err
	local utc utctime verify_res now sn timestamp_readable
	local timestamp issuer notbefore notafter subject cn cf ou 
	local issuer_cn notbefore_ts notafter_ts 
	declare -a timestamps_array
	declare -a certs_orig_array
	declare -a utctime_array
	declare -a verify_msg
	if [ ! -f "${CONF_DIR}/ca.pem" -o ! -s "${CONF_DIR}/ca.pem" ]; then
		warn "$(_msg 'download_url:ca:mancante')"
		return 1
	fi
	err=$(opensslVerify "$1" "DER" "no_out")
	R=$?
	if [ $R = "2" ]; then
		if [ -z "$2" ]; then
			err_detail "$(_msg 'openssl:verifica:errore:formato')" "$err" "$(_msg 'titolo:openssl:verify')"
		else 
			echo "$(_msg 'openssl:verifica:errore:formato');$err"
		fi
		return $R
	fi
	# in timestamps_array ci sono:
        #	negli elementi 0,2,4, ecc. (elementi pari) il serial del certificato di chi ha firmato
	#	negli elementi 1,3,5, ecc. (elementi dispari) l'UTCTIME in formato normalizzato con il locale impostato
	# in certs_orig_array ci sono:
	#	negli elementi 0,5,10, ecc. (elementi 0 + 5*n) il serial del certificato
	#	negli elementi 1,6,11, ecc. (elementi 1 + 5*n) l'issue
	#	negli elementi 2,7,12, ecc. (elementi 2 + 5*n) il notBefore (data di partenza del certificato)
	#	negli elementi 3,8,13, ecc. (elementi 3 + 5*n) il notAfter (data di scadenza del certificato)
	#	negli elementi 4,9,14, ecc. (elementi 4 + 5*n) il subject (Nome, cognome, CF, ecc)
	OLD_IFS=$IFS
	IFS=$'\n' 
	timestamps_array=($(getIssuerTimestamps "$1"))
	certs_orig_array=($(getCertsFields "$1"))
	IFS=$OLD_IFS
	idx=-1
	for (( i=0; i<${#timestamps_array[*]}; i=$(($i+2)) )); do
		idx=$(($idx + 1 ))
		#serial_timestamps[${timestamps_array[$i]}]=$i
		utctime=${timestamps_array[$(($i+1))]}
		utctime=$(getTs "${utctime}")
		#utctime_hash[$utctime]=${timestamps_array[$i]}
		utctime_array[$idx]=$utctime
	done

	# verify_res: indica se 0 che le firme e i loro timestamp sono corretti; se >0 c'e' un errore
	verify_res=0
	now=$(date "+%s")
	if [ ${#timestamps_array[*]} -eq 0 ]; then 
		verify_msg[0]="$(_msg 'openssl:verifica:timestamp:mancante')"
		verify_res=8
	else
		idx=-1
		for utc in $(echo "${utctime_array[@]}" | sed -e 's/ /\n/g' | sort -n); do
			id_utc=''
			for i in "${!utctime_array[@]}"; do
				if [ "${utctime_array[$i]}" = "$utc" ]; then
					id_utc=$i
				fi
			done
			sn=${timestamps_array[$(($id_utc * 2))]}
			idx=$(($idx + 1 ))
			timestamp_readable=${timestamps_array[$(( $id_utc * 2 +1 ))]}
			timestamp=$(getTs "${timestamp_readable}")
			issuer=${certs_orig_array[$(( $id_utc * 5 + 1 ))]}
			notbefore=${certs_orig_array[$(( $id_utc * 5 + 2 ))]}
			notafter=${certs_orig_array[$(( $id_utc * 5 + 3 ))]}
			subject=${certs_orig_array[$(( $id_utc * 5 + 4 ))]}
			cn=$(getCn "$subject")
			cf=$(getCf "$subject")
			ou=$(getOu "$subject")
			issuer_cn=$(getCn "$issuer")
			notbefore_ts=$(getTs "${notbefore}")
			notafter_ts=$(getTs "${notafter}")

			verify_res=0
			if [ $R = "0" ]; then
				verify_msg[$idx]="$(_msg 'openssl:verifica:ok:ok' "${cn}" "${timestamp_readable}" "${ou}" "${cf}" "${issuer_cn}" "${notbefore}" "${notafter}")"
			
			elif [ "${now}" -lt "${notbefore_ts}" -o "${now}" -gt "${notafter_ts}" ]; then
				if [ "${timestamp}" -ge "${notbefore_ts}" -a "${timestamp}" -le "${notafter_ts}" ]; then
					verify_msg[$idx]="$(_msg 'openssl:verifica:non_ok_scaduto:ok' "${cn}" "${timestamp_readable}" "${ou}" "${cf}" "${issuer_cn}" "${notbefore}" "${notafter}")"
				else
					verify_msg[$idx]="$(_msg 'openssl:verifica:non_ok_scaduto:non_ok' "${cn}" "${timestamp_readable}" "${ou}" "${cf}" "${issuer_cn}" "${notbefore}" "${notafter}")"
					verify_res=10
				fi
			else
				if [ "${timestamp}" -ge "${notbefore_ts}" -a "${timestamp}" -le "${notafter_ts}" ]; then
					verify_msg[$idx]="$(_msg 'openssl:verifica:non_ok:ok' "${cn}" "${timestamp_readable}" "${ou}" "${cf}" "${issuer_cn}" "${notbefore}" "${notafter}")"
				else
					verify_msg[$idx]="$(_msg 'openssl:verifica:non_ok:non_ok' "${cn}" "${timestamp_readable}" "${ou}" "${cf}" "${issuer_cn}" "${notbefore}" "${notafter}")"
					verify_res=11
				fi
			fi

		done
	fi
	echo "${verify_msg[*]}"
	return $verify_res
}

# cert()
# --------------------------
# Description: Extract certificates from a pkcs7 file
# Input params: 
#  $1: path of pkcs7 file
# Global variables used: $CONF_DIR
# External commans used: openssl
# Phrases key used: download_url:ca:mancante
# Output: the certs
# Return value: openssl pkcs7 return valus
# --------------------------
cert() {
	local str R
	if [ ! -f "${CONF_DIR}/ca.pem" -o ! -s "${CONF_DIR}/ca.pem" ]; then
		echo "$(_msg 'download_url:ca:mancante')"
		return 1
	fi
	if [ "${P7MTYPE}" = "smime" ]; then
		# smime
		str=`openssl pkcs7 -print_certs -text -inform der -in "$1" 2>&1`
		R=$?
	else
		# cms
		local certsfile=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
		openssl cms -verify ${P7MEXTRAOPT} -inform DER -CAfile "${CONF_DIR}/ca.pem" -certsout ${certsfile} -out /dev/null -in "$1" -out /dev/null 2>/dev/null
		str=$(openssl crl2pkcs7 -nocrl -certfile ${certsfile} | openssl pkcs7 -print_certs -text)
		R=$?
		del_oldtmp_file "${certsfile}"
	fi
	echo "$str"
	return $R
}

# debug_pkcs7()
# --------------------------
# Description: Debug with asn1parse a pkcs7 file
# Input params: 
#  $1: path of the file to debug
# Global variables used: $P7MTYPE
# External commans used: openssl
# Output: the asn1 debug output
# Return value: openssl asn1parse or cms fields
# --------------------------
debug_pkcs7() {
	local str R
	if [ "${P7MTYPE}" = "smime" ]; then
		# smime
		str=$(openssl asn1parse -inform der -in "$1" 2>&1)
		R=$?
	else
		# cms
		str=$(openssl cms -inform DER -verify -noverify ${P7MEXTRAOPT} -nosigs -cmsout -print -text -in "$1" 2>&1)
		R=$?
	fi
	echo "$str"
	return $R
}

# getxslenvs()
# --------------------------
# Description: Set the environment xsl_file and xsl_url based on version in $1
# Input params: 
#  $1: the version of xsl file
# Global variables used: $xsl_file, $xsl_url, $XSL_V12, $XSL_V12_URL, $XSL_V11, $XSL_V11_URL
# Output: <none>
# Return value: 0
# --------------------------
getxslenvs() {
	local version=$1
	unset xsl_file xsl_url
	if [ "$version" = "fpr12" ]; then
		xsl_file=${XSL_V12}
		xsl_url=${XSL_V12_URL}
	elif [ "$version" = "1.1" ]; then
		xsl_file=${XSL_V11}
		xsl_url=${XSL_V11_URL}
	fi
}

# copyxslfile()
# --------------------------
# Description: copy xsl file from $CONF_DIR to $2 dir
#              xsl file is based on $1 version of xml (inside fattura elettronica)
#              the xsl will be downloaded if it does not exist or if it is too old based on $CA_OLD_TIME_SEC
# Input params: 
#  $1: version of xsl
#  $2: dir where copy xsl file from $CONF_DIR 
# Global variables used: $CONF_DIR, $xsl_file, $xsl_file, $xsl_url
# External commans used: cp
# Phrases key used: download_url, titolo:download
# Output: <none>
# Return value: 0
# --------------------------
copyxslfile() {
	local version=$1
	local dir=$2
	local xsl url sec_old sec_now
	getxslenvs $version
	if [ -n "$xsl_file" ]; then
		if [ ! -f "${CONF_DIR}/$xsl_file" -o ! -s "${CONF_DIR}/$xsl_file" ]; then
			notify "$(_msg 'download_url' $xsl_file)" "$(_msg 'titolo:download')"
			download "$xsl_url" "${CONF_DIR}/$xsl_file"
		fi
		if [ -f "${CONF_DIR}/$xsl_file" -a -s "${CONF_DIR}/$xsl_file" ]; then
			cp "${CONF_DIR}/$xsl_file" "$dir/$xsl_file"
		fi
	else
		notify "$(_msg 'errore:fatturael:versione' $version)" "$(_msg 'titolo:copyxslfile')"
	fi

}

# p7mplugin()
# --------------------------
# Description: check if $1 is a fattura elettronica file and copy the right xsl
# Input params: 
#  $1: path of fattura elettronica file
# Global variables used: $IS_FATTURA, $xsl_file
# External commans used: file, grep, sed, dirname
# Output: <none>
# Return value: 0
#   IS_FATTURA=1 if $1 is a fattura elettronica
# --------------------------
p7mplugin() {
	local file=$1
	local testif_fatturaelettronica=$(grep -E '<FatturaElettronicaHeader' "$file")
	local t=`file -b --mime-type "$file"`
	if [ -n "$t" -a "$t" = 'application/xml' ]; then
		t='text/xml'
	fi
	if [ -n "$testif_fatturaelettronica" ]; then
		t='text/xml'
	fi
	local version
	local tag_FatturaElettronica=$(grep -E '<(.*:)?FatturaElettronica ' "$file")
	local testif_xmlstylesheet=$(grep -E 'xml-stylesheet' $file)
	if [ "$t" = 'text/xml' -a -n "$testif_fatturaelettronica" ]; then
		# check if fattura elettronica
		# found version and make all lowercase
		version=$(echo $tag_FatturaElettronica | sed -e 's/^.*versione="\([^"]*\).*$/\1/' | tr '[A-Z]' '[a-z]')
		getxslenvs $version
		if [ -z "$testif_xmlstylesheet" ]; then
			sed -i 's/\(<\([[:alnum:]]*:\)*FatturaElettronica \)/<\?xml-stylesheet type="text\/xsl" href="'$xsl_file'"\?>\1/' "$file"
		fi
		copyxslfile "$version" "$(dirname $file)"
		IS_FATTURA=1

	fi
}

# getP7mFile()
# --------------------------
# Description: Open dialog box (if possible) to select a p7m file if not yet present
# Input params: 
#  $1: file p7m if already present
# Global variables used: $out, $XDIALOG, $PWD
# External commans used: kdialog, zenity
# Phrases key used: titolo:seleziona:p7m
# Output: the p7m selected or $1
# Return value: 0
# --------------------------
getP7mFile() {
	local file=''
	if [ -n "$1" -o "$out" != 'g' ]; then
		file="$1"
	elif [ "$XDIALOG" = 'kdialog' ]; then
		file=$(kdialog --getopenfilename --title="$(_msg 'titolo:seleziona:p7m')" $PWD 'P7M file (*.p7m)')
	elif [ "$XDIALOG" = 'zenity' ]; then
		file=$(zenity --file-selection --title="$(_msg 'titolo:seleziona:p7m')" --file-filter='*.p7m')
	fi
	echo "$file"
	return 0
}

# getHelp()
# --------------------------
# Description: Display help usage message for p7m
# Input params: 
#  $1: Message to prepend to the help usage message
# Phrases key used: p7m:usage
# Output: Display 'p7m:usage' phrase
# Return value: 0
# --------------------------
getHelp() {
	display "$(_msg 'p7m:usage' "$1")"	
}

# inizialize()
# --------------------------
# Description: Inizialize the enviroenment
# Input params: <none>
# Phrases key used: 
# Environment variables used: CONF_DIR, L, DWN, OPEN, XDIALOG
# Output: <none>
# Return value: 0
# --------------------------
inizialize() {
	if [ -n "${CONF_DIR}" -a ! -d "${CONF_DIR}" ]; then
		mkdir -p "${CONF_DIR}"
	fi
	if [ -f "${CONF_DIR}/p7m_config" ]; then
		# in questo file puoi modificare i messaggi ed aggiungere lingue, i vari programmi da utilizzare ed altro
		source "${CONF_DIR}/p7m_config"
	fi
	L=$(get_lang_message)
	populate_msg
	DWN=$(find_command ${DWL_ORDER})
	OPEN=$(find_command ${OPEN_ORDER})
	XDIALOG=$(find_command ${DIALOG_ORDER})
	return 0
}

### START MAIN ###

# Global variable declaration
declare L DWN OPEN XDIALOG

# no_attr_verify: if yes insert option "-no_attr_verify" on "openssl cms" command so "Do not verify signed attribute signatures"
# see man openssl-cms
no_attr_verify="yes"
while getopts ":pvcdxghte" arg; do
  case $arg in
      p)
	 op='p'
      ;;
      v)
          op='v'
      ;;
      c)
          op='c'
      ;;
      d)
	  op='d'
      ;;
      x)
	  op='x'
      ;;
      g)
	  out='g'  
      ;;
      t)
	  op='test'
      ;;
      e)
          no_attr_verify=0
      ;;
      h)
	  op='h'
      ;;
  esac
done
if [ "$op" != 'test' ]; then
	inizialize
	if [ "$op" = 'h' ]; then
		getHelp " "
		exit 0
	fi
	if [ "$op" = 'p' ]; then
		getcert
		R=$?
		exit $R
	fi
	shift $(($OPTIND - 1))
	file=$@
	file=$(getP7mFile "$file")
	if [ -z "$file" ]; then
		getHelp "$(_msg 'errore:file:ext')"
	  exit 1
	fi
	if [ ! -f "$file" ]; then
		getHelp "$(_msg 'errore:file:non_esiste') ($file)"
	  exit 2
	fi
	orig_path=$(dirname "$file")
	name_file=$(echo ${file} | tr '[ A-Z]' '[_a-z]')
	b1=$(basename "$name_file")
	b2=$(basename "$name_file" .p7m)
	b2_orig=$(basename "$file" .p7m)
	if [ "$b1" = "$b2" ]; then
		getHelp "$(_msg 'errore:file:ext')"
	  exit 3
	fi
	if [ ! `which openssl 2>/dev/null` ]; then
		err "$(_msg 'eseguibile:openssl:non_trovato')" "$(_msg 'it:titolo:openssl')"
	  exit 4
	fi
	
	declare -a out_continue_array
	declare -a unlink_files
	checkfile="$file"
	# p7m_attach: [Variabile  globale] Nome del file estratta dal .p7m
	p7m_attach=""
	level=-1
	op_continue=1
	op_continue_ret=0
	op_title=''
	if [ $(is_p7m "$checkfile") -ne 0 ]; then 
		op_continue=0
		out_continue_array[0]=$(_msg 'errore:file:ext:bad')
	fi
	while [ $op_continue_ret -eq 0 -a $(is_p7m "$checkfile") -eq 0 ]; do
		level=$(( $level + 1 ))
		P7MTYPE=$(getP7mType "$checkfile")
		P7MEXTRAOPT=''
		if [ $P7MTYPE == 'cms' -a $no_attr_verify == 'yes' ]; then
			P7MEXTRAOPT="-no_attr_verify"
		fi
		# Se necessario converto da base64
		myfile_uu=$(from_base64_to_p7m "$checkfile")
		unlink_files+=("$myfile_uu")
		# Se necessario converto il file da PEM a DER
		myfile=$(from_pem_to_der "$myfile_uu")
		unlink_files+=("$myfile")
		
		if [ $level -eq 0 ]; then 
			getnewcert
		fi
		if [ "$op" = 'v' ]; then
			op_continue=0
			out_continue_array[$level]=$(verify "$myfile")
			op_continue_ret=$?
			if [ $op_continue_ret -eq 0 ]; then
				if [ -z "$op_title" ]; then
					op_title="openssl:verifica:title:ok"
				fi
			else
				op_title="openssl:verifica:title:non_ok"
			fi
		elif [ "$op" = 'c' ]; then
			op_continue=0
			out_continue_array[$level]=$(cert "$myfile")
			op_continue_ret=$?
			op_title="titolo:openssl:cert"
		elif [ "$op" = 'd' ]; then
			op_continue=0
			out_continue_array[$level]=$(debug_pkcs7 "$myfile")
			op_continue_ret=$?
			op_title="titolo:openssl:asn1parse"
		elif [ -f "${CONF_DIR}/ca.pem" -a -s "${CONF_DIR}/ca.pem" ]; then
			errv=$(verify "$myfile")
			codev=$?
			if [ $codev != "0" ]; then
				warn_yesno "$(_msg 'openssl:verifica:errore:continuo')" "" "$(_msg 'titolo:openssl')"
				if [ $? != 0 ]; then
					del_oldtmp_file "${unlink_files[*]}"
					exit 5
				fi
			fi
		fi
		checkfile=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX")
		err=`openssl ${P7MTYPE} -verify -noverify ${P7MEXTRAOPT} -in "$myfile" -inform DER -out "$checkfile" 2>&1`
		code=$?
		unlink_files+=("$checkfile")
		if [ $code != "0" ]; then
			warn_yesno "$(_msg 'openssl:verifica:errore:continuo')" "$err" "$(_msg 'titolo:openssl')"
			if [ $? != 0 ]; then
				del_oldtmp_file "${unlink_files[*]}"
				exit 5
			fi
		fi
	done
	if [ $op_continue -eq 0 ]; then
		declare -a out_msg
		indent=''
		for (( i=$(( ${#out_continue_array[*]} -1 )); i>=0; i=$(($i-1)) )); do
			level=$(( ${#out_continue_array[*]} -1 - $i ))
			if [ $level -gt 0 ]; then 
				indent="$indent    "
				out_msg[$level]=$(echo -e "\n${DOWN_RIGHT_ARROW} ** livello $level **\n\n${out_continue_array[$i]}" | sed "s/^/$indent/g")"\n"
			elif [ ${#out_continue_array[*]} -gt 1 ]; then
				out_msg[$level]=$(echo "\n ** livello $level **\n\n${out_continue_array[$i]}")
			else
				out_msg[$level]=$(echo "\n${out_continue_array[$i]}")
	
			fi
		done
		display "${out_msg[*]}" "$(_msg ${op_title})"
		del_oldtmp_file "${unlink_files[*]}"
		exit $op_continue_ret;
	fi
	if [ "$checkfile" = "$file" ]; then
		exit 2
	fi
	newfile=$checkfile
	t=`file -b --mime-type "$newfile"`
	if [ "$t" = 'text/xml' ]; then
		t='text/xml|application/xml';
	fi
	# test bad text/plain when it is Italian Fattura elettronica whiout xml header
	if [ "$t" = 'text/plain' ]; then
		grep -q 'FatturaElettronica .*http://ivaservizi.agenziaentrate.gov.it/docs/xsd.*versione=' "$newfile"
		test1=$?
		grep -q '<FatturaElettronicaHeader>' "$newfile"
		test2=$?
		grep -q '<FatturaElettronicaBody>' "$newfile"
		test3=$?
		if [ $test1 = "0" -a $test2 = "0" -a $test3 = "0" ]; then
			t='text/xml|application/xml';
		fi
	fi
	p7m_attach=${newfile}
	nf="${b2}"
	if [ -n "$t" -a -f "${MIMETYPES}" ]; then
		read -a exts <<<$(grep -E "^($t)\s" "${MIMETYPES}")
		if [ -n "${exts[1]}" ]; then
			b3=$(basename "$b2" ".${exts[1]}")
			nf="${b3}.${exts[1]}"
			b2_orig=$(basename "$b2_orig" ".${exts[1]}")
			b2_orig="$b2_orig.${exts[1]}"
			nf=$(echo ${nf} | tr '[ A-Z]' '[_a-z]')
			p7m_attach=$(mktemp --tmpdir "p7m_tmp.XXXXXXXXXX-${nf}")
			mv "${newfile}" "${p7m_attach}"
		fi
	fi
	# Cancellazione file temporanei
	del_oldtmp_file "${unlink_files[*]}"
	IS_FATTURA=""
	p7mplugin "${p7m_attach}"
	if [ "$op" == 'x' ]; then
		if [ -e "${orig_path}/${b2_orig}" ]; then
			warn_yesno "$(_msg 'file:sovrascivere') ${orig_path}/${b2_orig}" "" "$(_msg 'titolo:p7m')"
			if [ $? != 0 ]; then
				exit 2
			fi
		fi
		err=$( mv "${p7m_attach}" "${orig_path}/${b2_orig}" )
		if [ $? != "0" ]; then
			err "$(_msg 'file:diritti:scrittura') ${orig_path}\n$(_msg 'file:diritti:scrittura:alternativa') ${p7m_attach}"
		else
			notify "$(_msg 'openssl:estrazione:percorso') '${orig_path}/${b2_orig}'\n[tipo: $t]"
		fi
	elif [ -n "${OPEN}" ]; then
		# display "$(_msg 'eseguibile:open_file:non_trovato') ${p7m_attach}"
		${OPEN} "${p7m_attach}"
		exit 0
	elif [ -t 1 -a -n "$IS_FATTURA" ]; then
		more "${p7m_attach}"
	else 
		display "$(_msg 'eseguibile:open_file:non_trovato')  '${p7m_attach}'\n[tipo: $t]"
		exit 0
	fi
fi

# ########################################################################
#      Copyright (c) 2018 Enio Carboni - Italy
#
#      This file is part of p7m.
#
#    p7m is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    p7m is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with p7m.  If not, see <http://www.gnu.org/licenses/>.
# ########################################################################
