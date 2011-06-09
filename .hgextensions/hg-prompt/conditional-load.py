import sys

req_version = (2,5)
cur_version = sys.version_info

if cur_version[0] > req_version[0] or (cur_version[0] == req_version[0] and cur_version[1] >= req_version[1]):
    import prompt
