"""Override httplib.HTTPConnection to cache the results.

Python's builtin httplib does a dns query for every connect.
This makes it very expensive, so lets cache the results.
"""

import socket

from bzrlib.trace import mutter,note
import bzrlib.transport


_getaddrinfo = socket.getaddrinfo


_host_to_addrinfo = {}

def getaddrinfo(host, port, *args, **kwargs):
    key = (host, port, args, tuple(sorted(kwargs.items())))
    if key not in _host_to_addrinfo:
        mutter('getaddrinfo cache miss for %s:%s', host, port)
        _host_to_addrinfo[key] = _getaddrinfo(host, port, *args, **kwargs)
    else:
        mutter('getaddrinfo cache hit for %s:%s', host, port)
    return _host_to_addrinfo[key]

socket.getaddrinfo = getaddrinfo


## pycurl seems to be having the same problem, but the above monkey patch
## doesn't get used. So in the meantime, disable pycurl if this plugin is active
## All this does is re-register the _urllib version, which causes it to be prefered
## to pycurl

bzrlib.transport.register_lazy_transport('http://', 'bzrlib.transport.http._urllib',
                        'HttpTransport_urllib')
