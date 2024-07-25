# Define the new nameservers as a list of hashtables containing FQDN and IP address
$newNameServers = @(
    @{ FQDN = "bind1.hempshaw.internal."; IP = "192.168.53.101" },
    @{ FQDN = "bind2.hempshaw.internal."; IP = "192.168.53.102" },
    @{ FQDN = "bind3.hempshaw.internal."; IP = "192.168.53.103" },
    @{ FQDN = "bind4.hempshaw.internal."; IP = "192.168.53.104" },
    @{ FQDN = "bind5.hempshaw.internal."; IP = "192.168.53.105" }
    # Add more nameservers here
)

# Get all DNS zones
$allZones = Get-DnsServerZone

# Filter for reverse lookup zones
$reverseZones = $allZones | Where-Object { $_.ZoneName -like "*.in-addr.arpa" -or $_.ZoneName -like "*.ip6.arpa" }

# Iterate through each reverse zone and add the new nameservers
foreach ($zone in $reverseZones) {
    foreach ($newNameServer in $newNameServers) {
        # Get current nameservers
        $nameServers = Get-DnsServerResourceRecord -ZoneName $zone.ZoneName -RRType NS

        # Check if the nameserver already exists
        $existingNS = $nameServers | Where-Object { $_.RecordData.NameServer -eq $newNameServer.FQDN }

        if (-not $existingNS) {
            # Add new NS record
            Add-DnsServerResourceRecord -ZoneName $zone.ZoneName -Name "@" -NameServer $newNameServer.FQDN -NS -TimeToLive 01:00:00

            Write-Host "Added $($newNameServer.FQDN) to $($zone.ZoneName)"
        } else {
            Write-Host "$($newNameServer.FQDN) already exists in $($zone.ZoneName)"
        }
    }
}

