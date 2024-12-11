import subprocess

import jc
import typer

from pcimapper.model import Device
from typing import List

typer_app = typer.Typer(pretty_exceptions_enable=False)



def get_devices() -> List[Device]:
    cmd = ["/usr/bin/lspci", "-nnmmv"]
    lspci_output = subprocess.check_output(cmd, text=True)
    devices = jc.parse("lspci", lspci_output)
    return [Device(**device) for device in devices]


def get_device(device_name: str) -> Device:
    devices = [_ for _ in get_devices() if _.device == device_name]
    if devices:
        return devices[0]


def get_iommu_group_devices(iommugroup: str):
    # print(list(Path(f"/sys/kernel/iommu_groups/{iommugroup}/devices").iterdir()))
    return [device for device in get_devices() if device.iommugroup == iommugroup]


def attach_device(
    device_name: str,
    machine_name: str,
):
    device = get_device(device_name=device_name)
    iommu_devices = get_iommu_group_devices(iommugroup=device.iommugroup)
    if len(iommu_devices) > 1:
        raise Exception("More than one device in IOMMU group, not implemented")

    device_xml = f"""
    <hostdev mode='subsystem' type='pci' managed='yes'>
      <source>
        <address domain='0x0000' bus='0x{device.bus}' slot='0x{device.slot}' function='0x{device.function}'/>
      </source>
      <driver name='vfio'/>
    </hostdev>
    """

    # Save the device XML to a temporary file
    with open("/tmp/device.xml", "w") as file:
        file.write(device_xml)

    # Use virsh to attach the device
    subprocess.run(
        ["virsh", "attach-device", machine_name, "/tmp/device.xml"], check=True
    )


def detach_device(device_name: str, machine_name: str):
    device_name = get_device(device_name)
    if not device_name:
        device_names = "\n".join([device["device"] for device in get_devices()])
        raise SystemExit(f"Device not found, choose from:\n {device_names}")
    iommu_devices = get_iommu_group_devices(device_name["iommugroup"])
    if len(iommu_devices) > 1:
        raise Exception("More than one device in IOMMU group, not implemented")

    slot = device_name["slot"].split(":")[1].split(".")[0]
    device_xml = f"""
    <hostdev mode='subsystem' type='pci' managed='yes'>
      <source>
        <address domain='0x0000' bus='0x{device_name['bus']}' slot='0x{slot}' function='0x{device_name['function']}'/>
      </source>
      <driver name='vfio'/>
    </hostdev>
    """

    # Save the device XML to a temporary file
    with open("/tmp/device.xml", "w") as file:
        file.write(device_xml)

    # Use virsh to detach the device
    subprocess.run(
        ["virsh", "detach-device", machine_name, "/tmp/device.xml"], check=True
    )
