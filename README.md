# Template-Samba4-AD
This is my personale Samba4 AD Template for Zabbix 6

# Introduction
This is a fork from https://github.com/Galvy/Template-Samba4-AD and I agree when he stated: "Until today 26/6/2021 there is no decent Zabbix Template (just my own opinion) for monitoring Samba4 AD so I am still using Nagios just for this, until today. Enjoy! This template is tested wind Zabbix Server 5, Centos 7 DC and Zabbix Agent2.". So, I have worked to aggregate more functionality on his template. All changes was tested on Zabbix 6 and Zentyal CE 7.

# Installation
1) install jq with yum or apt install jq

sudo apt-get install jq

2) copy samba4_ad.conf and samba4_count.conf in your zabbix-agent2.d etc folder

Ex: /etc/zabbix/zabbix_agentd2.d/samba4_ad.conf

3) add zabbix user to sudo with visudo

4) allows 'zabbix' user to run all commands without password.
zabbix ALL=NOPASSWD: ALL

5) Allow active-check in your /etc/zabbix/zabbix_agentd2.conf and AllowKey=system.run[*]

6) copy samba4_ad.sh in /usr/local/bin

7) add cron tasks like:

*/15 * * * * /usr/local/bin/samba4_ad.sh doJson > /dev/null 2>&1
*/15 * * * * /usr/local/bin/samba4_counts.sh doCount > /dev/null 2>&1
0 */2 * * * /usr/local/bin/samba4_ad.sh doDbCheck > /dev/null 2>&1
