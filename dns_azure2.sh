#!/bin/bash

#DNS API for Azure DNS using pure REST API and doesn't require installing dependencies.
#This file name is "dns_azure2.sh"
#
#Author: Bruno Venturi
#Report Bugs here: https://github.com/barba3/dns_azure2/issues
#
########  Public functions #####################

# Please Read this guide first: https://github.com/acmesh-official/acme.sh/wiki/DNS-API-Dev-Guide

MY_AzureTenantId="[azure tenant id]"
MY_AzureSubscriptionId="[azure subscription ID]"
MY_AzureClientId="[app registration client id]"
MY_AzureClientSecret="[app secret]"
MY_AzureResourceGroupName="[name of the azure resource group containing your DNS zone]"
MY_AzureDnsApiBaseUrl="https://management.azure.com"
MY_AzureTokenUrl="https://login.microsoftonline.com/$MY_AzureTenantId/oauth2/v2.0/token"
MY_AzureDnsZoneName="[your zone name, e.g. example.com]"
MY_AzureScope="https://management.azure.com/.default"

#Usage: dns_myapi_add   _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_myapi_add() {
        fulldomain=$1
        txtvalue=$2
        _info "Using myapi"
        _debug fulldomain "$fulldomain"
        _debug txtvalue "$txtvalue"

        fulldomain=$1
        txtvalue=$2

        _debug "Parse the zone names"
        _domain=$MY_AzureDnsZoneName
        _sub_domain="${fulldomain/.$_domain/}"

        _debug _sub_domain $_sub_domain
        _debug _domain "$_domain"

        _info "Authenticating with Azure"
        _auth_result="$(_post "client_id=$MY_AzureClientId&scope=$MY_AzureScope&client_secret=$MY_AzureClientSecret&grant_type=client_credentials" "$MY_AzureTokenUrl" "" "POST")"

        _secure_debug _auth_result "$_auth_result"
        _access_token="${_auth_result#*\"access_token\":\"}"
        _access_token="${_access_token%%\"*}"
        _secure_debug _access_token $_access_token

        _info "Adding record"
        if _invoke_rest PUT "$MY_AzureDnsApiBaseUrl/subscriptions/$MY_AzureSubscriptionId/resourceGroups/$MY_AzureResourceGroupName/providers/Microsoft.Network/dnsZones/$MY_AzureDnsZoneName/TXT/$_sub_domain?api-version=2018-05-01" "{ \"properties\": { \"TTL\": 3600, \"TXTRecords\": [ { \"value\": [ \"$txtvalue\" ] } ] } }" "$_access_token"; then

                _debug response $response
                if _contains "$response" "$txtvalue"; then
                        _info "Added, OK"
                        return 0
                else
                        _err "Add txt record error."
                        return 1
                fi
        fi

        _err "Add txt record error."
        return 1

        if [ "$?" != "0" ]; then
                return 1
        fi
}

#Usage: fulldomain txtvalue
#Remove the txt record after validation.
dns_myapi_rm() {
  fulldomain=$1
  txtvalue=$2
  _info "Using myapi"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"
}

####################  Private functions below ##################################

_invoke_rest() {
        m=$1
        ep="$2"
        data="$3"
        accessToken="$4"
        _debug "$ep"

        export _H1="Content-Type: application/json"
        export _H2="Authorization: Bearer $accessToken"

        if [ "$m" != "GET" ]; then
                _debug data "$data"
                response="$(_post "$data" "$ep" "" "$m")"
        else
                response="$(_get "$ep")"
        fi

        if [ "$?" != "0" ]; then
                _err "error $ep"
                return 1
        fi
        _debug2 response "$response"
        return 0
}
