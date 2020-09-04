[![Maintained by River Point Technology](https://img.shields.io/badge/maintained%20by-River%20Point%20Technology-%235849a6.svg)](https://www.riverpointtechnology.com)
# VMware VCSA-config Module

This repo contains a module for configuring a [VMware VCSA](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.vcsa.doc/GUID-223C2821-BD98-4C7A-936B-7DBE96291BA4.html) vCenter with Nested [VMware](https://www.vmware.com/) hypervisor using [Terraform](https://www.terraform.io/).

The vCenter Server Appliance is a preconfigured Linux virtual machine, which is optimized for running VMware vCenter Server® and the associated services on Linux.

This Module leverages the outputs from the [VCSA Build](https://github.com/rptcloud/terraform-vsphere-vcsa/) Module and the [Nested ESXi](https://github.com/rptcloud/terraform-vsphere-nestedesxi) Module to configure the new VCSA and add the hosts to the cluster.

![Nested ESXi architecture](https://www.vmware.com/content/vmware/vmware-published-sites/us/products/vcenter-server/_jcr_content/parcontainer/image.img.jpg/1592480720032.jpg)

## How do you use this Module?

This repo has the following structure:

* **root folder**: The root folder contains all of the Terraform code necessary to configure standard vSphere components (Datacenter, Compute Cluster, Folders, Distributed Virtual Switch, Resource Pools, etc), and the code to join the Nested ESXi VMs to the Compute Cluster.

Prerequisites/Notes:

* **Both modules (VCSA Build and Nested ESXi) must be run first**: This module uses the outputs from each of the aforementioned modules as inputs to configure VCSA.  If those outputs are not available, this module will fail to run. 
* **Add/remove hosts and Cluster destruction**: If you adjust the host count in the Nested ESXi module, you will need to run/trigger this module again to adjust the VCSA configuration appropriately.  If the environment needs to be destroyed completely, please first disconnect and remove hosts from the Cluster, and destroy in reverse order (VCSA Config, VCSA Build, and Nested ESXi).  The VCSA will need to be manually deleted from your primary cluster as it does not live in .tfstate.