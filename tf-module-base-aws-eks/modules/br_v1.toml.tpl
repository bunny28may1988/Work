[settings.kubernetes]
"cluster-name" = "${cluster_name}"
"api-server" = "${api_ep}"
"cluster-certificate" = "${cert_auth}"

[settings.bootstrap-containers.cis-bootstrap]
source = "071833543603.dkr.ecr.ap-south-1.amazonaws.com/bottlerocket-cis-bootstrap-image:latest"
mode = "always"



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
https-proxy = "http://172.16.0.150:8080"
no-proxy = ["localhost", "127.0.0.1"]