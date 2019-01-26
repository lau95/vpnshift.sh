vpnshift
========


Fork proposal to add a client/server functionnality
---------------------------------------------------

*First please read carefull the whole document and especially hereunder :

Don't depend on this for anything serious (yet). If you do use this,
make sure to verify that the VPN connection is active, since the network
namespace abstraction is leaky with real-world applications like Google
Chrome.*

This fork of vpnshift aims to add a client/server fonctionnality of vpnshift
genuine tool.

To make it work :

	1/ copy the files below to an appropriate directory on your system
	   e.g. /opt/vpnshift
		vpnshift-client-open.sh
		vpnshift-launcher.sh
		vpnshift-server-open.sh
		vpnshift.sh

	2/ create a systemd service where 
		ExecStart=/opt/vpnshift/vpnshift-launcher.sh -a <your openvpn config file whole path>
		ExecStop=/opt/vpnshift/vpnshift-launcher.sh -o $MAINPID


	3/ create the vpn-client-allowed.conf
		under /usr/local/etc/vpnshift/
		base on the delivered template
		fill it dynamically to authorize client launchs (of any kinds,web browsers but not only)
		be carefull to keep it read restriced to root

	4/ modify or create clones of your applications to run under VPN
		e.g. desktop files under /usr/share/applications/ for gnome
		in the "Exec" lines, add /opt/vpnshift/vpnshift-client-open.sh as a launcher
			with the rest of the command in arguments

To understand vpnshift by itself please read the rest of this document

Guenuine vpnshift README :
--------------------------


vpnshift lets you run commands in an isolated network namespace with
openvpn.

This means that a program launched by vpnshift can conveniently have VPN
access while all other programs have normal internet access, without
resorting to running it under different user accounts or inside a
virtual machine.

This is particularly useful for not sending existing browser tabs or
long-running daemon traffic (like dropbox or syncthing) through your VPN.

    $ vpnshift -c myopenvpn.conf chromium --incognito
    starting openvpn..................
    <stdout and stderr from chromium>
    stopping openvpn...
    $

Once the command exits, openvpn is terminated and the namespace is torn
down.

For more usage information, run vpnshift with no arguments.

    $ vpnshift

Warnings
--------

Google Chrome and Chromium will breach the network namespace if you open
tabs both in the default namespace and inside vpnshift's namespace,
since they'll be in the same browsing session.

As a workaround, you can use completely separate browsers.

Alternatively, you can point Google Chrome/Chromium to a new
`--user-data-directory` manually (with that flag), or with
[chromeshift][].

  [chromeshift]: https://github.com/crasm/chromeshift

Limitations
-----------
- Only one network namespace ("vpnshift") can currently be used. This
  will be expanded in the future so multiple VPNs can be run
  simultaneously.
- The subnet for the veth tunnel is hard-coded to 10.10.10.10/31.
  (Determining the IP addresses is a major paint-point of the bullet
  above.)
- DNS nameservers pushed by openvpn are not recognized properly. The
  nameservers are hard-coded to [cryptostorm's][cs] DNS: [cs-ussouth2][]
  (108.62.19.131) and [cs-uswest2][] (104.238.194.235). DNS traffic is
  still forwarded through the VPN.

  [cs]:          https://cryptostorm.is/
  [cs-ussouth2]: https://github.com/jedisct1/dnscrypt-proxy/blob/1.7.0/dnscrypt-resolvers.csv#L19
  [cs-uswest2]:  https://github.com/jedisct1/dnscrypt-proxy/blob/1.7.0/dnscrypt-resolvers.csv#L21

Dependencies
------------
  - linux
  - bash
  - sudo
  - openvpn
  - iptables

Acknowledgements
----------------

I was first shown the power of network namespaces by [vpnns.sh][], which
inspired (and provided a helpful starting point) for vpnshift.  I used a
modified version of that script while I was still trying to get vpnshift
to work.

[vpnns.sh]: https://gist.github.com/Schnouki/fd171bcb2d8c556e8fdf

Similar Projects
----------------

[ocproxy/vpnns](https://github.com/cernekee/ocproxy#vpnns-experimental)
