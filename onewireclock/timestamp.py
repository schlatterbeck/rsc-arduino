#!/usr/bin/python
from time import strftime, gmtime, localtime

print int (strftime ("%s", localtime ())) + 3600
