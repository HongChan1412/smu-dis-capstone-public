NVD_APIKEY =""

SCRIPT_PATH = {
    "ubuntu": {
        "check": "./scripts/ubuntu/check_ubuntu.sh",
        "weak": "./scripts/ubuntu/weak_ubuntu.sh",
        "r01": "./scripts/ubuntu/resolve_ubuntu_01.sh",
        "r03": "./scripts/ubuntu/resolve_ubuntu_03.sh",
        "r04": "./scripts/ubuntu/resolve_ubuntu_04.sh",
        "r05": "./scripts/ubuntu/resolve_ubuntu_05.sh",
        "r09": "./scripts/ubuntu/resolve_ubuntu_09.sh",
        "r10": "./scripts/ubuntu/resolve_ubuntu_10.sh",
        "r11": "./scripts/ubuntu/resolve_ubuntu_11.sh",
        "r12": "./scripts/ubuntu/resolve_ubuntu_12.sh",
        "r20": "./scripts/ubuntu/resolve_ubuntu_20.sh",
        "r22": "./scripts/ubuntu/resolve_ubuntu_22.sh",
        "r29": "./scripts/ubuntu/resolve_ubuntu_29.sh",
        "r32": "./scripts/ubuntu/resolve_ubuntu_32.sh",
        "r35": "./scripts/ubuntu/resolve_ubuntu_35.sh",
        "r37": "./scripts/ubuntu/resolve_ubuntu_37.sh",
        "r39": "./scripts/ubuntu/resolve_ubuntu_39.sh",
        "r40": "./scripts/ubuntu/resolve_ubuntu_40.sh",
        "r41": "./scripts/ubuntu/resolve_ubuntu_41.sh",
        "r42": "./scripts/ubuntu/resolve_ubuntu_42.sh",
    },
    "centos": {
        "check": "./scripts/centos/check_centos.sh",
        "weak": "./scripts/centos/weak_centos.sh",
        "r01": "./scripts/centos/resolve_centos_01.sh",
        "r05": "./scripts/centos/resolve_centos_05.sh",
        "r06": "./scripts/centos/resolve_centos_06.sh",
        "r10": "./scripts/centos/resolve_centos_10.sh",
        "r12": "./scripts/centos/resolve_centos_12.sh",
        "r17": "./scripts/centos/resolve_centos_17.sh",
        "r19": "./scripts/centos/resolve_centos_19.sh",
        "r22": "./scripts/centos/resolve_centos_22.sh",
        "r29": "./scripts/centos/resolve_centos_29.sh",
        "r32": "./scripts/centos/resolve_centos_32.sh",
        "r35": "./scripts/centos/resolve_centos_35.sh",
        "r36": "./scripts/centos/resolve_centos_36.sh",
        "r40": "./scripts/centos/resolve_centos_40.sh",
        "r41": "./scripts/centos/resolve_centos_41.sh",
    },
    "common": {
        "add": "./scripts/common/add_sudoers.sh",
        "restore": "./scripts/common/restore_sudoers.sh"
    }
}
