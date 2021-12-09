# resource "oci_core_instance" "instance-spoke-b" {
#   availability_domain = var.availablity_domain_name
#   compartment_id      = var.compute_compartment_ocid
#   display_name        = "Instance-B"
#   shape               = var.instance_shape_linux
# 	shape_config {
# 		memory_in_gbs = "16"
# 		ocpus = "1"
# 	}

#   create_vnic_details {
#     subnet_id        = oci_core_subnet.spoke_B_subnet.id
#     display_name     = "Instance_Spoke_B"
#     assign_public_ip = "false"
#     hostname_label   = "spokeB"
#     assign_private_dns_record = "true"
#   }

#   source_details {
#     source_type = "image"
#     source_id   = var.vm_image_linux
#   }



#   //required for metadata setup via cloud-init
#   metadata = {
#     ssh_authorized_keys = var.ssh_public_key

#   }

#   timeouts {
#     create = "60m"
#   }
# }
# // attach untrust interface
