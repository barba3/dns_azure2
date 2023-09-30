#!/bin/bash

#DNS API for Azure DNS using pure REST API and doesn't require installing dependencies.
#This file name is "dns_azure2.sh"
#
#Author: Bruno Venturi
#Report Bugs here: https://github.com/barba3/dns_azure2/issues
#
########  Public functions #####################

# Please Read this guide first: https://github.com/acmesh-official/acme.sh/wiki/DNS-API-Dev-Guide

MY_Token="[bearer token]"

MY_AzureSubscriptionId="[azure subscription ID]"
MY_AzureResourceGroupName="[name of the azure resource group containing your DNS zone]"
MY_AzureDnsApiBaseUrl="https://management.azure.com"
MY_AzureDnsZoneName="[your zone name, e.g. example.com]"

#Usage: dns_myapi_add   _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_myapi_add() {
        fulldomain=$1
        txtvalue=$2
        _info "Using myapi"
        _debug fulldomain "$fulldomain"
        _debug txtvalue "$txtvalue"

        fulldomain=$1
        txtvalue=$2

        _debug "First parse the zone names"
        _domain=$MY_AzureDnsZoneName
        _sub_domain="${fulldomain/.$_domain/}"

        _debug _sub_domain $_sub_domain
        _debug _domain "$_domain"

        _info "Adding record"
        if _invoke_rest PUT "subscriptions/$MY_AzureSubscriptionId/resourceGroups/$MY_AzureResourceGroupName/providers/Microsoft.Network/dnsZones/$MY_AzureDnsZoneName/TXT/$_sub_domain?api-version=2018-05-01" "{ \"properties\": { \"TTL\": 3600, \"TXTRecords\": [ { \"value\": [ \"$txtvalue\" ] } ] } }"; then
                if _contains "$response" "$txtvalue"; then
                        _info "Added, OK"
                        return 0
                elif _contains "$response" "The record already exists"; then
                        _info "Already exists, OK"
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
        _debug "$ep"

        export _H1="Content-Type: application/json"
        export _H2="Authorization: Bearer $MY_Token"

        if [ "$m" != "GET" ]; then
                _debug data "$data"
                response="$(_post "$data" "$MY_AzureDnsApiBaseUrl/$ep" "" "$m")"
        else
                response="$(_get "$MY_AzureDnsApiBaseUrl/$ep")"
        fi

        if [ "$?" != "0" ]; then
                _err "error $ep"
                return 1
        fi
        _debug2 response "$response"
        return 0
}
