check_url
=========
Nagios plugin for checking URLs. Crafted to get more performance information than standard check_http
Uses curl, so nearly all curl command line switches can be used

Toni Comerma
may-2016
 
Performance variables:
size_download
speed_download
time_connect
time_starttransfer
time_total
num_redirects
time_redirect
Note: These are variables provided by curl's --write-out. Check curl documentation for details