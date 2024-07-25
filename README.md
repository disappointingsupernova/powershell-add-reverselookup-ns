# powershell-add-reverselookup-ns

## Add New Nameservers to Reverse Lookup Zones Script

This PowerShell script automates the process of adding new nameservers to all reverse lookup DNS zones on a DNS server. It checks if the nameservers already exist in each zone and adds them if they are not present.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Script Details](#script-details)
- [Customisation](#customisation)
- [License](#license)

## Prerequisites

- PowerShell 5.1 or later
- DNS server role installed on the target server
- Necessary permissions to manage DNS zones and records

## Usage

1. **Clone the Repository:**
    ```sh
    git clone https://github.com/disappointingsupernova/powershell-add-reverselookup-ns
    cd add-nameservers-script
    ```

2. **Edit the Script (if necessary):**
    Update the `$newNameServers` list in the script with the Fully Qualified Domain Names (FQDN) and IP addresses of the nameservers you want to add.

3. **Run the Script:**
    ```sh
    ./add-nameservers.ps1
    ```

## Script Details

This script performs the following steps:

1. **Define the new nameservers**: 
   - A list of hashtables containing the FQDN and IP address of each new nameserver.

    ```powershell
    $newNameServers = @(
        @{ FQDN = "bind1.hempshaw.internal."; IP = "192.168.53.101" },
        @{ FQDN = "bind2.hempshaw.internal."; IP = "192.168.53.102" },
        @{ FQDN = "bind3.hempshaw.internal."; IP = "192.168.53.103" },
        @{ FQDN = "bind4.hempshaw.internal."; IP = "192.168.53.104" },
        @{ FQDN = "bind5.hempshaw.internal."; IP = "192.168.53.105" }
    )
    ```

2. **Retrieve all DNS zones**: 
   - Gets all DNS zones on the server using `Get-DnsServerZone`.

    ```powershell
    $allZones = Get-DnsServerZone
    ```

3. **Filter reverse lookup zones**: 
   - Filters the zones to get only reverse lookup zones (e.g., zones ending in `.in-addr.arpa` or `.ip6.arpa`).

    ```powershell
    $reverseZones = $allZones | Where-Object { $_.ZoneName -like "*.in-addr.arpa" -or $_.ZoneName -like "*.ip6.arpa" }
    ```

4. **Add new nameservers to each reverse zone**: 
   - Iterates through each reverse zone and adds the new nameservers if they are not already present.

    ```powershell
    foreach ($zone in $reverseZones) {
        foreach ($newNameServer in $newNameServers) {
            $nameServers = Get-DnsServerResourceRecord -ZoneName $zone.ZoneName -RRType NS
            $existingNS = $nameServers | Where-Object { $_.RecordData.NameServer -eq $newNameServer.FQDN }
            if (-not $existingNS) {
                Add-DnsServerResourceRecord -ZoneName $zone.ZoneName -Name "@" -NameServer $newNameServer.FQDN -NS -TimeToLive 01:00:00
                Write-Host "Added $($newNameServer.FQDN) to $($zone.ZoneName)"
            } else {
                Write-Host "$($newNameServer.FQDN) already exists in $($zone.ZoneName)"
            }
        }
    }
    ```

## Customisation

To add more nameservers, simply extend the `$newNameServers` list with additional hashtables containing the FQDN and IP address of the new nameservers:

```powershell
$newNameServers = @(
    @{ FQDN = "bind1.hempshaw.internal."; IP = "192.168.53.101" },
    @{ FQDN = "bind2.hempshaw.internal."; IP = "192.168.53.102" },
    @{ FQDN = "bind3.hempshaw.internal."; IP = "192.168.53.103" },
    @{ FQDN = "bind4.hempshaw.internal."; IP = "192.168.53.104" },
    @{ FQDN = "bind5.hempshaw.internal."; IP = "192.168.53.105" },
    @{ FQDN = "bind6.hempshaw.internal."; IP = "192.168.53.106" }  # New nameserver example
)
