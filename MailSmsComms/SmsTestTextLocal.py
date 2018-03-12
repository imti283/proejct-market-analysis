#!/usr/bin/env python

import urllib.request
import urllib.parse


def getGroups(apikey):
    data = urllib.parse.urlencode({'apikey': apikey})
    data = data.encode('utf-8')
    request = urllib.request.Request("https://api.textlocal.in//?")
    f = urllib.request.urlopen(request, data)
    fr = f.read()
    return (fr)


resp = getGroups('r')
print(resp)