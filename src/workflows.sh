#!/bin/bash

WORKFLOW_OUTPUT="";

function WORKFLOW_RESULT {
	vUID="$1";
	vARG="$2";
	vTITLE="$3";
	vSUBTITLE="$4";
	vICON="$5";
	vAUTOCOMPLETE="$6";
	vACTIONABLE="${7:-yes}";
	vTYPE="${8:-default}";

	WORKFLOW_OUTPUT="${WORKFLOW_OUTPUT}  <item uid=\"$vUID\" arg=\"$vARG\" valid=\"$vACTIONABLE\" autocomplete=\"$vAUTOCOMPLETE\" type=\"$vTYPE\">\n"
	WORKFLOW_OUTPUT="${WORKFLOW_OUTPUT}    <title>$vTITLE</title>\n"
	WORKFLOW_OUTPUT="${WORKFLOW_OUTPUT}    <subtitle>$vSUBTITLE</subtitle>\n"
	WORKFLOW_OUTPUT="${WORKFLOW_OUTPUT}    <icon>$vICON</icon>\n"
	WORKFLOW_OUTPUT="${WORKFLOW_OUTPUT}  </item>\n"
}

function WORKFLOW_TOXML {
	if [ -z "${WORKFLOW_OUTPUT}" ]; then
		return;
	fi

	echo -e "<?xml version=\"1.0\"?>";
	echo -e "<items>";
	echo -e "${WORKFLOW_OUTPUT}</items>";
}