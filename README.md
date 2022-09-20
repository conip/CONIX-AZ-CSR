# CONIX-AZ-CSR

```
module "az_csr_1" {
  # NOTE: This module utilizes the CSR1K BYOL offer in the Azure marketplace. To subscribe to the offer:
  # Get-AzureRmMarketplaceTerms -Publisher "cisco" -Product "cisco-csr-1000v" -Name "17_3_3-byol" | Set-AzureRmMarketplaceTerms -Accept
  #
  # Azure CSR deployment and connection to VNG
  source                  = "git::https://github.com/conip/CONIX-AZ-CSR.git"
  csr_general_name        = "csr1-test"
  csr_az_rg_location      = "West Europe"
  csr_az_rg_name          = "RG-CSR"
  csr_admin_username      = "przemek"
  csr_admin_password      = "Alamakota$123"
  csr_hostname            = "csr1"
  csr_vnet_cidr           = "10.222.0.0/16"
  csr_bgp_adv_prefixes    = ["10.41.1.0/24", "10.41.2.0/24"]
  csr_bgp_local_asn       = "65001"
  csr_loopback_ip         = ""                                       # if not empty - will be used for source BGP for all members from peer list
  csr_bgp_tunnel_int_list = ["192.168.1.1", "192.168.2.1"]
  csr_bgp_peer_list       = ["192.168.1.2", "192.168.2.2"]
  csr_ipsec_peer_list     = ["52.233.239.168", "52.233.239.159"]
  peer_asn                = "65010"
  ipsec_preshared_key     = "AvXtest$123"
}
```

# result of the ebove example is the following 

```Section: IOS configuration
username admin privilege 15 password Password123
hostname test
interface GigabitEthernet2
ip address dhcp
ip nat inside
no shut
exit
crypto ikev2 proposal Azure-Ikev2-Proposal
encryption aes-cbc-256
integrity sha256
group 2
exit
crypto ikev2 policy Azure-Ikev2-Policy
proposal Azure-Ikev2-Proposal
exit
crypto ikev2 keyring AZURE-VNG-keyring
peer 52.233.239.168
address 52.233.239.168
identity address 52.233.239.168
pre-shared-key test
exit
exit
crypto ikev2 keyring AZURE-VNG-keyring
peer 52.233.239.159
address 52.233.239.159
identity address 52.233.239.159
pre-shared-key test
exit
exit
crypto ikev2 profile IKEv2-PROF-AZURE
match identity remote address 52.233.239.168 255.255.255.255
match identity remote address 52.233.239.159 255.255.255.255
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
crypto ipsec transform-set Azure-TransformSet esp-aes 256 esp-sha256-hmac
mode tunnel
exit
crypto ipsec df-bit clear
crypto ipsec profile IPSEC-PROF-AZURE
set security-association lifetime kilobytes 102400000
set transform-set Azure-TransformSet
set ikev2-profile IKEv2-PROF-AZURE
exit
interface Tunnel 101
ip address 192.168.1.1 255.255.255.252
ip tcp adjust-mss 1350
tunnel source GigabitEthernet1
tunnel mode ipsec ipv4
tunnel destination 52.233.239.168
tunnel protection ipsec profile IPSEC-PROF-AZURE
exit
interface Tunnel 102
ip address 192.168.2.1 255.255.255.252
ip tcp adjust-mss 1350
tunnel source GigabitEthernet1
tunnel mode ipsec ipv4
tunnel destination 52.233.239.159
tunnel protection ipsec profile IPSEC-PROF-AZURE
exit
router bgp 65001
neighbor 192.168.1.2 remote-as 65010
neighbor 192.168.1.2 ebgp-multihop 255
neighbor 192.168.2.2 remote-as 65010
neighbor 192.168.2.2 ebgp-multihop 255
address-family ipv4
neighbor 192.168.1.2 activate
neighbor 192.168.2.2 activate
network 10.41.1.0 mask 255.255.255.0
network 10.41.2.0 mask 255.255.255.0

ip route 192.168.1.2 255.255.255.255 Tunnel 101 

ip route 192.168.2.2 255.255.255.255 Tunnel 102 
ip route 10.41.1.0 255.255.255.0 Null0
ip route 10.41.2.0 255.255.255.0 Null0
 


end
wr mem
```
