# Architecture & Network Topology

## 1. Environment Topology

The lab is hosted on a bare-metal hypervisor running **VMware Workstation Pro 17** on a dedicated virtual switch (**VMnet8 NAT**).

```
                            [ Host Physical NIC / Internet ]
                                          |
                              [ VMware Virtual NAT Router ]
                                Gateway: 192.168.10.2
                                          |
           +------------------------------+------------------------------+
           |                              |                              |
    +--------------+               +--------------+               +--------------+
    |     DC01     |               |     ADC1     |               | Clients Pool |
    | Server 2022  | <=== Sync ==> | Server 2022  |               | Win10 & Win11|
    |192.168.10.10 |               |192.168.10.40 |               | 10.50, 10.51 |
    +--------------+               +--------------+               +--------------+
      - FSMO Holder                  - Replica DC                   - Domain Joined
      - Primary DNS                  - Secondary DNS                - DHCP Auto
      - DHCP Server                  - Fault Tolerant               - GPO Targets
```

---

## 2. IP Addressing Matrix

| System Identifier | Hostname | Operating System | IP Assignment | IPv4 Address | Subnet Mask | Default Gateway | Preferred DNS | Alternate DNS |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Primary DC** | `DC01` | Windows Server 2022 | **Static** | `192.168.10.10` | `255.255.255.0` | `192.168.10.2` | `127.0.0.1` | `192.168.10.40` |
| **Replica DC** | `ADC1` | Windows Server 2022 | **Static** | `192.168.10.40` | `255.255.255.0` | `192.168.10.2` | `192.168.10.10` | `127.0.0.1` |
| **Client Workstation 1** | `CLIENT-W11` | Windows 11 Enterprise | **DHCP** | `192.168.10.50` | `255.255.255.0` | `192.168.10.2` | `192.168.10.10` | `192.168.10.40` |
| **Client Workstation 2** | `CLIENT-W10` | Windows 10 Pro | **DHCP** | `192.168.10.51` | `255.255.255.0` | `192.168.10.2` | `192.168.10.10` | `192.168.10.40` |

---

## 3. Host System Hardware Allocation

* **Host CPU:** AMD Ryzen 7 5700G (8 Cores, 16 Threads)
* **Host Physical Memory:** 32 GB DDR4 RAM
* **Virtualization Overhead:**
  * DC01: 4 vCPUs, 8,192 MB RAM
  * ADC1: 2 vCPUs, 2,048 MB RAM
  * Win11: 3 vCPUs, 4,096 MB RAM
  * Win10: 2 vCPUs, 4,096 MB RAM
  * *Total Virtual Memory In Use:* ~18 GB RAM (leaving 14 GB for host OS & SIEM collectors).
