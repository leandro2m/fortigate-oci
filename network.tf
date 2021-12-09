# ------ Create HUB VCN
resource "oci_core_vcn" "hub" {
  compartment_id = var.network_compartment_ocid
  cidr_blocks     = var.vcn_cidr_block_hub
  dns_label      = var.vcn_dns_label_hub
  display_name   = var.vcn_display_name_hub
}

// route table management
resource "oci_core_route_table" "mgmt_route_table" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub.id
  display_name   = var.mgmt_routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}
// subnet management

resource "oci_core_subnet" "mgmt-subnet" {
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.hub.id
  cidr_block                 = var.mgmt_subnet
  display_name               = var.mgmt_subnet_display_name
  route_table_id             = oci_core_route_table.mgmt_route_table.id
  dns_label                  = var.mgmt_subnet_dns_label
  security_list_ids          = [oci_core_security_list.allow_all_security_vcn_hub.id]
  prohibit_public_ip_on_vnic = "false"
}

//untrust_route_table
resource "oci_core_route_table" "untrust_route_table" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub.id
  display_name   = var.untrust_routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}
// subnet untrust

resource "oci_core_subnet" "untrust-subnet" {
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.hub.id
  cidr_block                 = var.untrust_subnet
  display_name               = var.untrust_subnet_display_name
  route_table_id             = oci_core_route_table.untrust_route_table.id
  dns_label                  = var.untrust_subnet_dns_label
  security_list_ids          = [oci_core_security_list.allow_all_security_vcn_hub.id]
  prohibit_public_ip_on_vnic = "false"
}

//ha_route_table
resource "oci_core_route_table" "ha_route_table" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub.id
  display_name   = var.ha_routetable_display_name
}
// subnet HA

resource "oci_core_subnet" "ha-subnet" {
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.hub.id
  cidr_block                 = var.ha_subnet
  display_name               = var.ha_subnet_display_name
  route_table_id             = oci_core_route_table.ha_route_table.id
  dns_label                  = var.ha_subnet_dns_label
  security_list_ids          = [oci_core_security_list.allow_all_security_vcn_hub.id]
  prohibit_public_ip_on_vnic = "true"
}


// trust_route_table
resource "oci_core_route_table" "trust_route_table" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub.id
  display_name   = var.trust_routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.drg1.id
  }

}
// subnet Trust

resource "oci_core_subnet" "trust-subnet" {
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.hub.id
  cidr_block                 = var.trust_subnet
  display_name               = var.trust_subnet_display_name
  route_table_id             = oci_core_route_table.trust_route_table.id
  dns_label                  = var.trust_subnet_dns_label
  security_list_ids          = [oci_core_security_list.allow_all_security_vcn_hub.id]
  prohibit_public_ip_on_vnic = "true"
}

# # ------ Create LPG Hub Route Table
resource "oci_core_route_table" "vcn_ingress_route_table" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "VCN-INGRESS"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_private_ip.trust_private_ip.id
    description = "Default_Route"
  }
 //route to Spoke A
  route_rules {
    destination       = var.vcn_cidr_block_spoke_A
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_private_ip.trust_private_ip.id
    description = "to_VCN_A"
  }
  //route to Spoke B
  route_rules {
    destination       = var.vcn_cidr_block_spoke_B
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_private_ip.trust_private_ip.id
    description = "to_VCN_B"
  }

}

//security list AllowAll
resource "oci_core_security_list" "allow_all_security_vcn_hub" {
  compartment_id = var.network_compartment_ocid
  vcn_id         =  oci_core_vcn.hub.id
  display_name   = "AllowAll"
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}
// IGW
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.network_compartment_ocid
  display_name   = "internet-gatway"
  vcn_id         = oci_core_vcn.hub.id
  enabled        = "true"
}

// spoke A

resource "oci_core_vcn" "spoke_A" {
  cidr_block     = var.vcn_cidr_block_spoke_A
  dns_label      = var.vcn_dns_label_spoke_A
  compartment_id = var.network_compartment_ocid
  display_name   = var.vcn_display_name_spoke_A
}

resource "oci_core_subnet" "spoke_A_subnet" {
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.spoke_A.id
  cidr_block                 = var.spokeA_subnet
  display_name               = var.spokeA_subnet_display_name
  route_table_id             = oci_core_route_table.spoke_a_route_table.id
  dns_label                  = var.spokeA_subnet_dns_label
  security_list_ids          = [oci_core_security_list.allow_all_security_vcn_spokeA.id]
  prohibit_public_ip_on_vnic = "true"

}

// route table spokeA
resource "oci_core_route_table" "spoke_a_route_table" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.spoke_A.id
  display_name   = var.spokeA_routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.drg1.id
  }
}

