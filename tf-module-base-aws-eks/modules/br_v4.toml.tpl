[settings.kubernetes]
"cluster-name" = "${cluster_name}"
"api-server" = "${api_ep}"
"cluster-certificate" = "${cert_auth}"



[settings.kernel]
lockdown = "integrity"

[settings.kernel.modules.sctp]
allowed = false

[settings.kernel.modules.udf]
allowed = false

[settings.kernel.sysctl]

"net.ipv4.conf.all.accept_redirects" = "0"
"net.ipv4.conf.all.log_martians" = "1"
"net.ipv4.conf.all.secure_redirects" = "0"
"net.ipv4.conf.all.send_redirects" = "0"
"net.ipv4.conf.default.accept_redirects" = "0"
"net.ipv4.conf.default.log_martians" = "1"
"net.ipv4.conf.default.secure_redirects" = "0"
"net.ipv4.conf.default.send_redirects" = "0"
"net.ipv6.conf.all.accept_redirects" = "0"
"net.ipv6.conf.default.accept_redirects" = "0"

[settings.network]
https-proxy = "http://${proxy_ip}"
no-proxy = ["localhost", "127.0.0.1" ,"${no_proxy_ip}" ,"169.254.169.254" ,".internal" ,".eks.amazonaws.com" ,".ec2.ap-south-1.amazonaws.com" ,".amazonaws.com"]

