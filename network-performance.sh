clear
script_dir=$(dirname "$0")
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep -v "BSSID" | grep SSID | cut -d ':' -f2 | xargs)
output_filename="${ssid}_${timestamp}.txt"

# Start capturing the output and saving it in the same directory as the script
{
  echo SSID: $ssid

  echo "\n"
  echo "#####################################################################################################################"
  echo "\n"
  
  echo "TESTING LOCAL NETWORK ENTRY QUALITY -> PERFORMANCE TO DIRECTLY CONNECTED NEAR-END DEVICE"
  networkquality
  
  echo "\n"
  echo "#####################################################################################################################"
  echo "\n"

  echo "TESTING LOCAL NETWORK PACKAGE EXCHANGE SPEED -> PERFORMANCE TO DIRECTLY CONNECTED NEAR-END DEVICE\n"
  getip_direct=$(ipconfig getpacket en0 | grep yiaddr)
  ip_direct=$(echo "$getip_direct" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
  hostname_direct=$(arp $ip_direct)
  echo "Hostname: '$hostname_direct'"
  ping_stats_direct=$(ping $ip_direct -s 1024 -i 0.25 -c 50 --apple-time | sed -n "/--- $ip_direct ping statistics ---/,/^---/p")
  echo "$ping_stats_direct"

  echo "\n"
  echo "#####################################################################################################################"
  echo "\n"

  echo "TESTING LOCAL NETWORK PACKAGE EXCHANGE SPEED -> PERFORMANCE TO NEAR-END GATEWAY ROUTER\n"
  getip_gateway=$(route -n get www.google.com | grep gateway)
  ip_gateway=$(echo "$getip_gateway" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
  hostname_gateway=$(arp $ip_gateway)
  echo "Hostname: '$hostname_gateway'"
  ping_stats_gateway=$(ping $ip_gateway -s 1024 -i 0.25 -c 50 --apple-time | sed -n "/--- $ip_gateway ping statistics ---/,/^---/p")
  echo "$ping_stats_gateway"

  echo "\n"
  echo "#####################################################################################################################"
  echo "\n"

  echo "TESTING INTERNET SPEED -> PERFORMANCE TO REMOTE-ENDPOINT\n"
  #speedtest-cli --list
  speedtest-cli

  echo "\n"
  echo "#####################################################################################################################"
  echo "\n"

  echo "RECORD OF CURRENTLY CONNECTED DEVICES\n"
  arp -a
} 2>&1 | sed -e 's/\x1B\[[0-9;]*[JKmsu]//g' | tee "${script_dir}/${output_filename}"

exit