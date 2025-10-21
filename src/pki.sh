#!/bin/bash

# Name          : Simple PKI
# Description   : PKI script
# Author        : Manegold, Martin
# Version       : 1.0

# enable output to command line (1 = enable)
PKI_SCRIPT_OUTPUT=${PKI_SCRIPT_OUTPUT:-0}

# setting system dependant return values
/bin/true
TMP_TRUE=$?

/bin/false
TMP_FALSE=$?

# setting output colours
TMP_OUTPUT_COLOR_RED="\033[31m"
TMP_OUTPUT_COLOR_GREEN="\033[32m"
TMP_OUTPUT_COLOR_YELLOW="\033[33m"
TMP_OUTPUT_COLOR_RESET="\033[0m"
TMP_OUTPUT_CHECK="✓"
TMP_OUTPUT_CROSS="✗"
TMP_OUTPUT_INFO="o"

# initialize echo
CMD_ECHO="/bin/echo"

# initialize log
TMP_LOG_PATH="/tmp/pki.log"
if [ -f "${TMP_LOG_PATH}" ] && [ ! -O "${TMP_LOG_PATH}" ] ; then
    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [The log file '${TMP_LOG_PATH}' is not owned by the current user. If the script was executed as another user before, please delete the log manually.]${TMP_OUTPUT_COLOR_RESET}"
    exit ${TMP_FALSE} 
fi

# setting command binaries
CMD_AWK="/usr/bin/awk"
CMD_WHEREIS="/usr/bin/whereis"
CMD_CAT=$( ${CMD_WHEREIS} cat | ${CMD_AWK} '{ print $2 }' )
CMD_CAT=${CMD_CAT:-/usr/bin/cat}
CMD_DATE=$( ${CMD_WHEREIS} date | ${CMD_AWK} '{ print $2 }' )
CMD_DATE=${CMD_DATE:-/usr/bin/date}
CMD_DD=$( ${CMD_WHEREIS} dd | ${CMD_AWK} '{ print $2 }' )
CMD_DD=${CMD_DD:-/usr/bin/dd}
CMD_DIRNAME=$( ${CMD_WHEREIS} dirname | ${CMD_AWK} '{ print $2 }' )
CMD_DIRNAME=${CMD_DIRNAME:-/usr/bin/dirname}
CMD_ENV=$( ${CMD_WHEREIS} env | ${CMD_AWK} '{ print $2 }' )
CMD_ENV=${CMD_ENV:-/usr/bin/env}
CMD_GREP=$( ${CMD_WHEREIS} grep | ${CMD_AWK} '{ print $2 }' )
CMD_GREP=${CMD_GREP:-/usr/bin/grep}
CMD_MKDIR=$( ${CMD_WHEREIS} mkdir | ${CMD_AWK} '{ print $2 }' )
CMD_MKDIR=${CMD_MKDIR:-/usr/bin/mkdir}
CMD_OPENSSL=$( ${CMD_WHEREIS} openssl | ${CMD_AWK} '{ print $2 }' )
CMD_OPENSSL=${CMD_OPENSSL:-/usr/bin/openssl}
CMD_RM=$( ${CMD_WHEREIS} rm | ${CMD_AWK} '{ print $2 }' )
CMD_RM=${CMD_RM:-/usr/bin/rm}
CMD_SED=$( ${CMD_WHEREIS} sed | ${CMD_AWK} '{ print $2 }' )
CMD_SED=${CMD_SED:-/usr/bin/sed}
CMD_SEQ=$( ${CMD_WHEREIS} seq | ${CMD_AWK} '{ print $2 }' )
CMD_SEQ=${CMD_SEQ:-/usr/bin/seq}
CMD_TAIL=$( ${CMD_WHEREIS} tail | ${CMD_AWK} '{ print $2 }' )
CMD_TAIL=${CMD_TAIL:-/usr/bin/tail}
CMD_TEE=$( ${CMD_WHEREIS} tee | ${CMD_AWK} '{ print $2 }' )
CMD_TEE=${CMD_TEE:-/usr/bin/tee}
CMD_TOUCH=$( ${CMD_WHEREIS} touch | ${CMD_AWK} '{ print $2 }' )
CMD_TOUCH=${CMD_TOUCH:-/usr/bin/touch}
CMD_UNSET=$( ${CMD_WHEREIS} unset | ${CMD_AWK} '{ print $2 }' )
CMD_UNSET=${CMD_ENV:-/usr/bin/unset}
CMD_WC=$( ${CMD_WHEREIS} wc | ${CMD_AWK} '{ print $2 }' )
CMD_WC=${CMD_WC:-/usr/bin/wc}
CMD_WHOAMI=$( ${CMD_WHEREIS} whoami | ${CMD_AWK} '{ print $2 }' )
CMD_WHOAMI=${CMD_WHOAMI:-/usr/bin/whoami}
CMD_XARGS=$( ${CMD_WHEREIS} xargs | ${CMD_AWK} '{ print $2 }' )
CMD_XARGS=${CMD_XARGS:-/usr/bin/xargs}

for TMP in "${CMD_ECHO}" "${CMD_AWK}" "${CMD_WHEREIS}" "${CMD_CAT}" "${CMD_DATE}" "${CMD_DD}" "${CMD_DIRNAME}" "${CMD_DIRNAME}" "${CMD_ENV}" "${CMD_GREP}" "${CMD_MKDIR}" "${CMD_OPENSSL}" "${CMD_RM}" "${CMD_SED}" "${CMD_SEQ}" "${CMD_TAIL}" "${CMD_TEE}" "${CMD_TOUCH}" "${CMD_UNSET}" "${CMD_WC}" "${CMD_WHOAMI}" "${CMD_XARGS}" ; do
    if [ "${TMP}x" == "x" ] || [ ! -f "${TMP}" ] ; then
        TMP_NAME=(${!TMP@})
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The bash variable '${TMP_NAME}' with value '${TMP}' does not reference to a valid command binary path or is empty.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
done

TMP_USER=$( ${CMD_WHOAMI} )

function f_log_verify() {
    TMP_LOG_SIZE=$( ${CMD_DU} -ms "${TMP_LOG_PATH}" 2>/dev/null | ${CMD_AWK} '{ print $ 1 }' )
    if [ $? -eq ${TMP_TRUE} ] && [ "${TMP_LOG_SIZE}x" != "x" ] && [ ${TMP_LOG_SIZE} -gt 50 ] ; then
        ${CMD_ECHO} "" > "${TMP_LOG_PATH}"
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The log file '"${TMP_LOG_PATH}"' exceeded the maximum size of 50 MegaByte - emptying it.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
    fi
}

