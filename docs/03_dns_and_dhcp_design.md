# Active Directory DNS & DHCP Architecture

## 1. Domain Name System (DNS) Design

Active Directory is inextricably bound to DNS. Domain members discover Domain Controllers, Global Catalogs, and Kerberos Key Distribution Centers (KDCs) exclusively through DNS Service (`SRV`) records.

### Forward Lookup Zone: `mahialjaber.me`
* **Zone Type:** Active Directory-Integrated Primary Zone.
* **Storage & Replication:** Stored in the `DomainDnsZones` application directory partition; automatically replicated multi-master between `DC01` and `ADC1`.
* **Dynamic Updates:** Set to **Secure Only** (only authenticated Active Directory security principals can register/update their host records, mitigating DNS spoofing).

### Critical Active Directory SRV Records
Domain members query the following DNS SRV records to discover domain services:
```
_ldap._tcp.dc._msdcs.mahialjaber.me       --> Points to DC Port 389 (LDAP)
_kerberos._tcp.dc._msdcs.mahialjaber.me   --> Points to DC Port 88 (Kerberos KDC)
_kpasswd._tcp.dc._msdcs.mahialjaber.me   --> Points to DC Port 464 (Kerberos Password Change)
_gc._tcp.mahialjaber.me                  --> Points to DC Port 3268 (Global Catalog)
```

### Reverse Lookup Zone: `10.168.192.in-addr.arpa`
* Maps internal IPv4 addresses back to fully qualified domain names (`FQDN`).
* Essential for Kerberos mutual authentication, reverse DNS checks in SIEM / network monitoring tools, and log enrichment.

---

## 2. Dynamic Host Configuration Protocol (DHCP) Design

* **Server:** Hosted on `DC01`
* **Authorization:** Authorized in Active Directory to prevent rogue DHCP assignment.
* **Scope Range:** `192.168.10.50` - `192.168.10.254` (Subnet: `255.255.255.0`)
* **Exclusions / Reservations:** `192.168.10.1` - `192.168.10.49` reserved for network infrastructure, domain controllers, and servers.
* **Active Scope Options:**
  * **Option 003 (Router / Default Gateway):** `192.168.10.2`
  * **Option 006 (DNS Servers):** `192.168.10.10` (Primary DC), `192.168.10.40` (Secondary DC)
  * **Option 015 (DNS Domain Name):** `mahialjaber.me`
