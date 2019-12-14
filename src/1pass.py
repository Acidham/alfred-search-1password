#!/usr/bin/python

import json
import os

from Alfred import Items, Tools

# 1Password Cache Dir
CACHE_BASE_DIR = "Library/Containers/com.agilebits.onepassword7/Data/Library/Caches/Metadata/1Password"
user_dir = os.path.expanduser('~')
pass_lib = os.path.join(
    user_dir, CACHE_BASE_DIR)

query = Tools.getArgv(1)
vaults = Tools.getEnv('vaultNames').split(',')


def get_passwords(pass_lib):
    """
    Get all Password items stored in 1Password

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


wf = Items()
# Inform user if 3rd Party integration is disabled
# If 3rd party integration is enabled, read all passwords items
if os.path.isdir(pass_lib):
    passwords = get_passwords(pass_lib)
else:
    wf.setItem(
        title="3rd Party Integration in 1Password is disabled!",
        subtitle=u'1Password > Preferences > Advanced > Integratons > [x] Enable Spotlight and 3rd party app integrations',
        valid=False
    )
    wf.addItem()
    passwords = list()


for p in passwords:
    # Add Password item if no vaultNames are defined OR item's vault name in valutName config
    # AND
    # query empty OR query match item title
    if (
        (vaults[0] == str() or p.get('vaultName') in vaults) and
        (query == str() or query.lower() in p.get('itemTitle').lower())
    ):
        uuid = p.get('uuid')
        itemTitle = p.get('itemTitle')
        itemDesc = p.get('itemDescription')
        url = p.get('websiteURLs')[0] if p.get('websiteURLs') else str()

        wf.setItem(
            title=itemTitle,
            subtitle=itemDesc,
            arg=uuid,
            quicklookurl=url
        )
        if url:
            wf.setIcon('purl.png', "image")
            wf.addMod(
                key="cmd",
                subtitle='OPEN: {0}'.format(url),
                arg=url
            )
            wf.addModsToItem()
        wf.addItem()
wf.write()
