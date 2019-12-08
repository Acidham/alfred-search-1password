#!/usr/bin/python

import json
import os

from Alfred import Items, Tools

user_dir = os.path.expanduser('~')
pass_lib = user_dir + "/Library/Containers/com.agilebits.onepassword7/Data/Library/Caches/Metadata/1Password"

query = Tools.getArgv(1)
vaults = Tools.getEnv('vaultNames').split(',') if Tools.getEnv('vaultNames') else ["Personal"]


def get_passwords(pass_lib):
    """
    Get all Passwords stored in 1Password

    Args:
        pass_lib (str): Path to 1Password libraries including user roort

    Returns:
        list(dict): list of dictonaries contain all Passwords
    """
    passwords = list()
    for r, d, f in os.walk(pass_lib):
        for file in f:
            file_path = os.path.join(r, file)
            with open(file_path, 'r') as content:
                passwords.append(json.load(content))
    return passwords


passwords = get_passwords(pass_lib)

wf = Items()

for p in passwords:
    if p.get('vaultName') in vaults and (query == str() or query.lower() in p.get('itemTitle').lower()):
        uuid = p.get('uuid')
        itemTitle = p.get('itemTitle')
        itemDesc = p.get('itemDescription')

        wf.setItem(
            title=itemTitle,
            subtitle=itemDesc,
            arg=uuid
        )
        wf.addItem()


wf.write()
