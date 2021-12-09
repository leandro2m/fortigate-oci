# data "oci_identity_dynamic_groups" "test_dynamic_groups" {
    #Required
#    compartment_id = var.tenancy_ocid

    #Optional
#    name = "fortigate-high-availability"
#}

data "oci_core_vcns" "vcp_onprem" {
    #Required
    compartment_id = var.network_compartment_ocid

    display_name = "onprem-vcn"

}