resource "oci_core_security_list" "allow_all_security_vcn_spokeA" {
  compartment_id = var.network_compartment_ocid
  vcn_id         =  oci_core_vcn.spoke_A.id
  display_name   = "AllowAll"
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

// VCN B


resource "oci_core_vcn" "spoke_B" {
  cidr_block     = var.vcn_cidr_block_spoke_B
  dns_label      = var.vcn_dns_label_spoke_B
  compartment_id = var.network_compartment_ocid
  display_name   = var.vcn_display_name_spoke_B
}

resource "oci_core_subnet" "spoke_B_subnet" {
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.spoke_B.id
  cidr_block                 = var.spokeB_subnet
  display_name               = var.spokeB_subnet_display_name
  route_table_id             = oci_core_route_table.spoke_b_route_table.id
  dns_label                  = var.spokeB_subnet_dns_label
  security_list_ids          = [oci_core_security_list.allow_all_security_vcn_spokeB.id]
  prohibit_public_ip_on_vnic = "true"
}

// route table VCN_B
resource "oci_core_route_table" "spoke_b_route_table" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.spoke_B.id
  display_name   = var.spokeB_routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.drg1.id
  }
}

resource "oci_core_security_list" "allow_all_security_vcn_spokeB" {
  compartment_id = var.network_compartment_ocid
  vcn_id         =  oci_core_vcn.spoke_B.id
  display_name   = "AllowAll"
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# ------ Create DRG
resource "oci_core_drg" "drg1" {
  compartment_id = var.network_compartment_ocid
  display_name   = "DRG_HUB"
}

# ------ Attach DRG to Hub VCN
resource "oci_core_drg_attachment" "hub_drg_attachment" {
  drg_id             = oci_core_drg.drg1.id
  display_name       = "Hub_VCN"
  drg_route_table_id = oci_core_drg_route_table.from_firewall_route_table.id

  network_details {
    id   = oci_core_vcn.hub.id
    type = "VCN"
    route_table_id = oci_core_route_table.vcn_ingress_route_table.id
  }
}

# ------ Attach DRG to Spoke A VCN
resource "oci_core_drg_attachment" "spokeA_drg_attachment" {
  drg_id             = oci_core_drg.drg1.id
  vcn_id             = oci_core_vcn.spoke_A.id
  display_name       = "VCN_A"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to Spoke B VCN
resource "oci_core_drg_attachment" "spokeB_drg_attachment" {
  drg_id             = oci_core_drg.drg1.id
  vcn_id             = oci_core_vcn.spoke_B.id
  display_name       = "VCN_B"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ DRG From Firewall Route Table
resource "oci_core_drg_route_table" "from_firewall_route_table" {
  drg_id                           = oci_core_drg.drg1.id
  display_name                     = "From-Firewall"
  import_drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
}
# ------ DRG To Firewall Route Table

resource "oci_core_drg_route_table" "to_firewall_route_table" {
  drg_id       = oci_core_drg.drg1.id
  display_name = "To-Firewall"
}
resource "oci_core_drg_route_table_route_rule" "from_firewall_drg_route_table_route_rule_spoke_A" {
  drg_route_table_id         = oci_core_drg_route_table.from_firewall_route_table.id

  destination                = "10.10.1.0/24"
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.spokeA_drg_attachment.id
  
}
resource "oci_core_drg_route_table_route_rule" "from_firewall_drg_route_table_route_rule_spoke_B" {
  drg_route_table_id         = oci_core_drg_route_table.from_firewall_route_table.id

  destination                = "10.10.2.0/24"
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.spokeB_drg_attachment.id
}

# ------ DRG to Firewall Route Table


resource "oci_core_drg_route_table_route_rule" "vcn_route_tables_rule_spoke_A" {
  drg_route_table_id         = oci_core_drg_route_table.to_firewall_route_table.id

  destination                = "10.10.0.0/24"
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.spokeA_drg_attachment.id
  
}

resource "oci_core_drg_route_table_route_rule" "vcn_route_tables_rule_spoke_B" {
  drg_route_table_id         = oci_core_drg_route_table.to_firewall_route_table.id

  destination                = "10.10.1.0/24"
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.spokeB_drg_attachment.id
  
}
# ------ Add DRG To Firewall Route Table Entry
resource "oci_core_drg_route_table_route_rule" "vcn_route_tables_default_route" {
  drg_route_table_id         = oci_core_drg_route_table.to_firewall_route_table.id

  destination                = "0.0.0.0/0"
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.hub_drg_attachment.id
  
}
# ------ Add DRG To Firewall Route Table Entry
resource "oci_core_drg_route_table_route_rule" "to_firewall_drg_route_table_route_rule" {
  drg_route_table_id         = oci_core_drg_route_table.to_firewall_route_table.id

  destination                = "0.0.0.0/0"
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.hub_drg_attachment.id
  
}

# ---- DRG Route Import Distribution 
resource "oci_core_drg_route_distribution" "firewall_drg_route_distribution" {
  distribution_type = "IMPORT"
  drg_id            = oci_core_drg.drg1.id
  display_name      = "Transit-Spokes"
}

# ---- DRG Route Import Distribution Statements - One
# resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_one" {
#   drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
#   action                    = "ACCEPT"
#   match_criteria {
#     match_type = "DRG_ATTACHMENT_ID"
#     drg_attachment_id = oci_core_drg_attachment.spokeA_drg_attachment.id
#   }
#   priority = "1"
# }

# # ---- DRG Route Import Distribution Statements - Two 
# resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_two" {
#   drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
#   action                    = "ACCEPT"
#   match_criteria {
#     match_type = "DRG_ATTACHMENT_ID"
#     drg_attachment_id = oci_core_drg_attachment.spokeB_drg_attachment.id
#   }
#   priority = "2"
# }

# ------ Default Routing Table for Hub VCN 
resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.hub.default_route_table_id
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }

}

