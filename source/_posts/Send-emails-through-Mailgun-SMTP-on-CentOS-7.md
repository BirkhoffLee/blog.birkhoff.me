---
title: Send emails through Mailgun SMTP on CentOS 7
tags: |-

  - devops
  - server
  - linux
  - tutorial
permalink: send-email-thru-mailgun-on-centos-7
id: 5b5e684156639d0001318ca5
updated: '2018-08-08 15:06:41'
date: 2018-07-30 09:22:09
---

Install the dependencies:
```
$ yum install postfix cyrus-sasl-plain cyrus-sasl-md5 mailx -y
```

In `/etc/postfix/main.cf`, append the following to the end of file:

```
relayhost = smtp.mailgun.org
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
smtp_sasl_mechanism_filter = AUTH LOGIN
```

Run the following to configure the authentication details:
```
$ echo 'smtp.mailgun.org postmaster@<mailgun_host>:<mailgun_credentials>' > /etc/postfix/sasl_passwd
$ chmod 600 /etc/postfix/sasl_passwd
$ postmap /etc/postfix/sasl_passwd
$ systemctl restart postfix
```

And finally test it out!
```
$ mail -s "Test mail" your_email@example.com <<< "A test message using Mailgun"
$ cat /var/log/maillog
```

## References
* https://support.rackspace.com/how-to/setting-up-a-mail-relay/
* https://hakanu.net/linux/2017/04/23/making-crontab-send-email-through-mailgun/
* https://serverfault.com/questions/208882/on-centos-mail-or-mutt-never-sends-my-emails
