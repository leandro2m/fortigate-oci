resource "oci_core_instance" "vm-a" {
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compute_compartment_ocid
  display_name        = "HUB_OCI_FW1A"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.mgmt-subnet.id
    display_name     = "HUB_OCI_MGMT_PUB_VNIC_FW1A"
    assign_public_ip = "true"
    hostname_label   = "mgmtpubfw1a"
    assign_private_dns_record = "true"
    private_ip       = var.mgmt_private_ip_primary_a
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
    user_data           = base64encode(data.template_file.vm-a_userdata.rendered)

  }

  timeouts {
    create = "60m"
  }
}
// attach untrust interface


resource "oci_core_vnic_attachment" "vnic_attach_untrust_a" {
  depends_on   = [oci_core_instance.vm-a]
  instance_id  = oci_core_instance.vm-a.id
  display_name = "HUB_OCI_EXT_PUB_VNIC_FW1A"

  create_vnic_details {
    subnet_id              = oci_core_subnet.untrust-subnet.id
    display_name           = "HUB_OCI_EXT_PUB_VNIC_FW1A"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.untrust_private_ip_primary_a
  }
}
resource "oci_core_private_ip" "untrust_private_ip" {
  #Get Primary VNIC id
  vnic_id = element(oci_core_vnic_attachment.vnic_attach_untrust_a.*.vnic_id, 0)

  #Optional
  display_name   = "HUB_OCI_EXT_PUB_IP_FW1A"
  hostname_label = "extpubfw1a"
  ip_address     = var.untrust_floating_private_ip
}

resource "oci_core_public_ip" "untrust_public_ip" {
  #Required
  compartment_id = var.compute_compartment_ocid
  lifetime       = var.untrust_public_ip_lifetime

  #Optional
  display_name  = "HUB_OCI_EXT_PUB_PIP_01"
  private_ip_id = oci_core_private_ip.untrust_private_ip.id
}

// attach trust vnic

resource "oci_core_vnic_attachment" "vnic_attach_trust_a" {
  depends_on   = [oci_core_vnic_attachment.vnic_attach_untrust_a]
  instance_id  = oci_core_instance.vm-a.id
  display_name = "HUB_OCI_INT_PRI_VNIC_FW1A"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust-subnet.id
    display_name           = "HUB_OCI_INT_PRI_VNIC_FW1A"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.trust_private_ip_primary_a
  }
}

resource "oci_core_private_ip" "trust_private_ip" {
  depends_on   = [oci_core_vnic_attachment.vnic_attach_untrust_a]
  #Get Primary VNIC id
  vnic_id = element(oci_core_vnic_attachment.vnic_attach_trust_a.*.vnic_id, 0)

  #Optional
  display_name   = "HUB_OCI_INT_PRI_IP_FW1A"
  hostname_label = "intprifw1a"
  ip_address     = var.trust_floating_private_ip
}

resource "oci_core_vnic_attachment" "vnic_attach_hb_a" {
  depends_on   = [oci_core_vnic_attachment.vnic_attach_trust_a]
  instance_id  = oci_core_instance.vm-a.id
  display_name = "HUB_OCI_HA_PRI_VNIC_FW1A"

  create_vnic_details {
    subnet_id              = oci_core_subnet.ha-subnet.id
    display_name           = "HUB_OCI_HA_PRI_VNIC_FW1A"
    assign_public_ip       = false
    skip_source_dest_check = false
    private_ip             = var.hb_private_ip_primary_a
  }
}

data "template_file" "vm-a_userdata" {

  template = file(var.bootstrap_vm-a)

  vars = {
    mgmt_ip                          = var.mgmt_private_ip_primary_a
    mgmt_ip_mask                     = "255.255.255.0"
    untrust_ip                       = var.untrust_private_ip_primary_a
    untrust_ip_mask                  = "255.255.255.0"
    trust_ip                         = var.trust_private_ip_primary_a
    trust_ip_mask                    = "255.255.255.0"
    hb_ip                            = var.hb_private_ip_primary_a
    hb_ip_mask                       = "255.255.255.0"
    hb_peer_ip                       = var.hb_private_ip_primary_b
    untrust_floating_private_ip      = var.untrust_floating_private_ip
    untrust_floating_private_ip_mask = "255.255.255.0"
    trust_floating_private_ip        = var.trust_floating_private_ip
    trust_floating_private_ip_mask   = "255.255.255.0"
    untrust_subnet_gw                = var.untrust_subnet_gateway
    vcn_cidr                         = var.vcn_cidr
    trust_subnet_gw                  = var.trust_subnet_gateway
    mgmt_subnet_gw                   = var.mgmt_subnet_gateway

    tenancy_ocid = var.tenancy_ocid
    //oci_user_ocid = var.oci_user_ocid
    compartment_ocid = var.compute_compartment_ocid

    # license_file_a = file(var.license_vm-a)

  }
}