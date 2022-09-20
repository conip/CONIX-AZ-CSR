Section: IOS configuration
username admin privilege 15 password Password123
hostname ${hostname}
interface GigabitEthernet2
ip address dhcp
ip nat inside
no shut
exit
crypto ikev2 proposal Azure-Ikev2-Proposal
encryption ${phase_1_encryption}
integrity ${phase_1_integrity}
group ${phase_1_dh_groups}
exit
crypto ikev2 policy Azure-Ikev2-Policy
proposal Azure-Ikev2-Proposal
exit
%{ for peer in ipsec_peer_list ~}
crypto ikev2 keyring AZURE-VNG-keyring
peer ${peer}
address ${peer}
identity address ${peer}
pre-shared-key ${ipsec_preshared_key}
exit
exit
%{ endfor ~}
crypto ikev2 profile IKEv2-PROF-AZURE
%{ for peer in ipsec_peer_list ~}
match identity remote address ${peer} 255.255.255.255
%{ endfor ~} 
identity local address local_ip_outside
authentication remote pre-share
authentication local pre-share
keyring local AZURE-VNG-keyring
lifetime 28800
dpd 10 5 on-demand
exit
crypto ikev2 nat keepalive 3600
crypto isakmp keepalive 10 3 periodic
crypto isakmp nat keepalive 20
crypto ipsec transform-set Azure-TransformSet ${phase_2_encryption} ${phase_2_integrity}
mode tunnel
exit
crypto ipsec df-bit clear
crypto ipsec profile IPSEC-PROF-AZURE
set security-association lifetime kilobytes 102400000
set transform-set Azure-TransformSet
set ikev2-profile IKEv2-PROF-AZURE
set pfs ${phase_2_dh_pfs}
exit
%{ for peer in ipsec_peer_list ~}
interface Tunnel ${index(ipsec_peer_list, peer)+101}
ip address ${bgp_tunnel_int_list[index(ipsec_peer_list,peer)]} 255.255.255.252
ip tcp adjust-mss 1350
tunnel source GigabitEthernet1
tunnel mode ipsec ipv4
tunnel destination ${peer}
tunnel protection ipsec profile IPSEC-PROF-AZURE
exit
%{ endfor ~}
%{ if length(loopback_ip) > 1 ~}
interface loopback100
ip address ${loopback_ip} 255.255.255.255
exit
%{ endif ~}
router bgp ${asn}
%{ for bgp_peer in bgp_peer_list ~}
neighbor ${bgp_peer} remote-as ${peer_asn}
neighbor ${bgp_peer} ebgp-multihop 255
%{ if length(loopback_ip) > 1 ~}
neighbor ${bgp_peer} update-source loopback100
%{ endif ~}
%{ endfor ~}
address-family ipv4
%{ for bgp_peer in bgp_peer_list ~}
neighbor ${bgp_peer} activate
%{ endfor ~}
%{ for prefix in network_list ~}
network ${split("/", prefix)[0]} mask ${cidrnetmask(prefix)}
%{ endfor ~}
%{ for bgp_peer in bgp_peer_list }
ip route ${bgp_peer} 255.255.255.255 Tunnel ${index(bgp_peer_list, bgp_peer)+101} 
%{ endfor ~}
%{ for prefix in network_list ~}
ip route ${split("/", prefix)[0]} ${cidrnetmask(prefix)} Null0
%{ endfor ~}
 


end
wr mem
