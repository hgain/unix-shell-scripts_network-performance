clear
script_dir=$(dirname "$0")
start_time=$(date +"%Y-%m-%d_%H-%M-%S")
ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep -v "BSSID" | grep SSID | cut -d ':' -f2 | xargs)
output_filename="${start_time}.txt"

# Start capturing the output and saving it in the same directory as the script
{
  echo WiFi SSID: $ssid
  echo start time: $start_time

  echo "\n"
  echo "#####################################################################################################################"
  echo "\n"
  
  echo "PERFORMING PARALLEL INTERNET SPEEDTEST AGAINST STATIC APPLE QUALIFICATION SERVER"
  networkquality -sv

  echo "\n"
  echo "#####################################################################################################################"
  echo "\n"

  echo "PERFORMING SEQUENTIAL INTERNET SPEEDTEST TO CLOSEST SERVER\n"
  #speedtest-cli --list
  speedtest-cli

  echo "\n"
  echo "#####################################################################################################################"
  echo "\n"

  echo "TESTING LOCAL NETWORK CLIENT-GATEWAY SPEED\n"
  getip_gateway=$(route -n get www.google.com | grep gateway)
  ip_gateway=$(echo "$getip_gateway" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
  hostname_gateway=$(arp $ip_gateway)
  echo "Hostname: '$hostname_gateway'"
  #ping_stats_gateway=$(ping $ip_gateway -s 1024 -i 0.25 -c 50 --apple-time | sed -n "/--- $ip_gateway ping statistics ---/,/^---/p")
  echo "$ping_stats_gateway"
  iperf -e -t15 -c $ip_gateway -P 5 -p 4711 | awk '/^-|^\[ ID\] Interval|^Client connecting|^Write buffer size|^[A-Z][[:space:]]|^\[SUM\]|^\[ CT\]/'

  echo "\n"
  echo "#####################################################################################################################"
  echo "\n"

  echo "SNAPSHOT OF CURRENTLY CONNECTED LOCAL NETWORK DEVICES\n"
  arp -a
} 2>&1 | sed -e 's/\x1B\[[0-9;]*[JKmsu]//g' | tee "${script_dir}/${output_filename}" | tee /dev/tty

exit