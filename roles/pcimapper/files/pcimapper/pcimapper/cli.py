import json
import re
import subprocess
from pathlib import Path
from typing import List, Optional

import jc
import typer
from rich.console import Console
from rich.table import Table

from pcimapper.main import (attach_device, detach_device, get_device,
                            get_devices, get_devices_model,
                            get_iommu_group_devices)
from pcimapper.model import Device

typer_app = typer.Typer(pretty_exceptions_enable=False)


@typer_app.command(name="test")
def test_cmd(filename: str):
    # with open(filename) as f:
    #     content = f.read()
    #     jc.parse("lspci", content)

    def read_blocks(file_path):
        with open(file_path, "r") as file:
            content = file.read()
        blocks = content.strip().split("\n\n")
        return blocks

    file_path = filename
    blocks = read_blocks(file_path)
    for block in blocks:
        print(block)
        jc.parse("lspci", block)


@typer_app.command(name="list-json")
def list_json_cmd():
    print(json.dumps(get_devices()))


@typer_app.command(name="list")
def list_cmd(
    columns: List[str] = typer.Option(
        None,
        "--columns",
        "-c",
        help="Columns to display (default: slot, domain, bus, device, class_, vendor, device_id)",
    )
):
    devices = get_devices_model()

    # Get available fields dynamically from the Device model
    available_fields = Device.model_fields.keys()

    # Define default columns
    default_columns = ["slot", "device", "class_", "vendor_id", "device_id"]

    if not columns:
        columns = default_columns

    # Validate requested columns
    invalid_columns = [col for col in columns if col not in available_fields]
    if invalid_columns:
        raise typer.BadParameter(
            f"Invalid columns: {', '.join(invalid_columns)}. Available columns are: {', '.join(available_fields)}"
        )

    # Create a mapping of fields to display names using descriptions or aliases
    column_titles = {
        field: Device.model_fields[field].alias or field.replace("_", " ").title()
        for field in available_fields
    }

    # Initialize the table
    table = Table(title="Devices")
    for column in columns:
        table.add_column(
            column_titles[column], style="cyan" if column == "slot" else "white"
        )

    # Add rows dynamically based on the selected columns
    for device in devices:
        row = [str(getattr(device, column, "") or "") for column in columns]
        table.add_row(*row)

    # Render the table
    console = Console()
    console.print(table)


@typer_app.command(name="attach")
def attach_cmd(device_name: str, machine_name: str):
    attach_device(machine_name=machine_name, device_name=device_name)


@typer_app.command(name="detach")
def detach_cmd(device_name: str, machine_name: str):
    detach_device(machine_name=machine_name, device_name=device_name)


@typer_app.command(name="device-info")
def device_info_cmd(device_name: Optional[str] = None):
    device = get_device(device_name)
    if not device:
        device_names = "\n".join([device["device"] for device in get_devices()])
        raise SystemExit(f"Device not found, choose from:\n {device_names}")
    iommu_devices = get_iommu_group_devices(device["iommugroup"])

    for dev in iommu_devices:
        sys_path = Path(f"/sys/bus/pci/devices/0000:{dev['slot']}")
        print(f"Path in /sys: {sys_path}")
        print(
            f"Vendor ID: {dev['vendor_id']}, Device ID: {dev['device_id']}, Slot: {dev['slot']}\n"
        )
        pci_info = subprocess.check_output(
            ["lspci", "-nnk", "-s", dev["slot"]], text=True
        )
        kernel_driver = re.search("Kernel driver in use: (.*)", pci_info)

        if kernel_driver:
            kernel_driver = kernel_driver.group(1)
            print(f"Kernel driver: {kernel_driver}")
            print(f"To unbind, run:")
            print(
                f"echo '0000:{dev['slot']}' | sudo tee /sys/bus/pci/drivers/{kernel_driver}/unbind"
            )
        else:
            print(f"Kernel driver: None")

        # echo 'options vfio-pci ids=10de:1fb0,10de:10fa' | sudo tee -a /etc/modprobe.d/vfio.conf
        print("\nTo add this to vfio, run:")
        print(
            f"echo 'options vfio-pci ids={device['vendor_id']}:{device['device_id']}' | sudo tee -a /etc/modprobe.d/vfio.conf"
        )
        print("sudo update-initramfs -u\n")

        slot = device["slot"].split(":")[1].split(".")[0]
        print("Add this to libvirt XML:")
        print(
            f"""<hostdev mode='subsystem' type='pci' managed='yes'>
  <source>
    <address domain='0x0000' bus='0x{device['bus']}' slot='0x{slot}' function='0x{device['function']}'/>
  </source>
  <driver name='vfio'/>
</hostdev>
        """
        )


if __name__ == "__main__":
    typer_app()
