#!/bin/ash

# Wait until the network is up; ping 1.1.1.1
while ! ping -c 1 1.1.1.1; do
    sleep 1
done

export PATH=$PATH:/opt/bin:/opt/sbin

opkg update

if [ ! -f /opt/etc/init.d/S80mosquitto ]; then
    # Download and install mosquitto from opk
    opkg install mosquitto-ssl

    # Create the mosquitto configuration file

    cat <<EOF >/opt/etc/mosquitto/mosquitto.conf
log_type all

allow_anonymous true

listener 8883
protocol mqtt
cafile /user/ca.crt
keyfile /user/server.key
certfile /user/server.crt
EOF
fi

# Check if ca-certificates is installed with opkg
# opkg list | grep ca-certificates
# check if certificates are installed
if ! opkg list-installed | grep -q ca-certificates; then
    opkg install ca-certificates
fi

if ! opkg list-installed | grep -q wget-ssl; then
    opkg install wget-ssl
fi

if ! opkg list-installed | grep -q curl; then
    opkg install curl
fi

# Create link from /opt/etc/ssl/certs to /etc/ssl/certs
echo -e "${YELLOW}Creating link from /opt/etc/ssl/certs to /etc/ssl/certs${NC}"
ln -s /opt/etc/ssl/certs /etc/ssl >/dev/null 2>&1

# Copy ca.crt client.crt and client.key server.crt and server.key to /user in one command
# Copy the files to /user
cp -rp /etc/ssl/certs/{ca.crt,client.crt,client.key,server.crt,server.key} /user

# If mosquitto is not running then start it
# Don't grep mosquitto from the ps output
if ! ps | grep -r "mosquitto -c /opt/etc/mosquitto/mosquitto.conf" | grep -v grep; then
    /opt/etc/init.d/S80mosquitto start
fi
