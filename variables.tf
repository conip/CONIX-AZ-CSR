#------------ AZURE
variable "csr_general_name" {}
variable "csr_az_rg_location" {}
variable "csr_az_rg_name" {}
variable "csr_vnet_cidr" {}
variable "csr_admin_username" {}
variable "csr_admin_password" {}
variable "csr_hostname" {}
variable "csr_bgp_adv_prefixes" {}
variable "csr_bgp_local_asn" {}
variable "csr_bgp_tunnel_int_list" {}
variable "csr_loopback_ip" {}
variable "csr_bgp_peer_list" {}
variable "csr_ipsec_peer_list" {}
variable "peer_asn" {}
variable "ipsec_preshared_key" {}

variable "phase_1_encryption" {
 default = "aes-cbc-256"
}
variable "phase_1_integrity" {
 default = "sha256"
}
variable "phase_1_dh_groups" {
 default = "14"
}
variable "phase_2_encryption" {
 default = "esp-aes-256"
}
variable "phase_2_integrity" {
 default = "exp-sha256-hmac"
}
variable "phase_2_dh_pfs" {
 default = "group14"
}


