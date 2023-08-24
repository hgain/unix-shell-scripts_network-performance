clear 
# Get the directory of the currently executing script
script_dir=$(dirname "$0")

# Get the name of the currently executing script without the extension
script_name=$(basename "$0" .sh)

# Get the current timestamp
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Formulate the output filename
output_filename="${script_name}_${timestamp}.txt"

# Start capturing the output and saving it in the same directory as the script
{
  echo "starting nearest router connection performance test . . ."
  networkquality

  echo "\nstarting local master router package performance test . . ."
  getIP=$(route -n get www.google.com | grep gateway)
  ip=$(echo "$getIP" | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
  ping_stats=$(ping $ip -s 1024 -i 0.25 -c 50 --apple-time | sed -n "/--- $ip ping statistics ---/,/^---/p")
  echo "$ping_stats"

  echo "\nstarting remote endpoint up+downstream performance test . . ."
  #speedtest-cli --list
  speedtest-cli
} 2>&1 | sed -e 's/\x1B\[[0-9;]*[JKmsu]//g' | tee "${script_dir}/${output_filename}"

exit
