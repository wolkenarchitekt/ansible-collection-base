from pathlib import Path
import re
import subprocess
import jc
import sys
import pprint
import typer


def get_devices():
    cmd = ["/usr/bin/lspci", "-nnmmv"]
    print(f"Calling {' '.join(cmd)}")
    lspci_output = subprocess.check_output(cmd, text=True)
    return jc.parse('lspci', lspci_output)


def get_device(device: str):
    devices = get_devices()
    result = [_ for _ in devices if _['device'] == device]
    if result:
        return result[0]

def get_iommu_group_devices(iommugroup: int):
    # print(list(Path(f"/sys/kernel/iommu_groups/{iommugroup}/devices").iterdir()))
    return [device for device in get_devices() if device['iommugroup'] == iommugroup]


def main(device_name: str):
    for device in get_devices():
        print(device['device'])
    # device = get_device('Killer E3000 2.5GbE Controller')
    # device = get_device('ASRock Incorporation Ethernet Connection')
    device = get_device(device_name)
    # print(device['vendor_id'], device['device_id'], device['slot'])
    # pprint.pprint(device)
    # print(device)
    # print(device['slot'])
    # print(device['vendor_id'])
    # print(device['device_id'])
    # print(device['iommugroup'])
    iommu_devices = get_iommu_group_devices(device['iommugroup'])

    for dev in iommu_devices:
        sys_path = Path(f"/sys/bus/pci/devices/0000:{dev['slot']}")
        print(sys_path)
        print(dev['vendor_id'], dev['device_id'], dev['slot'])
        # from ipdb import set_trace; set_trace()

        pci_info = subprocess.check_output(['lspci', '-nnk', '-s', dev['slot']], text=True)
        kernel_driver = re.search('Kernel driver in use: (.*)', pci_info)
        if kernel_driver:
            kernel_driver = kernel_driver.group(1)
            print(f"Kernel driver: {kernel_driver}")
            print("To unbind, run:")
            print(f"echo '0000:{dev['slot']}' | sudo tee /sys/bus/pci/drivers/{kernel_driver}/unbind")
        else:
            print(f"Kernel driver: None")


        # for p in sys_path.iterdir():
        #     print(p)


    # echo 'options vfio-pci ids=10de:1fb0,10de:10fa' | sudo tee -a /etc/modprobe.d/vfio.conf


# assert len(get_iommu_group_devices(device['iommugroup'])) == 1
# print(device['slot'])



# for root, dirs, files in os.walk('/sys/kernel/iommu_groups'):
#     for device in os.listdir(os.path.join(root, 'devices')):
#         if device == f"0000:{device['device_id']}":
#             iommu_group = os.path.basename(root)
#             print(os.listdir(f"/sys/kernel/iommu_groups/{iommu_group}/devices"))

# dev_name = ""
# lspci_output = subprocess.check_output(["/usr/bin/lspci", "-nn"], text=True)
# lspci_output_list = lspci_output.split('\n')
#
# data = jc.parse('lspci', lspci_output)
#
#
# # pattern = r"\[(?P<vendor_id>[0-9a-fA-F]+):(?P<product_id>[0-9a-fA-F]+)\]"
# pattern = r"\[(?P<vendor_id>[0-9a-fA-F]+):(?P<product_id>[0-9a-fA-F]+)\]"
# killer_info = [x for x in lspci_output_list if "Ltd. Killer E3000 2.5GbE Controller" in x][0]
# match = re.search(pattern, lspci_output)
# # Extract vendor_id and product_id into a dictionary
# if match:
#     result = {
#         "vendor_id": match.group("vendor_id"),
#         "product_id": match.group("product_id"),
#     }
#
# bus_info = killer_info.split()[0]
# print(result["vendor_id"])
# print(result["product_id"])

if __name__ == '__main__':
    typer.run(main)
    # devices = get_devices()
    # device_name = sys.argv[1]
    # from ipdb import set_trace; set_trace()
    # for device in [x for x in devices if x['device_id'] == '1a1d']:
    #     # print(device['device'], device['vendor_id'])
    #     # pprint.pprint(device)
    #     pprint.pprint(get_iommu_group_devices(iommugroup=device['iommugroup']))
    # device_name = sys.argv[1]
    # main(device_name=device_name)