function f_parameter_set() {
    if [ "${1}x" != "x" ] ; then
        TMP_PARAM_POSITION_END=$( ${CMD_AWK} -F ':::' '{ print NF }' <<< "${1}" )
        for i in $( ${CMD_SEQ} 1 ${TMP_PARAM_POSITION_END} ) ; do
            TMP_PARAM_ENTRY=$( ${CMD_AWK} -v num=${i} -F ':::' '{ print $num }' <<< "${1}" )
            TMP_PARAM_ENTRY_KEY=$( ${CMD_AWK} -F '=' '{ print $1 }' <<< "${TMP_PARAM_ENTRY}" )
            TMP_PARAM_ENTRY_VALUE=$( ${CMD_AWK} -F '=' '{ print $2 }' <<< "${TMP_PARAM_ENTRY}" )
            f_parameter_verify "${TMP_PARAM_ENTRY_KEY}" "${TMP_PARAM_ENTRY_VALUE}"
            export "${TMP_PARAM_ENTRY}"
        done 
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [Could not extract the variables and values from the passed bash parameters '${1}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
}

function f_parameter_verify() {
    if [ "${1}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [An empty paramater was passed. Every parameter must consist of an entry and a value divided by '=' and separated to other parameters by ':::'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE} 
    fi
    
    if [ "${2}x" == "x" ] && [ "${1}" != "PKI_KEY_INPUT_PASSWORD" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [An empty value to parameter '${1}' was passed. Every parameter must consist of an entry and a value divided by '=' and separated to other parameters by ':::'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE} 
    fi
    
    case "${1}" in
        "PKI_KEY_OUTPUT_FILE")
            TMP_KEY_OUTPUT_PATH=$( ${CMD_DIRNAME} "${2}" )
            if [ ! -d "${TMP_KEY_OUTPUT_PATH}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed private key output path '${TMP_KEY_OUTPUT_PATH}' in variable 'PKI_KEY_OUTPUT_FILE' can not be found on the current system. Please ensure that the parent folder exists.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            
            if [ ! -w "${TMP_KEY_OUTPUT_PATH}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed private key output path '${TMP_KEY_OUTPUT_PATH}' in variable 'PKI_KEY_OUTPUT_FILE' is not writable for the executing user. Please ensure that the user '${TMP_USER}' has write permission on folder '${TMP_KEY_OUTPUT_PATH}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            
            if [ -f "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed private key output file '${2}' in variable 'PKI_KEY_OUTPUT_FILE' already exists. Overriding files is not supported.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            ;;
        "PKI_KEY_ALGORITHM")
            PKI_OPENSSL_KEY_ALGORITHM=""
            case "${2,,}" in
                "ec")
                    PKI_OPENSSL_KEY_ALGORITHM="ec"
                    ;;
                "rsa")
                    PKI_OPENSSL_KEY_ALGORITHM="rsa"
                    ;;
                "ed25519")
                    PKI_OPENSSL_KEY_ALGORITHM="ed25519"
                    ;;
                *)
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The private key encryption algorithm '${2}' in variable '${1}' is not supported.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                    exit ${TMP_FALSE}
                    ;;
            esac
            ;;
        "PKI_KEY_ENCRYPTION")
            PKI_OPENSSL_KEY_OPTION1=""
            PKI_OPENSSL_KEY_OPTION2=""
            case "${2,,}" in
                "prime256v1")
                    PKI_OPENSSL_KEY_OPTION1="ec_param_enc:named_curve"
                    PKI_OPENSSL_KEY_OPTION2="ec_paramgen_curve:P-256"
                    ;;
                "prime384v1")
                    PKI_OPENSSL_KEY_OPTION1="ec_param_enc:named_curve"
                    PKI_OPENSSL_KEY_OPTION2="ec_paramgen_curve:P-384"
                    ;;
                "prime521v1")
                    PKI_OPENSSL_KEY_OPTION1="ec_param_enc:named_curve"
                    PKI_OPENSSL_KEY_OPTION2="ec_paramgen_curve:P-521"
                    ;;
                "rsa3072")
                    PKI_OPENSSL_KEY_OPTION1="rsa_keygen_bits:3072"
                    ;;
                "rsa4096")
                    PKI_OPENSSL_KEY_OPTION1="rsa_keygen_bits:4096"
                    ;;
                "rsa8192")
                    PKI_OPENSSL_KEY_OPTION1="rsa_keygen_bits:8192"
                    ;;
                *)
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The private key encryption type '${2}' in variable '${1}' is not supported.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                    exit ${TMP_FALSE}
                    ;;
            esac
            ;;
        "PKI_CA_OUTPUT_PATH")
            if [ ! -d "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CA output path '${2}' in variable 'PKI_CA_OUTPUT_PATH' can not be found on the current system. Please ensure that the folder exists.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            
            if [ ! -w "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed private key output path '${2}' in variable 'PKI_KEY_OUTPUT_FILE' is not writable for the executing user. Please ensure that the user '${TMP_USER}' has write permission on folder '${PKI_CA_OUTPUT_PATH}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            ;;
        "PKI_CA_NAME")
            if [[ ! "${2}" =~ ^[a-Z0-9]{4,32}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CA name '${2}' in variable 'PKI_CA_NAME' must only consist of 4-32 alphabetical or numerical characters.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CA_ROOT")
            if [[ ! "${2}" =~ ^[0-1]{1,1}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CA root boolean '${2}' in variable 'PKI_CA_ROOT' must only consist of exactly one numerical character between 0-1 (0 = intermediate CA | 1 = root CA).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CA_PATHLENGTH")
            if [[ ! "${2}" =~ ^[0-9]{1,3}$ ]] && [ ${2} -ge 0 ] && [ ${2} -lt 256 ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CA path length '${2}' in variable 'PKI_CA_PATHLENGTH' must only consist of a number between 0 and 256.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CA_BASE_URI")
            if [[ ! "${2}" =~ ^http(|s): ]] ; then 
                ${CMD_ECHO} -e "${TMP_OUTPUcertificateT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CA base URI '${2}' in variable 'PKI_CA_BASE_URI' does not to be a valid URI. Please check it as it is used for certificate and CRL publishing default in the basic configuration file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CA_POLICY")
            if [[ ! "${2}" =~ ^[0-9\.]{3,256}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CA policy '${2}' in variable 'PKI_CA_POLICY' must consist of a numerical value, separated by dots, a minimum of 3 characters and a maximum of 256 characters.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CA_CERT_POLICY")
            if [[ ! "${2}" =~ ^[0-9.]{3,256}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CA cert policy '${2}' in variable 'PKI_CA_CERT_POLICY' must consist of a numerical value, separated by dots, a minimum of 3 characters and a maximum of 256 characters.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_KEY_INPUT_FILE")
            if ( [ ! -f "${2}" ] && [ ! -L "${2}" ] ) || [ ! -r "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed key file '${2}' in variable 'PKI_KEY_INPUT_FILE' must be an existent and by the current user readable regular file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            
            TMP_CHECK_KEY_RESULT=${TMP_TRUE}
            
            # check for a valid RSA / EC key
            TMP_CHECK_KEY=$( ${CMD_OPENSSL} rsa -check -in "${2}" -passin pass: 2>&1 | ${CMD_GREP} --ignore-case "bad\ decrypt" 2>/dev/null )
            if [ $? -eq ${TMP_FALSE} ] && [ "${TMP_CHECK_KEY}x" == "x" ] ; then
                TMP_CHECK_KEY_RESULT=${TMP_FALSE}
            fi
            
            TMP_CHECK_KEY=$( ${CMD_OPENSSL} ec -check -in "${2}" -passin pass: 2>&1 | ${CMD_GREP} --ignore-case "bad\ decrypt" 2>/dev/null )
            if [ $? -eq ${TMP_FALSE} ] && [ "${TMP_CHECK_KEY}x" == "x" ] ; then
                TMP_CHECK_KEY_RESULT=${TMP_FALSE}
            fi
            
            if [ ${TMP_CHECK_KEY_RESULT} -eq ${TMP_FALSE} ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed key file '${2}' in variable 'PKI_KEY_INPUT_FILE' does not seem to be a valid RSA or EC key.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_REQ_HASH")
            if [[ ! "${2}" =~ ^(sha256|sha384|sha512|sha512-256|sha3-256|sha3-384|sha3-512)$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request hash algorithm '${2}' in variable 'PKI_REQ_HASH' can not be used. Please use one of the following: 'sha256' /'sha384' / 'sha512' / 'sha512-256' / 'sha3-256' / 'sha3-384' / 'sha3-512'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_REQ_COUNTRY")
            if [[ ! "${2}" =~ ^[A-Z]{2,2}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request country code '${2}' in variable 'PKI_REQ_COUNTRY' must consist of 2 capital letters.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_REQ_STATE")
            if [[ ! "${2}" =~ ^[a-Z]{2,32}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request state field '${2}' in variable 'PKI_REQ_STATE' must consist of 2 up to 32 letters.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_REQ_LOCATION")
            if [[ ! "${2}" =~ ^[a-Z]{2,32}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request location field '${2}' in variable 'PKI_REQ_LOCATION' must consist of 2 up to 32 letters.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_REQ_ORGANIZATION")
            if [[ ! "${2}" =~ ^[a-Z0-9.-]{2,32}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request organization field '${2}' in variable 'PKI_REQ_ORGANIZATION' must consist of 2 up to 32 letters and can include special characters '.' / '-'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_REQ_ORGANIZATIONUNIT")
            if [[ ! "${2}" =~ ^[a-Z0-9.-]{2,32}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request organization unit field '${2}' in variable 'PKI_REQ_ORGANIZATIONUNIT' must consist of 2 up to 32 letters and can include special characters '.' / '-'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_REQ_COMMONNAME")
            if [[ ! "${2}" =~ ^[a-Z0-9.@\ ]{2,32}$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request common name field '${2}' in variable 'PKI_REQ_COMMONNAME' must consist of 2 up to 32 characters consisting of uppercase, lowercase or the special characters '.' / '@'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_REQ_EMAIL")
            if [ "${2}x" != "x" ] ; then
                if [[ ! "${2}" =~ ^(([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]+)|[A-Za-z0-9]+)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$ ]] ; then
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request email field '${2}' in variable 'PKI_REQ_EMAIL' seems not to be a valid email address.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                    exit ${TMP_FALSE}
                fi
            fi
            ;;
        "PKI_REQ_KEY_USAGE")
            TMP_IFS=${IFS}
            IFS=', '
            for i in ${2} ; do
                if [[ ! "${i}" =~ ^(critical|digitalSignature|nonRepudiation|keyEncipherment|dataEncipherment|keyAgreement|keyCertSign|cRLSign|encipherOnly|decipherOnly)$ ]] ; then
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed extended key usage value '${i}' in variable 'PKI_REQ_EXTENDED_KEY_USAGE' seems not to be a valid value. Please ensure you use 'critical', 'digitalSignature', 'nonRepudiation', 'keyEncipherment', 'dataEncipherment', 'keyAgreement', 'keyCertSign', 'cRLSign', 'encipherOnly' or 'decipherOnly' divided by ', ' for multiple values.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
                fi
            done
            IFS=${TMP_IFS}
            ;;
        "PKI_REQ_EXTENDED_KEY_USAGE")
            TMP_IFS=${IFS}
            IFS=', '
            for i in ${2} ; do
                if [[ ! "${i}" =~ ^(critical|serverAuth|clientAuth|codeSigning|emailProtection|timeStamping|OCSPSigning|ipsecIKE|msCodeInd|msCodeCom|msCTLSign|msEFS)$ ]] ; then
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed extended key usage value '${i}' in variable 'PKI_REQ_EXTENDED_KEY_USAGE' seems not to be a valid value. Please ensure you use 'critical', 'serverAuth', 'clientAuth', 'codeSigning', 'emailProtection', 'timeStamping', 'OCSPSigning', 'ipsecIKE', 'msCodeInd', 'msCodeCom', 'msCTLSign'or 'msEFS' divided by ', ' for multiple values.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
                fi
            done
            IFS=${TMP_IFS}
            ;;
        "PKI_REQ_ALTERNATE_NAME")
            TMP_IFS=${IFS}
            IFS=', '
            for i in ${2} ; do
                if [[ ! "${i}" =~ ^(IP.[0-9]{1,1}:((((1[0-9]{0,2})|(2[0-5]{0,2}))\.((1[0-9]{0,2})|(2[0-5]{0,2}))\.((1[0-9]{0,2})|(2[0-5]{0,2}))\.((1[0-9]{0,2})|(2[0-5]{0,2})))|([0-9A-Fa-f:]{2,39})))|(DNS.[0-9]{1,1}:[a-Z0-9.]{2,64})|(EMAIL.[0-9]{1,1}:((([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]+)|[A-Za-z0-9]+)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})))$ ]] ; then
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed alternate name '${i}' in variable 'PKI_REQ_ALTERNATE_NAME' seems not to be a valid value. Please ensure you use the format 'DNS.[0-9]:example.org' / 'IP.[0-9]:127.0.0.1' / 'EMAIL.1:example@example.org' divided by ', ' for multiple values.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
                fi
            done
            IFS=${TMP_IFS}
            ;;
        "PKI_REQ_OUTPUT_FILE")
            TMP_REQ_OUTPUT_PATH=$( ${CMD_DIRNAME} "${2}" )
            if [ ! -d "${TMP_REQ_OUTPUT_PATH}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request output path '${TMP_REQ_OUTPUT_PATH}' in variable 'PKI_REQ_OUTPUT_FILE' can not be found on the current system. Please ensure that the parent folder exists.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            
            if [ ! -w "${TMP_REQ_OUTPUT_PATH}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request output path '${TMP_REQ_OUTPUT_PATH}' in variable 'PKI_REQ_OUTPUT_FILE' is not writable for the executing user. Please ensure that the user '${TMP_USER}' has write permission on folder '${PKI_REQ_OUTPUT_FILE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            
            if [ -f "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request output file '${2}' in variable 'PKI_REQ_OUTPUT_FILE' already exists. Overriding files is not supported.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            ;;
        "PKI_CERT_OUTPUT_FILE")
            TMP_CERT_OUTPUT_PATH=$( ${CMD_DIRNAME} "${2}" )
            if [ ! -d "${TMP_CERT_OUTPUT_PATH}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed certificate output path '${TMP_CERT_OUTPUT_PATH}' in variable 'PKI_CERT_OUTPUT_FILE' can not be found on the current system. Please ensure that the parent folder exists.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            
            if [ ! -w "${TMP_CERT_OUTPUT_PATH}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed certificate output path '${TMP_CERT_OUTPUT_PATH}' in variable 'PKI_CERT_OUTPUT_FILE' is not writable for the executing user. Please ensure that the user '${TMP_USER}' has write permission on folder '${PKI_REQ_OUTPUT_FILE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            
            if [ -f "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed certificate output file '${2}' in variable 'PKI_CERT_OUTPUT_FILE' already exists. Overriding files is not supported.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE} 
            fi
            ;;
        "PKI_CERT_DURATION")
            if [ "${2}x" != "x" ] ; then
                if [[ ! "${2}" =~ ^(((([1-3]{1,1}[0-6]{1,1}[0-9]{1,1})|([0-9]{1,2})) days)|((([1-5]{1,1}[0-9]{1,1})|([1-9]{1,1})) weeks)|((([1-1]{1,1}[0-2]{1,1})|([1-9]{1,1})) months)|((([1-1]{1,1}[0]{1,1})|([1-9]{1,1})) years))$ ]] ; then 
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed certification duration '${2}' in variable 'PKI_CERT_DURATION' needs to be in a valid format ( '[1-369] days' / '[1-59] weeks' / '[1-12] months' / '[1-10] years').]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                    exit ${TMP_FALSE}
                fi
            fi
            ;;
        "PKI_REQ_INPUT_FILE")
            if [ ! -f "${2}" ] || [ ! -r "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request file '${2}' in variable 'PKI_REQ_INPUT_FILE' must be an existent and by the current user readable regular file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            
            TMP_CHECK_KEY_RESULT=${TMP_TRUE}
            
            # check for a valid request file
            ${CMD_OPENSSL} req -in "${2}" >/dev/null 2>&1
            
            if [ $? -eq ${TMP_FALSE} ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed request file '${2}' in variable 'PKI_REQ_INPUT_FILE' does not seem to be a valid request file in BASE64 format.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CA_CONF_FILE")PKI_REQ_ALTERNATE_NAME=DNS.1:server.fqdn
            if [ ! -f "${2}" ] || [ ! -r "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CA configuration file '${2}' in variable 'PKI_CA_CONF_FILE' must be an existent and by the current user readable regular file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi

            if [ "${PKI_KEY_INPUT_PASSWORD}x" == "x" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The passed CA key password needs to be specified in variable 'PKI_KEY_INPUT_PASSWORD' to verify the CA configuration file '${2}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi

            # check for a valid CA configuration file
            ${CMD_OPENSSL} ca -config "${2}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" >/dev/null 2>&1
            if [ $? -ne ${TMP_TRUE} ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The passed CA configuration file '${2}' in variable 'PKI_CA_CONF_FILE' does not seem to be a valid openssl configuration file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_KEY_INPUT_PASSWORD")
            TMP_KEY_PASSWORD_INPUT_PATH=$( ${CMD_DIRNAME} "${2}" )
            if [ -d "${TMP_KEY_PASSWORD_INPUT_PATH}" ] && [[ "${2}" =~ ^.*/.*$ ]] ; then
                if [ ! -f "${2}" ] ; then
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The passed key input password value '${2}' in variable 'PKI_KEY_INPUT_PASSWORD' seems to be a filepath but the file can not be found.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                    exit ${TMP_FALSE}
                fi

                if [ $( ${CMD_WC} -l < ${2} ) -ne 1 ] || [ ! -r "${2}" ] ; then
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The passed key input password value '${2}' in variable 'PKI_KEY_INPUT_PASSWORD' needs to consist of exactly one line ansd must be readable by the executing user when passed as file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                    exit ${TMP_FALSE}
                fi

                export PKI_KEY_INPUT_PASSWORD_PREFIX="file"
            else
                export PKI_KEY_INPUT_PASSWORD_PREFIX="pass"
            fi
            ;;
        "PKI_CA_EXTENSION")
            if [[ ! "${2}" =~ ^[0-9a-Z_]{2,32}$ ]] ; then
               ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The passed CA extension value '${2}' in variable 'PKI_CA_EXTENSION' must consist of 2 up to 32 characters and can contain letters, numbers and '_'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CRL_OUTPUT_FILE")
            TMP_CERT_OUTPUT_PATH=$( ${CMD_DIRNAME} "${2}" )
            if [ ! -d "${TMP_CERT_OUTPUT_PATH}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CRL output path '${TMP_CERT_OUTPUT_PATH}' in variable 'PKI_CRL_OUTPUT_FILE' can not be found on the current system. Please ensure that the parent folder exists.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi

            if [ ! -w "${TMP_CERT_OUTPUT_PATH}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CRL output path '${TMP_CERT_OUTPUT_PATH}' in variable 'PKI_CRL_OUTPUT_FILE' is not writable for the executing user. Please ensure that the user '${TMP_USER}' has write permission on folder '${PKI_REQ_OUTPUT_FILE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CRL_DURATION")
            if [ "${2}x" != "x" ] ; then
                if [[ ! "${2}" =~ ^(((([1-3]{1,1}[0-6]{1,1}[0-9]{1,1})|([0-9]{1,2})) days)|((([1-5]{1,1}[0-9]{1,1})|([1-9]{1,1})) weeks)|((([1-1]{1,1}[0-2]{1,1})|([1-9]{1,1})) months)|((([1-1]{1,1}[0]{1,1})|([1-9]{1,1})) years))$ ]] ; then
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CRL duration '${2}' in variable 'PKI_CRL_DURATION' needs to be in a valid format ( '[1-369] days' / '[1-59] weeks' / '[1-12] months' / '[1-10] years').]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                    exit ${TMP_FALSE}
                fi
            fi
            ;;
        "PKI_CERT_REVOKE_REASON")
            if [[ ! "${2}" =~ ^(unspecified|keyCompromise|CACompromise|affiliationChanged|superseded|cessationOfOperation|certificateHold|removeFromCRL)$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CERT_REVOKE_REASON' with value '${2}' must be set with a valid revocation like 'unspecified', 'keyCompromise', 'CACompromise', 'affiliationChanged', 'superseded', 'cessationOfOperation', 'certificateHold' or 'removeFromCRL'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CERT_SERIAL")
            if [[ ! "${2}" =~ ^[0-9a-fA-F]{2,128}$ ]] ; then
               ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The passed certificate serial '${2}' in variable 'PKI_CERT_SERIAL' must consist of 2 up to 128 hexadecimal characters.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CRL_OUTPUT_PATH")
            if [ ! -d "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CRL buffer output path '${2}' in variable 'PKI_CRL_OUTPUT_PATH' can not be found on the current system. Please ensure that the folder exists.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi

            if [ ! -w "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CRL buffer output path '${2}' in variable 'PKI_CRL_OUTPUT_PATH' is not writable for the executing user. Please ensure that the user '${TMP_USER}' has write permission on folder '${PKI_CRL_OUTPUT_PATH}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CRL_INPUT_FILE")
            if [ ! -f "${2}" ] || [ ! -r "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CRL input file '${2}' in variable 'PKI_CRL_INPUT_FILE' must be an existent and by the current user readable regular file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi

            # check for a valid request file
            ${CMD_OPENSSL} crl -in "${2}" -text -noout >/dev/null 2>&1
            if [ $? -eq ${TMP_TRUE} ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CRL input file '${2}' in variable 'PKI_CRL_INPUT_FILE' seems not to be a valid CRL file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CA_OVERVIEW_INPUT_CONF_FILE")
            TMP_IFS=${IFS}
            IFS=', '
            for i in ${2} ; do
                if [ ! -f "${i}" ] || [ ! -r "${i}" ] ; then
                    ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed parameter 'PKI_CA_OVERVIEW_INPUT_CONF_FILE' with value '${i}' is not an readable and existent regular CA configuration file. Multiple entries are divided by ', '.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                    exit ${TMP_FALSE}
                fi
            done
            IFS=${TMP_IFS}
            ;;
        "PKI_CA_OVERVIEW_OUTPUT_PATH")
            if [ ! -d "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed overview HTML page output path '${2}' in variable 'PKI_CA_OVERVIEW_OUTPUT_PATH' can not be found on the current system. Please ensure that the folder exists.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi

            if [ ! -w "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed overview HTML page output path '${2}' in variable 'PKI_CA_OVERVIEW_OUTPUT_PATH' is not writable for the executing user. Please ensure that the user '${TMP_USER}' has write permission on folder '${PKI_CRL_OUTPUT_PATH}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CERT_INPUT_FILE")
            if [ ! -f "${2}" ] || [ ! -r "${2}" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed cert input file '${2}' in variable 'PKI_CERT_INPUT_FILE' must be an existent and by the current user readable regular file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi

            # check for a valid certificate file
            ${CMD_OPENSSL} x509 -in "${2}" -text -noout >/dev/null 2>&1
            if [ $? -ne ${TMP_TRUE} ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed cert input file '${2}' in variable 'PKI_CERT_INPUT_FILE' seems not to be a valid certificate file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        "PKI_CRL_OUTPUT_FORMAT")
            if [[ ! "${2}" =~ ^(PEM|DER)$ ]] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CRL_OUTPUT_FORMAT' with value '${2}' must be set either with the valid output form 'PEM' or 'DER'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                exit ${TMP_FALSE}
            fi
            ;;
        *)
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed parameter '${1}' with value '${2}' is not a valid one.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            exit ${TMP_FALSE} 
            ;;
    esac
}
    
function f_parameter_unset() {
    TMP_ENV=$( ${TMP_ENV} | ${CMD_GREP} --ignore-case "^PKI_.*$" | ${CMD_AWK} -F '=' '{ print $1 }' )
    for i in ${TMP_ENV} ; do
        ${TMP_UNSET} "${i}"
    done 
}

function function_key_set() {
    return 0
}

function f_key_set() {
    if [ "${PKI_KEY_OUTPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_OUTPUT_FILE' must be set with a valid file path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_ALGORITHM}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_ALGORITHM' must be set with a valid algorithm (ec / rsa / ed25519).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_ALGORITHM,,}" == "ec" ] && [[ ! "${PKI_KEY_ENCRYPTION}" =~ ^(prime256v1|prime384v1|prime521v1)$ ]] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_ENCRYPTION' must be set with a valid algorithm (prime256v1 / prime384v1 / prime521v1) when using variable 'PKI_KEY_ALGORITHM' with value 'ec'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_ALGORITHM,,}" == "rsa" ] && [[ ! "${PKI_KEY_ENCRYPTION}" =~ ^(rsa3072|rsa4096|rsa8192)$ ]] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_ENCRYPTION' must be set with a valid algorithm (rsa3072 / rsa4096) when using variable 'PKI_KEY_ALGORITHM' with value 'rsa'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_ALGORITHM,,}" == "ed25519" ] && [ "${PKI_KEY_ENCRYPTION}x" != "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_ENCRYPTION' must be not set when using variable 'PKI_KEY_ALGORITHM' with value 'ed25519'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_INPUT_PASSWORD}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_PASSWORD' must be set with a valid password plain or in a file (8-31 characters with at least 2 numbers, 1 lower case and 1 upper case alphabetical character).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi

    if [ "${PKI_KEY_INPUT_PASSWORD_PREFIX}" == "file" ] ; then
        TMP_KEY_PASSWORD=$( ${CMD_CAT} "${PKI_KEY_INPUT_PASSWORD}" )
    else
        TMP_KEY_PASSWORD="${PKI_KEY_INPUT_PASSWORD}"
    fi

    TMP_KEY_PASSWORD_NUMBER_COUNT=$( ${CMD_GREP} --extended-regexp --only-matching '[0-9]' <<< "${TMP_KEY_PASSWORD}" | ${CMD_WC} --lines )
    TMP_KEY_PASSWORD_ALPHABETICAL_LOWER_COUNT=$( ${CMD_GREP} --extended-regexp --only-matching '[a-z]' <<< "${TMP_KEY_PASSWORD}" | ${CMD_WC} --lines )
    TMP_KEY_PASSWORD_ALPHABETICAL_UPPER_COUNT=$( ${CMD_GREP} --extended-regexp --only-matching '[A-Z]' <<< "${TMP_KEY_PASSWORD}" | ${CMD_WC} --lines )
    if [ "${#TMP_KEY_PASSWORD}" -lt 8 ] || [ "${#TMP_KEY_PASSWORD}" -gt 31 ] || [ ${TMP_KEY_PASSWORD_NUMBER_COUNT} -lt 2 ] || [ ${TMP_KEY_PASSWORD_ALPHABETICAL_LOWER_COUNT} -lt 1 ] || [ ${TMP_KEY_PASSWORD_ALPHABETICAL_UPPER_COUNT} -lt 1 ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The private key password in variable '${PKI_KEY_INPUT_PASSWORD}' must consist of 8 to 31 characters and at least 2 numbers, 1 upper and 1 lower case alphabetical character.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi


    case "${PKI_KEY_ALGORITHM}" in
        "ec")
            ${CMD_OPENSSL} genpkey -quiet -out "${PKI_KEY_OUTPUT_FILE}" -algorithm "${PKI_OPENSSL_KEY_ALGORITHM}" -aes-256-ecb -pkeyopt "${PKI_OPENSSL_KEY_OPTION1}" -pkeyopt "${PKI_OPENSSL_KEY_OPTION2}" -pass "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" 2>/dev/null
            TMP_CHECK_KEY=$( ${CMD_OPENSSL} ec -check -in "${PKI_KEY_OUTPUT_FILE}" -passin pass: 2>&1 | ${CMD_GREP} --ignore-case "bad\ decrypt" 2>/dev/null )
            ;;
        "rsa")
            ${CMD_OPENSSL} genpkey -quiet -out "${PKI_KEY_OUTPUT_FILE}" -algorithm "${PKI_OPENSSL_KEY_ALGORITHM}" -aes-256-ecb -pkeyopt "${PKI_OPENSSL_KEY_OPTION1}" -pass "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" 2>/dev/null
            TMP_CHECK_KEY=$( ${CMD_OPENSSL} rsa -check -in "${PKI_KEY_OUTPUT_FILE}" -passin pass: 2>&1 | ${CMD_GREP} --ignore-case "bad\ decrypt" 2>/dev/null )
            ;;
        "ed25519")
            ${CMD_OPENSSL} genpkey -quiet -out "${PKI_KEY_OUTPUT_FILE}" -algorithm "${PKI_OPENSSL_KEY_ALGORITHM}" -aes-256-ecb -pass "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" 2>/dev/null
            TMP_CHECK_KEY=$( ${CMD_OPENSSL} ec -check -in "${PKI_KEY_OUTPUT_FILE}" -passin pass: 2>&1 | ${CMD_GREP} --ignore-case "bad\ decrypt" 2>/dev/null )
            ;;
        *)
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The private key algorithm '${PKI_KEY_ALGORITHM}' is unknown. The private key could not be generated.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            return ${TMP_FALSE}
            ;;
    esac
    
    TMP_CHECK_KEY_RESULT=${TMP_TRUE}
    
    if [ "${TMP_CHECK_KEY}x" == "x" ] ; then
        TMP_CHECK_KEY_RESULT=${TMP_FALSE}
    fi
    
    if [ ${TMP_CHECK_KEY_RESULT} -eq ${TMP_FALSE} ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The private key '${PKI_KEY_OUTPUT_FILE}' with algorithm '${PKI_KEY_ALGORITHM}' and encrpyption '${PKI_KEY_ENCRYPTION}' could not be generated.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The private key '${PKI_KEY_OUTPUT_FILE}' with algorithm '${PKI_KEY_ALGORITHM}' and encrpyption '${PKI_KEY_ENCRYPTION}' was successfully generated.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_TRUE}
    fi
}

function f_req_set() {
    if [ "${PKI_REQ_OUTPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_OUTPUT_FILE' must be set with a valid request output filename path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_INPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_FILE' must be set with a valid Key input path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_INPUT_PASSWORD}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_PASSWORD' must be set with the valid password for key '${PKI_KEY_INPUT_FILE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_REQ_HASH}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_HASH' must be set with a valid hash value ('sha384' / 'sha512' / 'sha512-256' / 'sha3-256' / 'sha3-384' / 'sha3-512').]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_REQ_COUNTRY}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_COUNTRY' must be set with a valid country name value (two capital letters).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_REQ_STATE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_STATE' must be set with a valid state name value (2 to 32 letters).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_REQ_LOCATION}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_LOCATION' must be set with a valid location name value (2 to 32 letters).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_REQ_ORGANIZATION}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_ORGANIZATION' must be set with a valid organization name value (2 to 32 letters).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_REQ_ORGANIZATIONUNIT}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_ORGANIZATIONUNIT' must be set with a valid organization unit name value (2 to 32 letters).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_REQ_COMMONNAME}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_COMMONNAME' must be set with a valid common name value (2 up to 32 characters consisting of uppercase, lowercase or the special characters '.' / '@').]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_REQ_KEY_USAGE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_KEY_USAGE' must be set with a valid key usage value ('critical', 'digitalSignature', 'nonRepudiation', 'keyEncipherment', 'dataEncipherment', 'keyAgreement', 'keyCertSign', 'cRLSign', 'encipherOnly', 'decipherOnly' divided by ', ' for multiple values).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_CA_ROOT}x" == "x" ] && [ "${PKI_REQ_ALTERNATE_NAME}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_ALTERNATE_NAME' must be set with at least one valid value for DNS, IP or EMAIL (multiple values divided by ', ').]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    export PKI_CA_PATHLENGTH=${PKI_CA_PATHLENGTH:-0}
    
    ${CMD_ECHO} "[ req ]" > "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "distinguished_name=req_distinguished_name" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "req_extensions=req_cert_extensions" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "default_md=${PKI_REQ_HASH}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "dirstring_type=nombstr" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "prompt=no" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "[ req_distinguished_name ]" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "C=${PKI_REQ_COUNTRY}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "ST=${PKI_REQ_STATE}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "L=${PKI_REQ_LOCATION}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "O=${PKI_REQ_ORGANIZATION}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "1.OU=${PKI_REQ_ORGANIZATIONUNIT}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    if [ "${PKI_REQ_EMAIL}x" != "x" ] ; then
       ${CMD_ECHO} "emailAddress=${PKI_REQ_EMAIL}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    fi
    ${CMD_ECHO} "CN=${PKI_REQ_COMMONNAME}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    ${CMD_ECHO} "[ req_cert_extensions ]" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    if [ "${PKI_CA_ROOT}x" == "x" ] ; then
        ${CMD_ECHO} "subjectAltName=@subject_alt_name" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    fi
    if [ "${PKI_CA_ROOT}x" != "x" ] ; then
        ${CMD_ECHO} "basicConstraints=critical,CA:true,pathlen:${PKI_CA_PATHLENGTH}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    else
        ${CMD_ECHO} "basicConstraints=critical,CA:false,pathlen:${PKI_CA_PATHLENGTH}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    fi
    ${CMD_ECHO} "keyUsage=${PKI_REQ_KEY_USAGE}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    if [ "${PKI_REQ_EXTENDED_KEY_USAGE}x" != "x" ] ; then
        ${CMD_ECHO} "extendedKeyUsage=${PKI_REQ_EXTENDED_KEY_USAGE}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    fi
    ${CMD_ECHO} "[subject_alt_name]" >> "${PKI_REQ_OUTPUT_FILE}.conf"
    if [ "${PKI_CA_ROOT}x" == "x" ] ; then
        TMP_IFS=${IFS}
        IFS=', '
        for i in ${PKI_REQ_ALTERNATE_NAME} ; do
            TMP_REQ_ALTNAME=$( ${CMD_SED} 's/\:/\=/g' <<< "${i}" )
            ${CMD_ECHO} "${TMP_REQ_ALTNAME}" >> "${PKI_REQ_OUTPUT_FILE}.conf"
            TMP_REQ_ALTNAME=""
        done 
        IFS=${TMP_IFS}
    fi
    
    TMP_TIME=$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )
    ${CMD_DD} if=/dev/urandom bs=1k count=512 of="/tmp/${TMP_TIME}_RANDFILE" 2>/dev/null
    if [ $? -ne ${TMP_TRUE} ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The random file '/tmp/${TMP_TIME}_RANDFILE' for request '${PKI_REQ_OUTPUT_FILE}' could not be created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        return ${TMP_FALSE}
    fi

    ${CMD_OPENSSL} req -new -key "${PKI_KEY_INPUT_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -rand "/tmp/${TMP_TIME}_RANDFILE" -config "${PKI_REQ_OUTPUT_FILE}.conf" -out "${PKI_REQ_OUTPUT_FILE}"
    
    if [ $? -eq ${TMP_TRUE} ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The request file '${PKI_REQ_OUTPUT_FILE}' with configuration '${PKI_REQ_OUTPUT_FILE}.conf' was successfully created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        return ${TMP_TRUE}
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The request file '${PKI_REQ_OUTPUT_FILE}' with configuration '${PKI_REQ_OUTPUT_FILE}.conf' could not be created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        return ${TMP_FALSE}
    fi 
}

function f_cert_set() {
    if [ "${PKI_CERT_OUTPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CERT_OUTPUT_FILE' must be set with a valid filename path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_CERT_DURATION}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CERT_DURATION' must be set with a valid format ( '[1-369] days' / '[1-59] weeks' / '[1-12] months' / '[1-10] years').]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_REQ_INPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_INPUT_FILE' must be set with a valid request file path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_INPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_FILE' must be set with a valid private key input path for the CA.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_INPUT_PASSWORD}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_PASSWORD' must be set with the valid password for the CA private key '${PKI_KEY_INPUT_FILE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_CA_CONF_FILE}x" == "x" ] && [ "${PKI_CA_ROOT}x" != "1x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [Either the CA configuration file path at variable 'PKI_CA_CONF_FILE' or the CA root indicator 'PKI_CA_ROOT=1' must be set. ]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_CA_CONF_FILE}x" != "x" ] ; then
        if [ "${PKI_CA_EXTENSION}x" != "x" ] ; then
            TMP_CA_EXTENSION_CHECK=$( ${CMD_GREP} --extended-regexp "^\[\ ${PKI_CA_EXTENSION}\ \]$" < "${PKI_CA_CONF_FILE}" 2>/dev/null )
            if [ $? -eq ${TMP_FALSE} ] || [ "${TMP_CA_EXTENSION_CHECK}x" == "x" ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The passed CA profile value '${PKI_CA_EXTENSION}' in variable 'PKI_CA_EXTENSION' can not be found in the CA configuration file '${PKI_CA_CONF_FILE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                return ${TMP_FALSE}
            fi
        fi
    fi
    
    TMP_TIME=$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )
    ${CMD_DD} if=/dev/urandom bs=1k count=512 of="/tmp/${TMP_TIME}_RANDFILE" 2>/dev/null
    
    TMP_CERT_STARTDATE=$( ${CMD_DATE} --date 'now' --utc +"%Y-%m-%d 00:00:00.0" -d "-1 days" 2>/dev/null )
    TMP_CERT_STARTDATE_HUMAN=$( ${CMD_DATE} --date "${TMP_CERT_STARTDATE}" --utc +"%Y-%m-%d 00:00:00 UTC" -d "-1 days" 2>/dev/null )
    TMP_CERT_STARTDATE=$( ${CMD_DATE} --date "${TMP_CERT_STARTDATE}" --utc +"%Y%m%d000000Z" -d "-1 days" 2>/dev/null )
    if [ $? -ne ${TMP_TRUE} ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The start date for the certificate in variable 'TMP_CERT_STARTDATE' could not be generated and has value '${TMP_CERT_STARTDATE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        return ${TMP_FALSE}
    fi
    
    TMP_CERT_ENDDATE=$( ${CMD_DATE} --date 'now' --utc +"%Y-%m-%d 11:59:59.0" -d "+${PKI_CERT_DURATION}" 2>/dev/null )
    TMP_CERT_ENDDATE_HUMAN=$( ${CMD_DATE} --date "${TMP_CERT_ENDDATE}" --utc +"%Y-%m-%d 11:59:59 UTC" -d "+${PKI_CERT_DURATION}" 2>/dev/null )
    TMP_CERT_ENDDATE=$( ${CMD_DATE} --date "${TMP_CERT_ENDDATE}" --utc +"%Y%m%d115959Z" -d "+${PKI_CERT_DURATION}" 2>/dev/null )
    if [ $? -ne ${TMP_TRUE} ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The end date for the certificate in variable 'TMP_CERT_ENDDATE' could not be generated and has value '${TMP_CERT_ENDDATE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        return ${TMP_FALSE}
    fi
    
    if [ "${PKI_CA_ROOT}x" == "1x" ] ; then
        ${CMD_OPENSSL} req -x509 -in "${PKI_REQ_INPUT_FILE}" -not_before "${TMP_CERT_STARTDATE}" -not_after "${TMP_CERT_ENDDATE}" -key "${PKI_KEY_INPUT_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -rand "/tmp/${TMP_TIME}_RANDFILE" -config "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" -extensions "v3_root_ca" -out "${PKI_CERT_OUTPUT_FILE}" 2>/dev/null
    else
        if [ "${PKI_CA_EXTENSION}x" != "x" ] ; then
            ${CMD_OPENSSL} ca -config "${PKI_CA_CONF_FILE}" -keyfile "${PKI_KEY_INPUT_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -rand_serial -rand "/tmp/${TMP_TIME}_RANDFILE" -startdate "${TMP_CERT_STARTDATE}" -enddate "${TMP_CERT_ENDDATE}" -extensions "${PKI_CA_EXTENSION}" -in "${PKI_REQ_INPUT_FILE}" -out "${PKI_CERT_OUTPUT_FILE}"
        else
            ${CMD_OPENSSL} ca -config "${PKI_CA_CONF_FILE}" -keyfile "${PKI_KEY_INPUT_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -rand_serial -rand "/tmp/${TMP_TIME}_RANDFILE" -startdate "${TMP_CERT_STARTDATE}" -enddate "${TMP_CERT_ENDDATE}" -in "${PKI_REQ_INPUT_FILE}" -out "${PKI_CERT_OUTPUT_FILE}"
        fi
    fi
    
    if [ $? -eq ${TMP_TRUE} ] && [ -f "${PKI_CERT_OUTPUT_FILE}" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The certificate file '${PKI_CERT_OUTPUT_FILE}' with start date '${TMP_CERT_STARTDATE_HUMAN}' and end date '${TMP_CERT_ENDDATE_HUMAN}' was successfully created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        return ${TMP_TRUE}
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The certificate file '${PKI_CERT_OUTPUT_FILE}' with start date '${TMP_CERT_STARTDATE_HUMAN}' and end date '${TMP_CERT_ENDDATE_HUMAN}' could not be created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        return ${TMP_FALSE}
    fi
}

function f_ca_set() {
    if [ "${PKI_CA_OUTPUT_PATH}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CA_OUTPUT_PATH' must be set with a valid directory path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
    
    if [ "${PKI_CA_NAME}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CA_NAME' must be set with a valid CA name (4-32 characters with alphabetical or numerical characters).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ -d "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The PKI CA output path '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}' already exists. Stopping execution to prevent override. Please correct it manually.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
    
    if [ "${PKI_CA_ROOT}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CA_ROOT' must be set with a valid vlaue (1 numerical character between 0-1 - 0 = intermediate CA | 1 = root CA).]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
    
    if [ "${PKI_CA_BASE_URI}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CA_BASE_URI' must be set with a valid URI.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_CA_POLICY}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CA_POLICY' must be set with a valid OID number.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
    
    if [ "${PKI_CA_CERT_POLICY}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CA_CERT_POLICY' must be set with a valid OID number.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
    
    if [ "${PKI_KEY_OUTPUT_FILE}x" != "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_OUTPUT_FILE' can not be set as it is automatically set to '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.key'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
    
    export "PKI_KEY_OUTPUT_FILE=${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.key"

    if [ "${PKI_REQ_OUTPUT_FILE}x" != "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_OUTPUT_FILE' can not be set as it is automatically set to '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.req'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
    
    export "PKI_REQ_OUTPUT_FILE=${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.req"
    
    if [ "${PKI_REQ_INPUT_FILE}x" != "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_REQ_INPUT_FILE' can not be set as it is automatically set to '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.req'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
    
    export "PKI_REQ_INPUT_FILE=${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.req"
    
    if [ "${PKI_KEY_INPUT_FILE}x" != "x" ] && [ "${PKI_CA_ROOT}x" == "1x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_FILE' can not be set as it is automatically set to '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.key'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    TMP_PKI_KEY_INPUT_FILE="${PKI_KEY_INPUT_FILE:-${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.key}"
    
    if [ "${PKI_CERT_OUTPUT_FILE}x" != "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CERT_OUTPUT_FILE' can not be set as it is automatically set to '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/public/${PKI_CA_NAME}.cer'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
    
    export "PKI_CERT_OUTPUT_FILE=${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/public/${PKI_CA_NAME}.cer"
    
    ${CMD_MKDIR} --parents "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/"{signing/{newcerts,crls},\.private,public}
    
    if [ $? -ne ${TMP_TRUE} ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The basic structure for CA '${PKI_CA_NAME}' at '${PKI_CA_OUTPUT_PATH}' could not be generated successfully.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE} 
    fi
    
    if [ ! -f "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/certdb.txt" ] ; then
        ${CMD_TOUCH} "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/certdb.txt"
        if [ $? -ne ${TMP_TRUE} ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The basic certificate database file of the CA '${PKI_CA_NAME}' at '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/certdb.txt' could not be created successfully. Deleting non-functional CA structure '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            ${CMD_RM} --recursive --force "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}"
            exit ${TMP_FALSE}
        fi
    fi
    
    if [ ! -f "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/serial.txt" ] ; then
        ${CMD_TOUCH} "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/serial.txt"
        if [ $? -ne ${TMP_TRUE} ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The basic serial buffer file of the CA '${PKI_CA_NAME}' at '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/serial.txt' could not be created successfully. Deleting non-functional CA structure '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            ${CMD_RM} --recursive --force "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}"
            exit ${TMP_FALSE}
        fi
    fi
    
    if [ ! -f "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/crls/crlnumber" ] ; then
        ${CMD_TOUCH} "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/crls/crlnumber"
        ${CMD_ECHO} "0000" > "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/crls/crlnumber"
        if [ $? -ne ${TMP_TRUE} ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The basic CRL number file of the CA '${PKI_CA_NAME}' at '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/signing/crls/crlnumber' could not be created successfully. Deleting non-functional CA structure '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            ${CMD_RM} --recursive --force "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}"
            exit ${TMP_FALSE}
        fi
    fi
    
    f_key_set
    if [ $? -ne ${TMP_TRUE} ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The key file '${PKI_KEY_OUTPUT_FILE}' for CA '${PKI_CA_NAME}' with algorithm '${PKI_KEY_ALGORITHM}' and encrpyption '${PKI_KEY_ENCRYPTION}' could not be generated. Deleting non-functional CA structure '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --recursive --force "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}"
        exit ${TMP_FALSE}
    fi

    export "PKI_KEY_INPUT_FILE=${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.key"

    f_req_set 
    if [ $? -ne ${TMP_TRUE} ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The request file '${PKI_REQ_OUTPUT_FILE}' for CA '${PKI_CA_NAME}' with algorithm '${PKI_KEY_ALGORITHM}' and encrpyption '${PKI_KEY_ENCRYPTION}' could not be generated. Deleting non-functional CA structure '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --recursive --force "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}"
        exit ${TMP_FALSE}
    fi
    
    if [ ! -f "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" ] ; then
        ${CMD_TOUCH} "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        if [ $? -ne ${TMP_TRUE} ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The basic configuration file of the CA '${PKI_CA_NAME}' at '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf' could not be created successfully. Deleting non-functional CA structure '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            ${CMD_RM} --recursive --force "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}"
            exit ${TMP_FALSE}
        fi
        
        ${CMD_ECHO} "HOME                            = ${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}" > "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} "[ ca ]" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} "default_ca                      = CA_default" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} "[ CA_default ]" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} "# Directory and file locations." >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} "dir                             = ${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'certs                           = $dir/signing/newcerts' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'crl_dir                         = $dir/signing/crls' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'new_certs_dir                   = $dir/signing/newcerts' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'database                        = $dir/signing/certdb.txt' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} 'serial                          = $dir/signing/serial.txt' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'RANDFILE                        = $dir/.private/RANDFILE.BIN' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"  
        ${CMD_ECHO} '# The key and certificate.' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'private_key                     = $dir/.private/'"${PKI_CA_NAME}.key" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'certificate                     = $dir/public/'"${PKI_CA_NAME}.cer" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} '# For certificate revocation lists.' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'crlnumber                       = $crl_dir/crlnumber' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'crl                             = $crl_dir/'"${PKI_CA_NAME}.crl" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'crl_extensions                  = crl_ext' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'default_crl_days                = 7' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"  
        ${CMD_ECHO} 'default_md                      = sha256' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} 'name_opt                        = ca_default' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'cert_opt                        = ca_default' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'default_days                    = 365' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'preserve                        = no' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'policy                          = policy' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'unique_subject                  = no' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'copy_extensions                 = copy' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"  
        ${CMD_ECHO} '[ policy ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'countryName                     = match' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'stateOrProvinceName             = match' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'localityName                    = supplied' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'organizationName                = supplied' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'organizationalUnitName          = supplied' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'commonName                      = supplied' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'emailAddress                    = optional' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} '[ req ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'distinguished_name              = req_distinguished_name' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'attributes                      = req_attributes' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'string_mask                     = utf8only' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'x509_extensions                 = v3_default' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"  
        ${CMD_ECHO} '[ req_distinguished_name ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'countryName                     = Country Name (2 letter code)' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'countryName_default             = '"${PKI_REQ_COUNTRY}" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'countryName_min                 = 2' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'countryName_max                 = 2' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'stateOrProvinceName             = State or Province Name' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'stateOrProvinceName_default     = '"${PKI_REQ_STATE}" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'localityName                    = Locality Name (e.g. city)' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'localityName_default            = '"${PKI_REQ_LOCATION}" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '0.organizationName              = Organization Name' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '0.organizationName_default      = '"${PKI_REQ_ORGANIZATION}" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'organizationalUnitName          = Organizational Unit Name' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'organizationalUnitName_default  = '"${PKI_REQ_ORGANIZATIONUNIT}" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'commonName                      = Common Name (e.g. server FQDN or hostname)' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'commonName_max                  = 64' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'emailAddress                    = Email Address' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} '[ req_attributes ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'challengePassword               = A challenge password' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'challengePassword_min           = 4' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'challengePassword_max           = 20' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'unstructuredName                = An optional company name' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"  
        ${CMD_ECHO} '[ v3_default ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extensions for a typical CA (`man x509v3_config`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always,issuer' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'basicConstraints                = critical, CA:false' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'keyUsage                        = critical, digitalSignature, keyEncipherment, nonRepudiation' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"   
        if [ "${PKI_CA_ROOT}x" == "1x" ] ; then
            ${CMD_ECHO} '[ v3_root_ca ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
            ${CMD_ECHO} '# Extensions for a typical CA (`man x509v3_config`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
            ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
            ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
            ${CMD_ECHO} 'basicConstraints                = critical, CA:true' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
            ${CMD_ECHO} 'keyUsage                        = critical, digitalSignature, cRLSign, keyCertSign' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
            ${CMD_ECHO} 'authorityInfoAccess             = @cert_default_aia' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
            ${CMD_ECHO} 'certificatePolicies             = ia5org,@v3_ca_policies' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
            ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        fi
        ${CMD_ECHO} '[ v3_ca_policies ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'policyIdentifier                = '"${PKI_CA_POLICY}" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'CPS                             = '"${PKI_CA_BASE_URI}/${PKI_CA_NAME}/policy" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} '[ v3_intermediate_ca ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extensions for a typical intermediate CA (`man x509v3_config`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always,issuer' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'basicConstraints                = critical, CA:true, pathlen:0' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'keyUsage                        = critical, digitalSignature, cRLSign, keyCertSign' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'crlDistributionPoints           = cert_default_crls' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityInfoAccess             = @cert_default_aia' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'certificatePolicies             = ia5org,@v3_ca_policies' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"  
        ${CMD_ECHO} '[ crl_ext ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extension for CRLs (`man x509v3_config`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always,issuer:always' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectAltName                  = @crl_ext_altnames' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} '[ crl_ext_altnames ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'URI.1                           = '"${PKI_CA_BASE_URI}/${PKI_CA_NAME}" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} '#[ cert_default_policies ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '#policyIdentifier                = '"${PKI_CA_CERT_POLICY}" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '#CPS                             = '"${PKI_CA_BASE_URI}/${PKI_CA_NAME}/policy" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "#" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '[ cert_default_crls ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'fullname                        = URI:'"${PKI_CA_BASE_URI}/${PKI_CA_NAME}/${PKI_CA_NAME}.crl" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '[ cert_default_aia ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'caIssuers;URI                   = '"${PKI_CA_BASE_URI}/${PKI_CA_NAME}/${PKI_CA_NAME}.cer" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '[ cert_default ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extensions for server certificates (`man x509v3_config`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'basicConstraints                = CA:FALSE' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always,issuer:always' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'keyUsage                        = critical, digitalSignature, keyEncipherment' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityInfoAccess             = @cert_default_aia' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '[ cert_email ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extensions for client certificates (`man x509v3_config`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'basicConstraints                = CA:FALSE' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid,issuer' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'keyUsage                        = critical, nonRepudiation, digitalSignature, keyEncipherment' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'extendedKeyUsage                = critical, clientAuth, emailProtection' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'crlDistributionPoints           = cert_default_crls' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityInfoAccess             = @cert_default_aia' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'certificatePolicies             = ia5org,@v3_ca_policies' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '[ cert_server_auth ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extensions for server certificates (`man x509v3_config`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'basicConstraints                = CA:FALSE' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always,issuer:always' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'keyUsage                        = critical, digitalSignature, keyEncipherment' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'extendedKeyUsage                = critical, serverAuth' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityInfoAccess             = @cert_default_aia' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '[ cert_server_client_auth ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extensions for server certificates (`man x509v3_config`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'basicConstraints                = CA:FALSE' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always,issuer:PKI_CA_OVERVIEW_INPUT_CONF_FILEalways' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'keyUsage                        = critical, digitalSignature, keyEncipherment' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'extendedKeyUsage                = critical, serverAuth,clientAuth' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityInfoAccess             = @cert_default_aia' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" 
        ${CMD_ECHO} '[ cert_code ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extension for OCSP signing certificates (`man ocsp`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'basicConstraints                = CA:FALSE' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always,issuer:always' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityInfoAccess             = @cert_default_aia' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'keyUsage                        = critical, digitalSignature' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'extendedKeyUsage                = critical, codeSigning, msCodeInd, msCodeCom' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'crlDistributionPoints           = cert_default_crls' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '[ cert_crl ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extension for CRL signing certificates.' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'basicConstraints                = CA:FALSE' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always,issuer:always' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityInfoAccess             = @cert_default_aia' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'keyUsage                        = critical, digitalSignature, cRLSign' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'extendedKeyUsage                = critical, OCSPSigning' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'crlDistributionPoints           = cert_default_crls' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} "" >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '[ cert_ocsp ]' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} '# Extension for OCSP signing certificates (`man ocsp`).' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'basicConstraints                = CA:FALSE' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'subjectKeyIdentifier            = hash' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityKeyIdentifier          = keyid:always,issuer:always' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'authorityInfoAccess             = @cert_default_aia' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'keyUsage                        = critical, digitalSignature' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'extendedKeyUsage                = critical, OCSPSigning' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        ${CMD_ECHO} 'crlDistributionPoints           = cert_default_crls' >> "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf"
        
        if [ "${PKI_CA_ROOT}x" == "1x" ] ; then
            export "PKI_KEY_INPUT_FILE=${TMP_PKI_KEY_INPUT_FILE}"

            f_cert_set
            if [ $? -ne ${TMP_TRUE} ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The certificate file '${PKI_CERT_OUTPUT_FILE}' for root CA '${PKI_CA_NAME}' with algorithm '${PKI_KEY_ALGORITHM}' and encrpyption '${PKI_KEY_ENCRYPTION}' could not be generated. Deleting non-functional CA structure '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                ${CMD_RM} --recursive --force "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}"
                exit ${TMP_FALSE}
            fi

            ${CMD_OPENSSL} ca -config "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" >/dev/null 2>&1
            if [ $? -ne ${TMP_TRUE} ] ; then
                ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The generated root CA configuration file '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf' does not seem to be a valid openssl configuration file. Deleting non-functional CA structure '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
                ${CMD_RM} --recursive --force "${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}"
                exit ${TMP_FALSE}
            fi
        fi
    fi
    
    if [ "${PKI_CA_ROOT}x" == "1x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The root CA '${PKI_CA_NAME}' at path '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}' with private key '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.key', certificate file '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/public/signing/${PKI_CA_NAME}.cer' and configuration file '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf' was successfully created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The intermediate CA '${PKI_CA_NAME}' at path '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}' with private key '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.key', request file '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.req' and configuration file '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.conf' was successfully created. Please sign the request file '${PKI_CA_OUTPUT_PATH}/${PKI_CA_NAME}/.private/${PKI_CA_NAME}.req' with a valid CA at a higher hierarchy.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
    fi
    
    exit ${TMP_TRUE}
}

function f_crl_set() {
    if [ "${PKI_CRL_OUTPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CRL_OUTPUT_FILE' must be set with a valid filename path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if ( [ "${PKI_KEY_INPUT_FILE}x" != "x" ] && [ "${PKI_CERT_INPUT_FILE}x" == "x" ] ) || ( [ "${PKI_KEY_INPUT_FILE}x" == "x" ] && [ "${PKI_CERT_INPUT_FILE}x" != "x" ] ) ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CERT_INPUT_FILE' and 'PKI_KEY_INPUT_FILE' need to be specified together. If not specified, the CA configuration private key and certificate will be used.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_KEY_INPUT_PASSWORD}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_PASSWORD' must be set with the valid password for the signing private key.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_CA_CONF_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA configuration file path at variable 'PKI_CA_CONF_FILE' must be set to a valid CA configuration path. ]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    PKI_CRL_OUTPUT_FORMAT="${PKI_CRL_OUTPUT_FORMAT:-pem}"

    TMP_TIME=$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )
    ${CMD_DD} if=/dev/urandom bs=1k count=512 of="/tmp/${TMP_TIME}_RANDFILE" 2>/dev/null

    if [ "${PKI_CRL_DURATION}x" != "x" ] ; then
        TMP_CRL_STARTDATE=$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d000000Z" -d "-1 days" 2>/dev/null )
        if [ $? -ne ${TMP_TRUE} ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The start date for the certificate in variable 'TMP_CRL_STARTDATE' could not be generated and has value '${TMP_CRL_STARTDATE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
            exit ${TMP_FALSE}
        fi

        TMP_CRL_ENDDATE=$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d115959Z" -d "+${PKI_CRL_DURATION}" 2>/dev/null )
        if [ $? -ne ${TMP_TRUE} ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The end date for the certificate in variable 'TMP_CRL_ENDDATE' could not be generated and has value '${TMP_CRL_ENDDATE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
            exit ${TMP_FALSE}
        fi

        if [ "${PKI_KEY_INPUT_FILE}x" != "x" ] && [ "${PKI_CERT_INPUT_FILE}x" != "x" ] ; then
            ${CMD_OPENSSL} ca -config "${PKI_CA_CONF_FILE}" -keyfile "${PKI_KEY_INPUT_FILE}" -cert "${PKI_CERT_INPUT_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -rand_serial -rand "/tmp/${TMP_TIME}_RANDFILE" -crl_lastupdate "${TMP_CRL_STARTDATE}" -crl_nextupdate "${TMP_CRL_ENDDATE}" -gencrl -out "${PKI_CRL_OUTPUT_FILE}" 2>/dev/null
        else
            ${CMD_OPENSSL} ca -config "${PKI_CA_CONF_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -rand_serial -rand "/tmp/${TMP_TIME}_RANDFILE" -crl_lastupdate "${TMP_CRL_STARTDATE}" -crl_nextupdate "${TMP_CRL_ENDDATE}" -gencrl -out "${PKI_CRL_OUTPUT_FILE}" 2>/dev/null
        fi
    else
        if [ "${PKI_KEY_INPUT_FILE}x" != "x" ] && [ "${PKI_CERT_INPUT_FILE}x" != "x" ] ; then
            ${CMD_OPENSSL} ca -config "${PKI_CA_CONF_FILE}" -keyfile "${PKI_KEY_INPUT_FILE}" -cert "${PKI_CERT_INPUT_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -rand_serial -rand "/tmp/${TMP_TIME}_RANDFILE" -gencrl -out "${PKI_CRL_OUTPUT_FILE}" 2>/dev/null
        else
            ${CMD_OPENSSL} ca -config "${PKI_CA_CONF_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -rand_serial -rand "/tmp/${TMP_TIME}_RANDFILE" -gencrl -out "${PKI_CRL_OUTPUT_FILE}" 2>/dev/null
        fi
    fi

    if [[ "${PKI_CRL_OUTPUT_FORMAT}" =~ ^(DER|der)$ ]] ; then
        ${CMD_OPENSSL} crl -in "${PKI_CRL_OUTPUT_FILE}" -outform der -out "${PKI_CRL_OUTPUT_FILE}" 2>/dev/null
    fi

    if [ $? -eq ${TMP_TRUE} ] && [ -f "${PKI_CRL_OUTPUT_FILE}" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The CRL file '${PKI_CRL_OUTPUT_FILE}' with CA configuration file '${PKI_CA_CONF_FILE}' and output format '${PKI_CRL_OUTPUT_FORMAT}' was successfully created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        exit ${TMP_TRUE}
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The CRL file '${PKI_CRL_OUTPUT_FILE}' with CA configuration file '${PKI_CA_CONF_FILE}' and output format '${PKI_CRL_OUTPUT_FORMAT}' could not be created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        exit ${TMP_FALSE}
    fi
}

function f_cert_unset() {
    if [ "${PKI_CERT_SERIAL}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CERT_SERIAL' must be set with a valid certificate serial which is signed by the CA.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --appePKI_CA_OVERVIEW_INPUT_CONF_FILEnd "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_KEY_INPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_FILE' must be set with a valid private key input path for the CA.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_KEY_INPUT_PASSWORD}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_PASSWORD' must be set with the valid password for the CA private key '${PKI_KEY_INPUT_FILE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_CA_CONF_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA configuration file path at variable 'PKI_CA_CONF_FILE' must be set to a valid CA configuration path. ]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    TMP_CA_CONF_DIR=$( ${CMD_GREP} --extended-regexp "^dir\s+=\s+.*$" < "${PKI_CA_CONF_FILE}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
    if [ "${TMP_CA_CONF_DIR}x" == "x" ] || [ ! -d "${TMP_CA_CONF_DIR}" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA configuration variable 'dir' from CA configration file '${PKI_CA_CONF_FILE}' and value '${TMP_CA_CONF_DIR}' could not be extracted to a valid directory path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    TMP_CA_CONF_CERTDIR=$( ${CMD_GREP} --extended-regexp "^new_certs_dir\s+=\s+.*$" < "${PKI_CA_CONF_FILE}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
    if [ "${TMP_CA_CONF_CERTDIR}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA configuration variable 'new_certs_dir' from CA configration file '${PKI_CA_CONF_FILE}' and value '${TMP_CA_CONF_CERTDIR}' could not be extracted]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [[ "${TMP_CA_CONF_CERTDIR}" =~ ^\$dir.*$ ]] ; then
        TMP_CA_CONF_CERTDIR=$( ${CMD_AWK} -v dir="${TMP_CA_CONF_DIR}" -F '\\$dir' '{ print dir$2 }' <<< "${TMP_CA_CONF_CERTDIR}" )
    fi

    if [ ! -d "${TMP_CA_CONF_CERTDIR}" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA configuration variable 'new_certs_dir' from CA configration file '${PKI_CA_CONF_FILE}' and value '${TMP_CA_CONF_CERTDIR}' is not a valid path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_CERT_REVOKE_REASON}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CERT_REVOKE_REASON' must be set with a valid revocation reason ('unspecified' / 'keyCompromise' / 'CACompromise' / 'affiliationChanged' / 'superseded' / 'cessationOfOperation' / 'certificateHold' / 'removeFromCRL').]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    TMP_TIME=$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )
    ${CMD_DD} if=/dev/urandom bs=1k count=512 of="/tmp/${TMP_TIME}_RANDFILE" 2>/dev/null

    ${CMD_OPENSSL} ca -config "${PKI_CA_CONF_FILE}" -keyfile "${PKI_KEY_INPUT_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -rand_serial -rand "/tmp/${TMP_TIME}_RANDFILE" -revoke "${TMP_CA_CONF_CERTDIR}/${PKI_CERT_SERIAL}.pem" -crl_reason "${PKI_CERT_REVOKE_REASON}" 2>/dev/null
    if [ $? -eq ${TMP_TRUE} ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The certificate with serial '${PKI_CERT_SERIAL}' and CA configuration file '${PKI_CA_CONF_FILE}' was successfully revoked with reason '${PKI_CERT_REVOKE_REASON}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        exit ${TMP_TRUE}
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The certificate with serial '${PKI_CERT_SERIAL}' and CA configuration file '${PKI_CA_CONF_FILE}' could not be revoked with reason '${PKI_CERT_REVOKE_REASON}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ${CMD_RM} --force "/tmp/${TMP_TIME}_RANDFILE" >/dev/null 2>&1
        exit ${TMP_FALSE}
    fi
}

function f_crl_copy() {
    if [ "${PKI_CRL_OUTPUT_PATH}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CRL_OUTPUT_PATH' for the buffer CRL must be set with a valid path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_CRL_INPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CRL_INPUT_FILE' must be set with a valid filename path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    TMP_CRL_NAME=$( ${CMD_AWK} -F '/' '{ print $NF }' <<< "${PKI_CRL_INPUT_FILE}" )

    ${CMD_CAT} "${PKI_CRL_INPUT_FILE}" > "${PKI_CRL_OUTPUT_PATH}/${TMP_CRL_NAME}.buffer"

    if [ $? -eq ${TMP_TRUE} ] && [ -f "${PKI_CRL_OUTPUT_PATH}/${TMP_CRL_NAME}.buffer" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The CRL buffer file '${PKI_CRL_OUTPUT_PATH}/${TMP_CRL_NAME}.buffer' was successfully created from CRL '${PKI_CRL_INPUT_FILE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_TRUE}
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The CRL buffer file '${PKI_CRL_OUTPUT_PATH}/${TMP_CRL_NAME}.buffer' could not be created from CRL '${PKI_CRL_INPUT_FILE}'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
}

function f_overview_set() {
    #last --since -7days --fulltimes --ip --limit

    if [ "${PKI_CA_OVERVIEW_INPUT_CONF_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CA_OVERVIEW_INPUT_CONF_FILE' must be set with a valid path to a CA configuration file. Multiple values are separated by ', '.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_CA_OVERVIEW_OUTPUT_PATH}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CA_OVERVIEW_OUTPUT_PATH' must be set with a valid path for saving the output HTML file and can not be empty.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    TMP_OVERVIEW_CA_COUNT=$( ${CMD_AWK} -F ', ' '{ print NF }' <<< "${PKI_CA_OVERVIEW_INPUT_CONF_FILE}" )

    # start writing to output variable for HTML code
    ${CMD_ECHO} '<!DOCTYPE html>' > "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '<html lang="de">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '<head>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  <meta charset="UTF-8">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  <meta http-equiv="X-UA-Compatible" content="ie=edge">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  <link rel="icon" type="image/png" href="data:image/png;base64,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">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  <title>Overview PKI</title>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  <style>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      body {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          font-family: Arial;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          margin: 0px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          height: 100%;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      table, th, td {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border: none;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          table-layout: fixed;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          word-wrap: break-word;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      th {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          text-align: left;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      tr {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-radius: 2px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      #menu_tab {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          overflow: hidden;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-bottom: 1px solid #ededed;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          width: 100%;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          min-height: 40px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      #menu_tab button {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          background-color: #cbdceb;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          float: left;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border: none;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          outline: none;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          cursor: pointer;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          padding: 14px 16px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          transition: 0.3s;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          font-size: 17px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} "          width: calc((100% / ${TMP_OVERVIEW_CA_COUNT}) - ((${TMP_OVERVIEW_CA_COUNT} - 1) * 10px));" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-right: solid 1px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-top: solid 1px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-left: solid 1px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-top-left-radius: 10px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-top-right-radius: 10px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          margin-right: 10px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          margin-left: 10px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      #menu_tab button:hover {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          background-color: #6d94c5;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      #menu_tab button.active {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          background-color: #6d94c5;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      .ca_content {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          display: none;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          padding: 6px 12px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      #ca_content_log {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          clear: both;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          padding: 6px 12px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      .ca_content_info_ca {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          width: calc(100% - 12px);' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-radius: 5px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border: solid 1px #ededed;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          min-height: 40px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          padding: 5px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          margin-bottom: 10px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      .ca_content_info_certificates {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          width: calc(50% - 15px);' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          float: left;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          padding: 5px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          margin-top: 10px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-radius: 5px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border: solid 1px #ededed;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      #status {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          padding: 10px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          font-size: 20px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      #status_value {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          font-weight: bolder;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          color: #9dd6ad;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      #ca_content_divider {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          width: 6px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          float: left;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      #log {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          width: calc(100% - 12px);' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border-radius: 5px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          border: solid 1px #ededed;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          height: 40px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          padding: 5px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      .info {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          background-color: #9dd6ad;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      .warning {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          background-color: #fff8d5;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      .error {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          background-color: #ffa4a9 !important;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      @media only screen and (max-width: 800px) {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          /* For mobile phones: */' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          #menu_tab button {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              width: 100%;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              border-top-left-radius: 0px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              border-top-right-radius: 0px;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              border-style: none;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              border-top: solid thin #ededed;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              border-bottom: solid thin #ededed;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          #ca_content_divider {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              display: none;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          .ca_content_info_certificates {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              width: calc(100% - 12px);' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  </style>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  </head>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  <body onload="set_error();">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      <div id="status">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          <p id=status_date>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} "              Date generated: $( ${CMD_DATE} --date 'now' --utc +'%Y-%m-%d %X GMT')" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          </p>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          <p id=status_value>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} "              Status: OK" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          </p>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      <div id="menu_tab">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"

    TMP_IFS=${IFS}
    IFS=', '
    TMP_COUNTER=1
    for i in ${PKI_CA_OVERVIEW_INPUT_CONF_FILE} ; do
        TMP_CA_CONF_CERTIFICATE=$( ${CMD_GREP} --extended-regexp "^certificate\s+=\s+.*$" "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )

        if [[ "${TMP_CA_CONF_CERTIFICATE}" =~ ^\$dir.*$ ]] ; then
            TMP_CA_CONF_DIR=$( ${CMD_GREP} --extended-regexp "^dir\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
            TMP_CA_CONF_CERTIFICATE=$( ${CMD_AWK} -v dir="${TMP_CA_CONF_DIR}" -F '\\$dir' '{ print dir$2 }' <<< "${TMP_CA_CONF_CERTIFICATE}" )
        fi
        if [ "${TMP_CA_CONF_CERTIFICATE}x" == "x" ] || [ ! -f "${TMP_CA_CONF_CERTIFICATE}" ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_INFO}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA certificate filepath with extracted value '${TMP_CA_CONF_CERTIFICATE}' from the CA configuration file '${i}' is not a valid filepath. Skipping the menu creation for the CA on overview HTML file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            continue
        fi
        TMP_CA_CONF_CERTIFICATE_CN=$( ${CMD_OPENSSL} x509 -in "${TMP_CA_CONF_CERTIFICATE}" -text -noout 2>/dev/null | ${CMD_GREP} "Subject:" | ${CMD_AWK} -F 'CN=' '{ print $2 }' | ${CMD_AWK} -F ',' '{ print $1 }' )
        if [ "${TMP_CA_CONF_CERTIFICATE_CN}x" == "x" ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_INFO}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The common name (value: '${TMP_CA_CONF_CERTIFICATE_CN}') could not be extracted from the CA with configuration file '${i}'. Skipping the menu creation for the CA on overview HTML file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html'. ]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            continue
        fi

        ${CMD_ECHO} "          <button class=\"menu_tab_link\" id=\"menu_tab_${TMP_COUNTER}\" onclick=\"set_menu(event, '${TMP_COUNTER}')\">${TMP_CA_CONF_CERTIFICATE_CN}</button>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        TMP_COUNTER=$((TMP_COUNTER+1))
    done

    ${CMD_ECHO} '      </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"

    for i in ${PKI_CA_OVERVIEW_INPUT_CONF_FILE} ; do
        TMP_CA_CERTIFICATES_REVOKED=""
        TMP_CA_CERTIFICATES_VALID=""
        TMP_OVERVIEW_CA_CHECK_DATE=""
        TMP_OVERVIEW_CA_CHECK_NUMBER=""

        TMP_CA_CONF_CERTIFICATE=$( ${CMD_GREP} --extended-regexp "^certificate\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )

        if [[ "${TMP_CA_CONF_CERTIFICATE}" =~ ^\$dir.*$ ]] ; then
            TMP_CA_CONF_DIR=$( ${CMD_GREP} --extended-regexp "^dir\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
            TMP_CA_CONF_CERTIFICATE=$( ${CMD_AWK} -v dir="${TMP_CA_CONF_DIR}" -F '\\$dir' '{ print dir$2 }' <<< "${TMP_CA_CONF_CERTIFICATE}" )
        fi

        if [ "${TMP_CA_CONF_CERTIFICATE}x" == "x" ] || [ ! -f "${TMP_CA_CONF_CERTIFICATE}" ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_INFO}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA certificate filepath with extracted value '${TMP_CA_CONF_CERTIFICATE}' from the CA configuration file '${i}' is not a valid filepath. Skipping the content creation for the CA on overview HTML file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            continue
        fi

        TMP_CA_CONF_CRLDIR=$( ${CMD_GREP} --extended-regexp "^crl_dir\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )

        if [[ "${TMP_CA_CONF_CRLDIR}" =~ ^\$dir.*$ ]] ; then
            TMP_CA_CONF_DIR=$( ${CMD_GREP} --extended-regexp "^dir\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
            TMP_CA_CONF_CRLDIR=$( ${CMD_AWK} -v dir="${TMP_CA_CONF_DIR}" -F '\\$dir' '{ print dir$2 }' <<< "${TMP_CA_CONF_CRLDIR}" )
        fi


        TMP_CA_CONF_CRL=$( ${CMD_GREP} --extended-regexp "^crl\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )

        if [[ "${TMP_CA_CONF_CRL}" =~ ^\$dir.*$ ]] ; then
            TMP_CA_CONF_DIR=$( ${CMD_GREP} --extended-regexp "^dir\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
            TMP_CA_CONF_CRL=$( ${CMD_AWK} -v dir="${TMP_CA_CONF_DIR}" -F '\\$dir' '{ print dir$2 }' <<< "${TMP_CA_CONF_CRL}" )
        fi

        if [[ "${TMP_CA_CONF_CRL}" =~ ^\$crl_dir.*$ ]] ; then
            TMP_CA_CONF_CRL=$( ${CMD_AWK} -v dir="${TMP_CA_CONF_CRLDIR}" -F '\\$crl_dir' '{ print dir$2 }' <<< "${TMP_CA_CONF_CRL}" )
        fi

        TMP_CA_CONF_CERTDB=$( ${CMD_GREP} --extended-regexp "^database\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
        if [[ "${TMP_CA_CONF_CERTDB}" =~ ^\$dir.*$ ]] ; then
            TMP_CA_CONF_DIR=$( ${CMD_GREP} --extended-regexp "^dir\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
            TMP_CA_CONF_CERTDB=$( ${CMD_AWK} -v dir="${TMP_CA_CONF_DIR}" -F '\\$dir' '{ print dir$2 }' <<< "${TMP_CA_CONF_CERTDB}" )
        fi

        if [ "${TMP_CA_CONF_CERTDB}x" == "x" ] || [ ! -f "${TMP_CA_CONF_CERTDB}" ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_INFO}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA database with extracted value '${TMP_CA_CONF_CERTDB}' from the CA configuration file '${i}' is not a valid filepath.  Skipping the content creation for the CA on overview HTML file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            continue
        fi

        TMP_CA_CONF_NEWCERTS=$( ${CMD_GREP} --extended-regexp "^new_certs_dir\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
        if [[ "${TMP_CA_CONF_NEWCERTS}" =~ ^\$dir.*$ ]] ; then
            TMP_CA_CONF_DIR=$( ${CMD_GREP} --extended-regexp "^dir\s+=\s+.*$" < "${i}" 2>/dev/null | ${CMD_AWK} -F '=' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
            TMP_CA_CONF_NEWCERTS=$( ${CMD_AWK} -v dir="${TMP_CA_CONF_DIR}" -F '\\$dir' '{ print dir$2 }' <<< "${TMP_CA_CONF_NEWCERTS}" )
        fi

        if [ "${TMP_CA_CONF_NEWCERTS}x" == "x" ] || [ ! -d "${TMP_CA_CONF_NEWCERTS}" ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_INFO}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA new certificate dir with extracted value '${TMP_CA_CONF_NEWCERTS}' from the CA configuration file '${i}' is not a valid path.  Skipping the content creation for the CA on overview HTML file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            continue
        fi

        TMP_CA_CONF_CERTIFICATE_CN=$( ${CMD_OPENSSL} x509 -in "${TMP_CA_CONF_CERTIFICATE}" -text -noout 2>/dev/null | ${CMD_GREP} "Subject:" | ${CMD_AWK} -F 'CN=' '{ print $2 }' | ${CMD_AWK} -F ',' '{ print $1 }' )

        TMP_OVERVIEW_CA_CHECK=$( ${CMD_GREP} --ignore-case '(event' < "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html" 2>/dev/null | ${CMD_AWK} -F "['><]" '{ print $3,$5 }' | ${CMD_GREP} "${TMP_CA_CONF_CERTIFICATE_CN}" )
        if [ "${TMP_OVERVIEW_CA_CHECK}x" == "x" ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_INFO}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The common name (value: '${TMP_CA_CONF_CERTIFICATE_CN}') could not be found in the already generated menu structure of the CA overview file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html'.  Skipping the content creation for the CA on overview HTML file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            continue
        fi

        TMP_OVERVIEW_CA_CHECK_NUMBER=$( ${CMD_GREP} --ignore-case '(event' < "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html" 2>/dev/null | ${CMD_AWK} -F "['><]" '{ print $3,$5 }' | ${CMD_GREP} "${TMP_CA_CONF_CERTIFICATE_CN}" | ${CMD_AWK} '{ print $1 }' )

        TMP_CA_CONF_CERTIFICATE_SERIAL=$( ${CMD_OPENSSL} x509 -in "${TMP_CA_CONF_CERTIFICATE}" -text -noout 2>/dev/null | ${CMD_GREP} "Serial Number:" | ${CMD_TAIL} --line 1 | ${CMD_AWK} -F ':' '{ print $2 }' | ${CMD_AWK} '{ print $1 }' | ${CMD_XARGS} )
        TMP_CA_CONF_CERTIFICATE_START=$( ${CMD_OPENSSL} x509 -in "${TMP_CA_CONF_CERTIFICATE}" -text -noout 2>/dev/null | ${CMD_GREP} "Not Before" | ${CMD_AWK} -F ': ' '{ print $2 }' )
        TMP_CA_CONF_CERTIFICATE_END=$( ${CMD_OPENSSL} x509 -in "${TMP_CA_CONF_CERTIFICATE}" -text -noout -enddate 2>/dev/null | ${CMD_GREP} "Not After" | ${CMD_AWK} -F ': ' '{ print $2 }' )

        if [ "${TMP_CA_CONF_CERTIFICATE_CN}x" == "x" ] || [ "${TMP_CA_CONF_CERTIFICATE_SERIAL}x" == "x" ] || [ "${TMP_CA_CONF_CERTIFICATE_START}x" == "x" ] || [ "${TMP_CA_CONF_CERTIFICATE_END}x" == "x" ]  ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_INFO}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [Either the common name (value: '${TMP_CA_CONF_CERTIFICATE_CN}'), the serial (value: '${TMP_CA_CONF_CERTIFICATE_SERIAL}'), the start date (value: '${TMP_CA_CONF_CERTIFICATE_START}') or the end date (value: '${TMP_CA_CONF_CERTIFICATE_START}') could not be extracted from the CA with configuration file '${i}'.  Skipping the content creation for the CA on overview HTML file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
            continue
        fi

        # CA certificate status
        TMP_OVERVIEW_CA_CHECK_DATE=$(( ($(date --date="${TMP_CA_CONF_CERTIFICATE_END}" +%s) - $(date --date="now" +%s) )/(60*60*24) ))

        ${CMD_ECHO} "      <div id=\"${TMP_OVERVIEW_CA_CHECK_NUMBER}\" class=\"ca_content\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '          <div class="ca_content_info_ca">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              <h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  CA Certificate Information' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              </h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              <table style="width:100%">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  <tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>CN</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Serial</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Valid From</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Valid To</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  </tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        if [[ "${TMP_OVERVIEW_CA_CHECK_DATE}" -lt "365" ]] && [[ "${TMP_OVERVIEW_CA_CHECK_DATE}" -ge "180" ]] ; then
            ${CMD_ECHO} "              <tr class=\"warning\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        elif [[ "${TMP_OVERVIEW_CA_CHECK_DATE}" -lt "180" ]]; then
            ${CMD_ECHO} "              <tr class=\"error\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        else
            ${CMD_ECHO} "              <tr class=\"info\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        fi
        ${CMD_ECHO} "                      <td>${TMP_CA_CONF_CERTIFICATE_CN}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} "                      <td>${TMP_CA_CONF_CERTIFICATE_SERIAL}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} "                      <td>${TMP_CA_CONF_CERTIFICATE_START}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} "                      <td>${TMP_CA_CONF_CERTIFICATE_END}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  </tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              </table>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '          </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '          <hr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"

        # CA CRL status
        if [ "${TMP_CA_CONF_CRL}x" == "x" ] || [ ! -f "${TMP_CA_CONF_CRL}" ] ; then
            ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_YELLOW}[${TMP_OUTPUT_INFO}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The CA CRL filepath with extracted value '${TMP_CA_CONF_CRL}' from the CA configuration file '${i}' is not a valid filepath. Ignoring CRL file for the CA on overview HTML file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html'.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        else
            TMP_CA_CONF_CRL_START=$( ${CMD_OPENSSL} crl -in "${TMP_CA_CONF_CRL}" -text -noout 2>/dev/null | ${CMD_GREP} "Last Update" | ${CMD_AWK} -F ': ' '{ print $2 }' )
            TMP_CA_CONF_CRL_END=$( ${CMD_OPENSSL} crl -in "${TMP_CA_CONF_CRL}" -text -noout 2>/dev/null | ${CMD_GREP} "Next Update" | ${CMD_AWK} -F ': ' '{ print $2 }' )

            TMP_OVERVIEW_CRL_CHECK_DATE=$(( ($(date --date="${TMP_CA_CONF_CRL_END}" +%s) - $(date --date="now" +%s) )/(60*60*24) ))
            TMP_OVERVIEW_CRL_CHECK_DATE_HOURS=$(( ($(date --date="${TMP_CA_CONF_CRL_END}" +%s) - $(date --date="now" +%s) )/(60*60) ))

            ${CMD_ECHO} '          <div class="ca_content_info_ca">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '              <h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} "                  CA CRL Information ($( if [ "${TMP_OVERVIEW_CRL_CHECK_DATE}x" == "x" ] || [ "${TMP_OVERVIEW_CRL_CHECK_DATE_HOURS}x" == "x" ] ; then ${CMD_ECHO} "?" ; elif [ ${TMP_OVERVIEW_CRL_CHECK_DATE} -gt 0 ] ; then ${CMD_ECHO} "${TMP_OVERVIEW_CRL_CHECK_DATE} days" ; elif [ ${TMP_OVERVIEW_CRL_CHECK_DATE} -le 0 ] && [ ${TMP_OVERVIEW_CRL_CHECK_DATE_HOURS} -gt 0 ]  ; then ${CMD_ECHO} "${TMP_OVERVIEW_CRL_CHECK_DATE_HOURS} hours" ; else ${CMD_ECHO} "0 hours" ; fi ) remaining)" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '              </h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '              <table style="width:100%">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '                  <tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '                      <th>Valid From</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '                      <th>Valid To</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '                  </tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            if [[ "${TMP_OVERVIEW_CRL_CHECK_DATE}" -le "5" ]] && [[ "${TMP_OVERVIEW_CRL_CHECK_DATE}" -ge "1" ]] ; then
                ${CMD_ECHO} "              <tr class=\"warning\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            elif [[ "${TMP_OVERVIEW_CRL_CHECK_DATE}" -lt "1" ]]; then
                ${CMD_ECHO} "              <tr class=\"error\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            else
                ${CMD_ECHO} "              <tr class=\"info\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            fi
            ${CMD_ECHO} "                      <td>${TMP_CA_CONF_CRL_START}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} "                      <td>${TMP_CA_CONF_CRL_END}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '                  </tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '              </table>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '          </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            ${CMD_ECHO} '          <hr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        fi

        # certificate status
        TMP_CA_CERTIFICATES_REVOKED=$( ${CMD_GREP} --extended-regexp "^R" < "${TMP_CA_CONF_CERTDB}" | ${CMD_AWK} -F ' ' '{ $1=$2=$5=""; print $0}' )
        TMP_CA_CERTIFICATES_VALID=$( ${CMD_GREP} --extended-regexp "^V" < "${TMP_CA_CONF_CERTDB}" | ${CMD_AWK} -F ' ' '{ $1=$2=$4=""; print $0 }' )

        ${CMD_ECHO} '          <div class="ca_content_info_certificates">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              <h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  CA Valid Certificates' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              </h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              <table style="width:100%">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  <tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>CN</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Serial</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Valid From</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Valid To</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  </tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"

        while read -r j ; do
            TMP_OVERVIEW_CA_CHECK_DATE=""
            TMP_CA_CERTIFICATES_ELEMENT_CN=""
            TMP_CA_CERTIFICATES_ELEMENT_SERIAL=""
            TMP_CA_CERTIFICATES_ELEMENT_START=""
            TMP_CA_CERTIFICATES_ELEMENT_END=""
            TMP_CA_CERTIFICATES_ELEMENT_CN=$( ${CMD_AWK} '{ $1=""; print $0 }' <<< "${j}" )
            TMP_CA_CERTIFICATES_ELEMENT_SERIAL=$( ${CMD_AWK} '{ print $1 }' <<< "${j}" )
            TMP_CA_CERTIFICATES_ELEMENT_START=$( ${CMD_OPENSSL} x509 -in "${TMP_CA_CONF_NEWCERTS}/${TMP_CA_CERTIFICATES_ELEMENT_SERIAL}.pem" -text -noout 2>/dev/null | ${CMD_GREP} "Not Before" | ${CMD_AWK} -F ': ' '{ print$2 }' )
            TMP_CA_CERTIFICATES_ELEMENT_END=$( ${CMD_OPENSSL} x509 -in "${TMP_CA_CONF_NEWCERTS}/${TMP_CA_CERTIFICATES_ELEMENT_SERIAL}.pem" -text -noout 2>/dev/null | ${CMD_GREP} "Not After" | ${CMD_AWK} -F ': ' '{ print$2 }' )
            TMP_OVERVIEW_CA_CHECK_DATE=$(( ($(date --date="${TMP_CA_CERTIFICATES_ELEMENT_END}" +%s) - $(date --date="now" +%s) )/(60*60*24) ))
            if [ "${TMP_CA_CERTIFICATES_ELEMENT_CN}x" != "x" ] || [ "${TMP_CA_CERTIFICATES_ELEMENT_SERIAL}x" != "x" ] || [ "${TMP_CA_CERTIFICATES_ELEMENT_START}x" != "x" ] || [ "${TMP_CA_CERTIFICATES_ELEMENT_END}x" != "x" ]  ; then
                if [[ "${TMP_OVERVIEW_CA_CHECK_DATE}" -lt "90" ]] && [[ "${TMP_OVERVIEW_CA_CHECK_DATE}" -ge "30" ]] ; then
                    ${CMD_ECHO} "          <tr class=\"warning\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                elif [[ "${TMP_OVERVIEW_CA_CHECK_DATE}" -lt "30" ]] && [[ "${TMP_OVERVIEW_CA_CHECK_DATE}" -gt "0" ]] ; then
                    ${CMD_ECHO} "          <tr class=\"error\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                else
                    ${CMD_ECHO} "          <tr class=\"info\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                fi
                ${CMD_ECHO} "                  <td>${TMP_CA_CERTIFICATES_ELEMENT_CN}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} "                  <td>${TMP_CA_CERTIFICATES_ELEMENT_SERIAL}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} "                  <td>${TMP_CA_CERTIFICATES_ELEMENT_START}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} "                  <td>${TMP_CA_CERTIFICATES_ELEMENT_END}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} '              </tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            fi
        done <<< "${TMP_CA_CERTIFICATES_VALID}"

        ${CMD_ECHO} '              </table>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '          </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '          <div id="ca_content_divider">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              &nbsp;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '          </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '          <div class="ca_content_info_certificates">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              <h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  CA Revoked Certificates' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              </h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              <table style="width:100%">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  <tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>CN</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Serial</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Valid From</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Valid To</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                      <th>Revoke Reason</th>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '                  </tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        while read -r j ; do
            TMP_OVERVIEW_CA_CHECK_DATE=""
            TMP_CA_CERTIFICATES_ELEMENT_CN=""
            TMP_CA_CERTIFICATES_ELEMENT_SERIAL=""
            TMP_CA_CERTIFICATES_ELEMENT_START=""
            TMP_CA_CERTIFICATES_ELEMENT_END=""
            TMP_CA_CERTIFICATES_ELEMENT_CN=$( ${CMD_AWK} '{ $1=$2=""; print $0 }' <<< "${j}" )
            TMP_CA_CERTIFICATES_ELEMENT_REASON=$( ${CMD_AWK} '{ print $1 }' <<< "${j}" )
            TMP_CA_CERTIFICATES_ELEMENT_SERIAL=$( ${CMD_AWK} '{ print $2 }' <<< "${j}" )
            TMP_CA_CERTIFICATES_ELEMENT_START=$( ${CMD_OPENSSL} x509 -in "${TMP_CA_CONF_NEWCERTS}/${TMP_CA_CERTIFICATES_ELEMENT_SERIAL}.pem" -text -noout 2>/dev/null | ${CMD_GREP} "Not Before" | ${CMD_AWK} -F ': ' '{ print$2 }' )
            TMP_CA_CERTIFICATES_ELEMENT_END=$( ${CMD_OPENSSL} x509 -in "${TMP_CA_CONF_NEWCERTS}/${TMP_CA_CERTIFICATES_ELEMENT_SERIAL}.pem" -text -noout 2>/dev/null | ${CMD_GREP} "Not After" | ${CMD_AWK} -F ': ' '{ print$2 }' )
            TMP_OVERVIEW_CA_CHECK_DATE=$(( ($(date --date="${TMP_CA_CERTIFICATES_ELEMENT_END}" +%s) - $(date --date="now" +%s) )/(60*60*24) ))
            if [ "${TMP_CA_CERTIFICATES_ELEMENT_CN}x" != "x" ] || [ "${TMP_CA_CERTIFICATES_ELEMENT_SERIAL}x" != "x" ] || [ "${TMP_CA_CERTIFICATES_ELEMENT_START}x" != "x" ] || [ "${TMP_CA_CERTIFICATES_ELEMENT_END}x" != "x" ]  ; then
                ${CMD_ECHO} "              <tr>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} "                  <td>${TMP_CA_CERTIFICATES_ELEMENT_CN}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} "                  <td>${TMP_CA_CERTIFICATES_ELEMENT_SERIAL}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} "                  <td>${TMP_CA_CERTIFICATES_ELEMENT_START}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} "                  <td>${TMP_CA_CERTIFICATES_ELEMENT_END}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} "                  <td>${TMP_CA_CERTIFICATES_ELEMENT_REASON}</td>" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
                ${CMD_ECHO} '              </tr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
            fi
        done <<< "${TMP_CA_CERTIFICATES_REVOKED}"
        ${CMD_ECHO} '              </table>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '          </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '      </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    done
    IFS=${TMP_IFS}
    # log information

    ${CMD_ECHO} "      <div id=\"ca_content_log\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          <hr>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          <div class="ca_content_info_ca">' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              <h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '                  Log Information' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              </h3>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    while read -r j ; do
        if [[ "${j}" =~ "33m" ]] ; then
            ${CMD_ECHO} "              <p class=\"warning\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        elif [[ "${j}" =~ "31m" ]] ; then
            ${CMD_ECHO} "              <p class=\"error\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        else
            ${CMD_ECHO} "              <p class=\"info\">" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        fi
        ${CMD_ECHO} "                  $( ${CMD_AWK} -F '] ' '{print $2"]",$3}' <<< "${j}" 2>/dev/null | ${CMD_AWK} -F '' '{ print $1 }' )" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
        ${CMD_ECHO} '              </p>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    done <<< $( ${CMD_TAIL} --line 30 < "${TMP_LOG_PATH}" )
    ${CMD_ECHO} '          </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      </div>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  </body>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  <script>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      function set_menu(evt, ca) {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          var i, ca_content, menu_tab_link, tmp_element;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          ca_content = document.getElementsByClassName("ca_content");' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          for (i = 0; i < ca_content.length; i++) {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              ca_content[i].style.display = "none";' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          menu_tab_link = document.getElementsByClassName("menu_tab_link");' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          for (i = 0; i < menu_tab_link.length; i++) {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              menu_tab_link[i].classList.remove("active");' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          set_error();' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          document.getElementById(ca).style.display = "block";' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          evt.currentTarget.classList.remove("error");' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          evt.currentTarget.classList.add("active");' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      function set_error() {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} "          for (let i = 1; i < ${TMP_COUNTER}; i++) {" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              tmp_element = document.getElementById(i).innerHTML;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              tmp_element_name = "";' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} "              if (tmp_element.indexOf('class=\"error\"') !== -1) {" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '                  tmp_element_name = "menu_tab_" + i;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '                  document.getElementById(tmp_element_name).classList.add("error");' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '                  document.getElementById("status_value").style.color = "#ffa4a9";' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '                  document.getElementById("status_value").innerHTML = "Status: Not OK";' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              tmp_element = "";' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          const tmp_date = new Date();' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} "          const tmp_date_gen = new Date(\"$( ${CMD_DATE} --date 'now' --utc +'%Y-%m-%d %X GMT')\");" >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          var tmp_hours = Math.abs(tmp_date - tmp_date_gen) / 36e5;' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          if (tmp_hours > 24) {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              document.getElementById("status_date").style.color = "#ffa4a9";' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              document.getElementById("status_date").append(" (generation date older than 24 hours)");' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          else {' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '              document.getElementById("status_date").style.color = "#9dd6ad";' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '          }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '      }' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  </script>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
    ${CMD_ECHO} '  </html>' >> "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html"
   
    if [ -f "${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The PKI HTML overview file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html' was successfully created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_TRUE}
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The PKI HTML overview file '${PKI_CA_OVERVIEW_OUTPUT_PATH}/pki.html' could not be created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
}

function f_pkcs12_set() {
    if [ "${PKI_KEY_INPUT_PASSWORD}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_PASSWORD' must be set with the valid password for the private key.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_KEY_INPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_KEY_INPUT_FILE' must be set with a valid private key input path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ "${PKI_CERT_INPUT_FILE}x" == "x" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The variable 'PKI_CERT_INPUT_FILE' must be set with a valid certifcate input path.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    if [ -f "${PKI_CERT_INPUT_FILE}.pfx" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} --date 'now' --utc +"%Y%m%d%H%M%SZ" )] [The PKCS#12 output file '${PKI_CERT_INPUT_FILE}.pfx' aready exist. Overriding existent files is not supported.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi

    ${CMD_OPENSSL} pkcs12 -export -inkey "${PKI_KEY_INPUT_FILE}" -in "${PKI_CERT_INPUT_FILE}" -passin "${PKI_KEY_INPUT_PASSWORD_PREFIX}":"${PKI_KEY_INPUT_PASSWORD}" -out "${PKI_CERT_INPUT_FILE}.pfx" 2>/dev/null

    if [ $? -eq ${TMP_TRUE} ] && [ -f "${PKI_CERT_INPUT_FILE}.pfx" ] ; then
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_GREEN}[${TMP_OUTPUT_CHECK}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The PKCS#12 file '${PKI_CERT_INPUT_FILE}.pfx' with private key '${PKI_KEY_INPUT_FILE}' and certificate file '${PKI_CERT_INPUT_FILE}' was successfully created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_TRUE}
    else
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The PKCS#12 file '${PKI_CERT_INPUT_FILE}.pfx' with private key '${PKI_KEY_INPUT_FILE}' and certificate file '${PKI_CERT_INPUT_FILE}' could not be created.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        exit ${TMP_FALSE}
    fi
}

# check log size and rotate if necessary
f_log_verify

# read in parameters
if [ "${2}x" != "x" ] ; then
    f_parameter_set "${2}"
fi

# decision execution
case "${1}" in
    "ca_create")       
        f_ca_set
        ;;
    "cert_create")
        f_cert_set
        if [ $? -eq ${TMP_TRUE} ] ; then
            exit ${TMP_TRUE}
        else
            exit ${TMP_FALSE}
        fi
        ;;
    "cert_revoke")
        f_cert_unset
        ;;
    "crl_create")
        f_crl_set
        ;;
    "crl_buffer")
        f_crl_copy
        ;;
    "key_create")
        f_key_set
        if [ $? -eq ${TMP_TRUE} ] ; then
            exit ${TMP_TRUE}
        else
            exit ${TMP_FALSE}
        fi
        ;;
    "req_create")
        f_req_set
        if [ $? -eq ${TMP_TRUE} ] ; then
            exit ${TMP_TRUE}
        else
            exit ${TMP_FALSE}
        fi
        ;;
    "overview_create")
        f_overview_set
        ;;
    "pkcs12_create")
        f_pkcs12_set
        ;;
    *)
        ${CMD_ECHO} -e "${TMP_OUTPUT_COLOR_RED}[${TMP_OUTPUT_CROSS}] [$( ${CMD_DATE} -d 'now' -u +"%Y%m%d%H%M%SZ" )] [The PKI script option '${1}' is not a valid one. Please use one of the following options:\n\tca_create\t: Create a new root or intermediate CA.\n\tcert_create\t: Sign a certificate with a existent CA.\n\tcert_revoke\t: Revoke a certificate from a existent CA.\n\tcrl_create\t: Create a CRL for a existent CA.\n\tcrl_buffer\t: Copy a CRL from a existent CA to another file.\n\tkey_create\t: Create a new private key for a certificate or request.\n\treq_create\t: Create a new request with a private key.\n\toverview_create\t: Create a basic CA overview with essential informations as a plain HTML file with Javascript and CSS.\n\tpkcs12_create\t: Create a PKCS#12 file from a private key and the corresponding certificate file.]${TMP_OUTPUT_COLOR_RESET}" | if [ "${PKI_SCRIPT_OUTPUT}x" != "1x" ] ; then ${CMD_TEE} --append "${TMP_LOG_PATH}" >/dev/null ; else ${CMD_TEE} --append "${TMP_LOG_PATH}" ; fi
        ;;
esac

# unset all PKI environment variables
f_parameter_unset
