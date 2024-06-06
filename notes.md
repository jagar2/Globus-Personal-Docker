# Building the container

To build the container, run the following command:

```bash
docker build -t globus .
```

# Running the container

To run the container, run the following command:

```bash
docker run -v /home/ferroelectric/data:/home/ferroelectric/data -v /home/ferroelectric/globus_config:/home/ferroelectric/globus_config -it globus 
```

globus login --no-local-server

```bash
# Run the globus endpoint create command and capture the output
endpoint_info=$(globus endpoint create --personal myep 2>&1)

# Extract the Endpoint ID and Setup Key from the output using grep and awk
endpoint_id=$(echo "$endpoint_info" | grep -oP 'Endpoint ID: \K[0-9a-f-]+')
setup_key=$(echo "$endpoint_info" | grep -oP 'Setup Key: \K[0-9a-f-]+')

# Set the environment variables
export GLOBUS_ENDPOINT_ID="$endpoint_id"
export GLOBUS_SETUP_KEY="$setup_key"

cd /home/gridftp/globusconnectpersonal-**/

./globusconnectpersonal -setup $GLOBUS_SETUP_KEY

./globusconnectpersonal -start &

echo "/home/ferroelectric/data/,0,1" >> ~/.globusonline/lta/config-paths
cp -p -r /home/gridftp/.globus* /home/ferroelectric/globus_config
cp -p /home/gridftp/endpoint-info /home/ferroelectric/globus_config

```


mkdir -p /data/gridftp-save
chown gridftp.gridftp /data/gridftp-save
cd ~gridftp/
cp -p -r .globus* /data/gridftp-save/
cp -p endpoint-info /data/gridftp-save/

# now need to move files 