resource "oci_core_instance" "vm-b" {
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compute_compartment_ocid
  fault_domain = "FAULT-DOMAIN-2"
  display_name        = "HUB_OCI_FW1B"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.mgmt-subnet.id
    display_name     = "HUB_OCI_MGMT_PUB_VNIC_FW1B"
    assign_public_ip = "true"
    hostname_label   = "mgmtpubfw1b"
    assign_private_dns_record = "true"
    private_ip       = var.mgmt_private_ip_primary_b
  }

  source_details {
    source_type = "image"
    source_id   = var.vm_image_ocid

    //for PIC image: source_id   = var.vm_image_ocid

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true


  //required for metadata setup via cloud-init
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # user_data           = "${base64encode(data.template_file.vm-b_userdata.rendered)}"

  }

  timeouts {
    create = "60m"
  }
}
// attach untrust interface


resource "oci_core_vnic_attachment" "vnic_attach_untrust_b" {
  depends_on   = [oci_core_instance.vm-b]
  instance_id  = oci_core_instance.vm-b.id
  display_name = "HUB_OCI_EXT_PUB_VNIC_FW1B"

  create_vnic_details {
    subnet_id              = oci_core_subnet.untrust-subnet.id
    display_name           = "HUB_OCI_EXT_PUB_VNIC_FW1B"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.untrust_private_ip_primary_b
  }
}

// attach trust vnic

resource "oci_core_vnic_attachment" "vnic_attach_trust_b" {
  depends_on   = [oci_core_vnic_attachment.vnic_attach_untrust_b]
  instance_id  = oci_core_instance.vm-b.id
  display_name = "HUB_OCI_INT_PRI_VNIC_FW1B"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust-subnet.id
    display_name           = "HUB_OCI_INT_PRI_VNIC_FW1B"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.trust_private_ip_primary_b
  }
}


resource "oci_core_vnic_attachment" "vnic_attach_hb_b" {
  depends_on   = [oci_core_vnic_attachment.vnic_attach_trust_b]
  instance_id  = oci_core_instance.vm-b.id
  display_name = "HUB_OCI_HA_PRI_VNIC_FW1B"

  create_vnic_details {
    subnet_id              = oci_core_subnet.ha-subnet.id
    display_name           = "HUB_OCI_HA_PRI_VNIC_FW1B"
    assign_public_ip       = false
    skip_source_dest_check = false
    private_ip             = var.hb_private_ip_primary_b
  }
}

# data "template_file" "vm-b_userdata" {

#   template = file(var.bootstrap_vm-b)

#   vars = {
#     mgmt_ip                          = var.mgmt_private_ip_primary_b
#     mgmt_ip_mask                     = "255.255.255.0"
#     untrust_ip                       = var.untrust_private_ip_primary_b
#     untrust_ip_mask                  = "255.255.255.0"
#     trust_ip                         = var.trust_private_ip_primary_b
#     trust_ip_mask                    = "255.255.255.0"
#     hb_ip                            = var.hb_private_ip_primary_b
#     hb_ip_mask                       = "255.255.255.0"
#     hb_peer_ip                       = var.hb_private_ip_primary_b
#     untrust_floating_private_ip      = var.untrust_floating_private_ip
#     untrust_floating_private_ip_mask = "255.255.255.0"
#     trust_floating_private_ip        = var.trust_floating_private_ip
#     trust_floating_private_ip_mask   = "255.255.255.0"
#     untrust_subnet_gw                = var.untrust_subnet_gateway
#     vcn_cidr                         = var.vcn_cidr
#     trust_subnet_gw                  = var.trust_subnet_gateway
#     mgmt_subnet_gw                   = var.mgmt_subnet_gateway

#     tenancy_ocid = var.tenancy_ocid
#     //oci_user_ocid = var.oci_user_ocid
#     compartment_ocid = var.compute_compartment_ocid

#     # license_file_a = file(var.license_vm-a)

#   }
# }