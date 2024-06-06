globus login --no-local-server

# Run the globus endpoint create command and capture the output
endpoint_info=$(globus endpoint create --personal myep 2>&1)

# Extract the Endpoint ID and Setup Key from the output using grep and awk
endpoint_id=$(echo "$endpoint_info" | grep -oP 'Endpoint ID: \K[0-9a-f-]+')
setup_key=$(echo "$endpoint_info" | grep -oP 'Setup Key: \K[0-9a-f-]+')

# Set the environment variables
export GLOBUS_ENDPOINT_ID="$endpoint_id"
export GLOBUS_SETUP_KEY="$setup_key"

su gridftp

cd /home/gridftp/globusconnectpersonal-**/

./globusconnectpersonal -setup $GLOBUS_SETUP_KEY

echo "$DataPath,0,1" >> ~/.globusonline/lta/config-paths
cp -p -r /home/gridftp/.globus* $ConfigPath
