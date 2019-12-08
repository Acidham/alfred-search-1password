#!/bin/bash

source ./workflows.sh;

DEBUG=false;
ONEPASSWORD_METADATA_PATH="$1";
ONEPASSWORD_METADATA_EXT="onepassword-item-metadata";
SEARCH_QUERY="$2";

if [ -z "$SEARCH_QUERY" ]; then
	SEARCH_QUERY=".*";
fi

# search 1password metadata directory for all files
if [ -z "$ONEPASSWORD_METADATA_PATH" ]; then
	echo "please specify the path to the 1Password metadata directory";
	exit;
fi

if [ ! -d "$ONEPASSWORD_METADATA_PATH" ]; then
	echo "specify a valid path for the 1Password metadata directory";
	exit;
fi

# get all the available metadata
ONEPASSWORD_ALL_METADATA=$(/usr/bin/egrep -ihr --include="*.${ONEPASSWORD_METADATA_EXT}" ".*" "${ONEPASSWORD_METADATA_PATH}");
ONEPASSWORD_TITLES=$(echo "$ONEPASSWORD_ALL_METADATA" | grep -ihroE "\"itemTitle\":\".*?\"");
# get only the titles
ONEPASSWORD_TITLES=$(echo "$ONEPASSWORD_TITLES" | sed 's/^.............//' | sed 's/.$//');
# do a search to match the titles, limit results to first 20
MATCHED_LINE_NUM=$(echo "$ONEPASSWORD_TITLES" | grep -in "$SEARCH_QUERY" | cut -f1 -d: | head -20);

if [ "$DEBUG" = true ] ; then
	echo "$MATCHED_LINE_NUM";
fi

# get content of all matching line numbers
ONEPASSWORD_SELECTED_METADATA="";
while read -r LINE_NUM; do

    ONEPASSWORD_SELECTED_METADATA_STRING=$(echo "$ONEPASSWORD_ALL_METADATA" | tail -n +$LINE_NUM | head -n 1);
    ONEPASSWORD_SELECTED_METADATA+=$(bash -c "echo $'\n${ONEPASSWORD_SELECTED_METADATA_STRING}'");

done <<< "$MATCHED_LINE_NUM";



# if no results, do nothjing
if [ -z "$ONEPASSWORD_SELECTED_METADATA" ]; then
	exit;
fi

if [ "$DEBUG" = true ] ; then
	echo "$ONEPASSWORD_SELECTED_METADATA";
fi
# exit;


# results are there, encode any "&" which might be present in url to avoid XML error
# refer: http://mrrena.blogspot.com/2009/07/entityref-expecting-at-line-1.html
ONEPASSWORD_SELECTED_METADATA="${ONEPASSWORD_SELECTED_METADATA//&/&amp;}";


while read -r ONEPASSWORD_ITEM; do

	if [ -z "$ONEPASSWORD_ITEM" ]; then
		continue;
	fi


    ITEM_UUID=$(echo "$ONEPASSWORD_ITEM" | /usr/local/bin/jq -r ".uuid");
    ITEM_TITLE=$(echo "$ONEPASSWORD_ITEM" | /usr/local/bin/jq -r ".itemTitle");
    ITEM_DESCRIPTION=$(echo "$ONEPASSWORD_ITEM" | /usr/local/bin/jq -r ".itemDescription");
    ITEM_URL=$(echo "$ONEPASSWORD_ITEM" | /usr/local/bin/jq -r ".websiteURLs[0]"); # get the first in a list of potentially multiple URLs

    VAULT_UUID=$(echo "$ONEPASSWORD_ITEM" | /usr/local/bin/jq -r ".vaultUUID");

    # add url to subtitle if it exists
    if [[ ! -z "$ITEM_URL" && ! "$ITEM_URL" = "null" ]]; then
    	ITEM_DESCRIPTION="${ITEM_DESCRIPTION} - ${ITEM_URL}";
    fi

    if [ "$DEBUG" = true ] ; then
    	echo "$VAULT_UUID, $ITEM_UUID, $ITEM_DESCRIPTION, $ITEM_URL";
    fi

    vUID="$ITEM_UUID";
	vARG="$ITEM_UUID";
	vTITLE="$ITEM_TITLE";
	vSUBTITLE="$ITEM_DESCRIPTION";
	vICON="";
	vAUTOCOMPLETE="$ITEM_TITLE";

	WORKFLOW_RESULT "$vUID" "$vARG" "$vTITLE" "$vSUBTITLE" "$vICON" "$vAUTOCOMPLETE";

	if [ "$DEBUG" = true ] ; then
		echo "$vUID: $vTITLE, $vSUBTITLE";
	fi


done <<< "$ONEPASSWORD_SELECTED_METADATA";

if [ ! "$DEBUG" = true ] ; then
	WORKFLOW_TOXML;
fi

