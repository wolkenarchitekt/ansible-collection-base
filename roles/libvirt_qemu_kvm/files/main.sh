#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

IMAGE_DIR="/var/lib/libvirt/images/"

download_images() {
    cd images
    wget -nc https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.4.0-amd64-DVD-1.iso
    wget -nc https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-desktop-amd64.iso
    wget -nc https://releases.ubuntu.com/23.10.1/ubuntu-23.10.1-desktop-amd64.iso
    wget -nc https://www.archlinux.de/download/iso/2024.02.01/archlinux-2024.02.01-x86_64.iso
    sudo rsync --update --progress *.iso "${IMAGE_DIR}"
}

create_storage_pool() {
    local pool=mypool
#     sudo virsh pool-destroy "${pool}"
#     sudo virsh pool-delete "${pool}"
#     sudo virsh pool-undefine "${pool}"

    sudo virsh pool-define-as "${pool}" dir --target "${IMAGE_DIR}"
    sudo virsh pool-autostart "${pool}"
    sudo virsh pool-start "${pool}"
}

setup_network() {
    sudo virsh net-define default.xml
    sudo virsh net-start mynetwork
    sudo virsh net-autostart mynetwork
}

delete_bridge() {
    local bridge_name="${1}"

    sudo ip link set dev ${bridge_name} down
    sudo brctl delbr ${bridge_name}
}

create_bridge() {
    local bridge_name="${1}"

    # todd: "enx3ce1a14b4e83"
    # jesse: "wwx028037ec0200:"
    local interface="${2}"

    if sudo brctl show | grep -q "$bridge_name"; then
        sudo ip link set dev ${bridge_name} down
        sudo brctl delbr ${bridge_name}
    fi

    sudo brctl addbr ${bridge_name}
    #     sudo ip addr add 192.168.122.1/24 dev ${bridge_name}
    sudo brctl addif ${bridge_name} "${interface}"
    sudo ip link set dev ${bridge_name} up

    sudo brctl show ${bridge_name}
}

create_vm() {
    local vm_name="$1"
    local image="$2"

    # osinfo-query os
    local os_variant="$3" # archlinux,debian11,ubuntu22.04

    sudo virt-install \
        --name="${vm_name}" \
        --ram=1024 \
        --vcpus=2 \
        --os-variant=${os_variant} \
        --cdrom="${image}" \
        --disk pool=mypool,size=20 \
        --graphics=spice \
        --network network=default,model=virtio \
        --console pty,target_type=serial \
        --virt-type kvm \
        --noautoconsole
}

create_arch_vm() {
    create_vm arch ${IMAGE_DIR}/archlinux-2024.02.01-x86_64.iso archlinux
}

destroy_vm() {
    local vm_name="$1"

    sudo virsh shutdown ${vm_name}
    sudo virsh undefine ${vm_name}
    sudo virsh destroy ${vm_name}
}

help() {
    echo "Available commands:"
    echo "${ACTIONS}"
}

# Extract all public function names
ACTIONS=$(declare -F | cut -d" " -f3 | grep -E "^[^_]")

main() {
    # Rewrite action write-image -> write_image
    # (using hyphens in function names is discouraged in Shell)
    local ACTION=${1:-}
    ACTION="${ACTION//-/_}"

    case "$ACTION" in
        -h | --help)
            help
            exit 0
            ;;
    esac

    if [ -z "${ACTION}" ]; then
        help
    else
        shift
        ${ACTION} "${@}"
    fi
}

main "${@}"
