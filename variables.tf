//variables.tf

//provider
variable "tenancy_ocid" {}
variable "region" {}
variable "fingerprint" {}
variable "user_ocid" {}
variable "availablity_domain_name" {}
variable "compartment_ocid" {}
variable "network_compartment_ocid" {}
variable "compute_compartment_ocid" {}
variable "ssh_public_key" {}
variable "private_key_path" {}


//network variables
//hub
variable "vcn_cidr_block_hub" {
  description = "VCN CIDR 10.206.224.0/16"
  default     = ["10.0.0.0/16"]
}
variable "vcn_dns_label_hub" {
  description = "VCN DNS Label"
  default     = "hub"
}

variable "vcn_display_name_hub" {
  description = "VCN Name"
  default     = "HUB_VCN"
}
variable "hub_subnet__mgmt_display_name" {
  description = "Hub mgmt Subnet Name"
  default     = "mgmt-subnet"
}
variable "mgmt_subnet" {
  description = "Mgmt Subnet"
  default     = "10.0.0.0/24"
}
variable "untrust_subnet" {
  description = "Untrust Subnet"
  default     = "10.0.1.0/24"
}
variable "trust_subnet" {
  description = "Trust Subnet"
  default     = "10.0.2.0/24"
}
variable "ha_subnet" {
  description = "HA Subnet"
  default     = "10.0.3.0/24"
}

variable "mgmt_subnet_display_name" {
  description = "Mgmt Subnet Name"
  default     = "mgmt-subnet"
}
variable "untrust_subnet_display_name" {
  description = "Untrust Subnet Name"
  default     = "untrust-subnet"
}
variable "ha_subnet_display_name" {
  description = "HA Subnet Name"
  default     = "ha-subnet"
}
variable "trust_subnet_display_name" {
  description = "Trust Subnet Name"
  default     = "trust-subnet"
}
variable "mgmt_subnet_dns_label" {
  description = "Mgmt Subnet DNS Label"
  default     = "mgmt"
}
variable "untrust_subnet_dns_label" {
  description = "Untrust Subnet DNS Label"
  default     = "untrust"
}
variable "ha_subnet_dns_label" {
  description = "HA Subnet DNS Label"
  default     = "ha"
}
variable "trust_subnet_dns_label" {
  description = "Trust Subnet DNS Label"
  default     = "trust"
}
variable "mgmt_routetable_display_name" {
  description = "Mgmt route table Name"
  default     = "RTB-MGMT"
}
variable "untrust_routetable_display_name" {
  description = "Untrust route table Name"
  default     = "RTB-PUBLIC"
}
variable "vcn_ingress_routetable_display_name" {
  description = "VCN Ingress route table Name"
  default     = "INGRESS"
}
variable "ha_routetable_display_name" {
  description = "HA route table Name"
  default     = "RTB-HA"
}
variable "trust_routetable_display_name" {
  description = "Trust route table Name"
  default     = "RTB-PRIVATE"
}

// spoke A
variable "vcn_cidr_block_spoke_A" {
  description = "CIDR for Spoke A"
  default = "10.10.1.0/24"
}
variable "spokeA_routetable_display_name" {
  description = "SpokeA route table Name"
  default     = "SpokeARouteTable"
}

variable vcn_dns_label_spoke_A {
  description = "Spoke A DNS Label"
  default     = "VCNA"
}
variable vcn_display_name_spoke_A {
  description = "VCN Name"
  default     = "VNC_A"
}
variable "spokeA_subnet" {
  description = "Spoke A Subnet"
  default     = "10.10.1.0/25"
}
variable "spokeA_subnet_display_name" {
  description = "Spoke A Subnet Name"
  default     = "private-vcn-A-subnet"
}
variable "spokeA_subnet_dns_label" {
  description = "SpokeA Subnet DNS Label"
  default     = "VCNA"
}

// Spoke B

variable "vcn_cidr_block_spoke_B" {
  description = "CIDR for Spoke B"
  default = "10.10.2.0/24"
}

variable vcn_dns_label_spoke_B {
  description = "Spoke B DNS Label"
  default     = "VCNB"
}
variable vcn_display_name_spoke_B {
  description = "VCN Name"
  default     = "VNC_B"
}
variable "spokeB_subnet" {
  description = "Spoke B Subnet"
  default     = "10.10.2.0/25"
}
variable "spokeB_subnet_display_name" {
  description = "Spoke B Subnet Name"
  default     = "private-vcn-B-subnet"
}
variable "spokeB_subnet_dns_label" {
  description = "SpokeB Subnet DNS Label"
  default     = "VCNB"
}
variable "spokeB_routetable_display_name" {
  description = "SpokeB route table Name"
  default     = "SpokeBRouteTable"
}

//variable for instance FTGT

variable "vm_image_ocid" {


//FortiGate-VM 7.0.2 PAYG SRIOV 4OCPU for OCI Paravirtualized Mode
    default = "ocid1.image.oc1..aaaaaaaa63jbmfi2lyj7k73ldibrqtufy3ecewterssewodne3cqfxa3fjma"

}

variable "vm_image_linux" {


//FortiGate-VM 7.0.2 PAYG SRIOV 4OCPU for OCI Paravirtualized Mode
    default = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa35s6u7lmfmqtttsb3fmciugki34nigwc7ipov6tntra3sgd5k2xa"

}

variable "instance_shape" {
  default = "VM.Standard2.4"
}

variable "volume_size" {
  default = "50" //GB
}
variable "instance_shape_linux" {
  default = "VM.Standard.E4.Flex"
}

#ACTIVE NODE
variable "mgmt_private_ip_primary_a" {
  default = "10.0.0.11"
}
variable "mgmt_private_ip_primary_b" {
  default = "10.0.0.12"
}

variable "untrust_private_ip_primary_a" {
  default = "10.0.1.11"
}
variable "untrust_private_ip_primary_b" {
  default = "10.0.1.12"
}

variable "untrust_public_ip_lifetime" {
  default = "RESERVED"
  //or EPHEMERAL
}
variable "untrust_floating_private_ip" {
  default = "10.0.1.10"
}


variable "trust_private_ip_primary_a" {
  default = "10.0.2.11"
}
variable "trust_private_ip_primary_b" {
  default = "10.0.2.12"
}


variable "trust_floating_private_ip" {
  default = "10.0.2.10"
}
variable "hb_private_ip_primary_a" {
  default = "10.0.3.11"
}
variable "hb_private_ip_primary_b" {
  default = "10.0.3.12"
}


variable "untrust_subnet_gateway" {
  default = "10.0.1.1"
}
variable "mgmt_subnet_gateway" {
  default = "10.0.0.1"
}
variable "trust_subnet_gateway" {
  default = "10.0.2.1"
}

variable "vcn_cidr" {
  default = "10.0.0.0/8"
}

variable "license_vm-a" {
  default = "./license"
}
variable "bootstrap_vm-a" {
  default = "./userdata/bootstrap_vm-a.tpl"
}

//identity 

