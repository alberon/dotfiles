HOST = '0.0.0.0'

# To increase the API rate limit, generate a personal access token here:
#   https://github.com/settings/applications
# Then add this to ~/.grip/settings-local.py:
#   PASSWORD = '<token>'
import os
gripdir = os.path.dirname(os.path.realpath(__file__))
localsettings = os.path.join(gripdir, "settings-local.py")
if os.path.exists(localsettings):
    USERNAME = 'alberon'
    exec(open(localsettings))
