#!/bin/bash
set -euo pipefail
# Find Ethernet adapter
# Get Bus:Device.Function
# Bus: 6f
# Device number: 00
# Function: 0
# Vendor ID: 10ec
# Device ID: 3000
lspci_output="$(lspci -nn | grep -i killer)"
pci_dev=$(echo $lspci_output | awk '{print $1}')
vendor_id=$(echo $lspci_output | awk -F '[\\[\\]:]' '{print $5}')
product_id=$(echo $lspci_output | awk -F '[\\[\\]:]' '{print $6}')
echo "PCI device: ${pci_dev}"
echo "Vendor ID: ${vendor_id}"
echo "Product ID: ${product_id}"

# # Check current driver in use:
# lspci -nnk -s ${PCI_DEV}
#
# # Check iommu groups
# echo "Using PCI device: ${PCI_DEV}"
# echo "IOMMU devices in same group:"
# for d in /sys/kernel/iommu_groups/*/devices/*; do
#   if [[ $(basename "$d") == "0000:${PCI_DEV}" ]]; then
#     iommu_group=$(basename $(dirname $(dirname $d)))
#     ls "/sys/kernel/iommu_groups/${iommu_group}/devices"
#   fi
# done
#
