#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
    echo "usage : $0 <project_root> <kobra_unleashed_package>"
    exit 1
fi

project_root="$1"
kobra_unleashed_package="$2"

check_tools "unzip cp sed grep"

if [ ! -d "$project_root" ]; then
    echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
    exit 2
fi

kobra_unleashed_package_folder="$OPTIONS_DIR/kobra_unleashed/$kobra_unleashed_package"
if [ ! -d "$kobra_unleashed_package_folder" ]; then
    echo -e "${RED}ERROR: Cannot find the folder '$kobra_unleashed_package_folder' ${NC}"
    exit 3
fi

kobra_unleashed_package_file="${kobra_unleashed_package_folder}/${kobra_unleashed_package}.zip"
if [ ! -f "$kobra_unleashed_package_file" ]; then
    echo -e "${RED}ERROR: Cannot find the file '$kobra_unleashed_package_file' ${NC}"
    exit 4
fi

target_folder="$ROOTFS_DIR"
temp_folder="$TEMP_DIR"

if [ ! -d "$target_folder" ]; then
    echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
    exit 5
fi

if [ ! -d "$temp_folder" ]; then
    echo -e "${RED}ERROR: Cannot find the temp folder '$temp_folder' ${NC}"
    exit 6
fi

# unzip the kobra_unleashed package to the temp folder
unzip -o -q "$kobra_unleashed_package_file" -d "$temp_folder"

# Check if folders "frontend" and "server" exist in the temp folder
if [ ! -d "$temp_folder/frontend" ]; then
    echo -e "${RED}ERROR: Cannot find the folder 'frontend' in the temp folder ${NC}"
    exit 7
fi

if [ ! -d "$temp_folder/server" ]; then
    echo -e "${RED}ERROR: Cannot find the folder 'server' in the temp folder ${NC}"
    exit 8
fi

# Check if folders exist
if [ ! -d "$target_folder/www" ]; then
    echo -e "${RED}ERROR: Cannot find the folder 'www' in the target folder ${NC}"
    exit 9
fi

if [ ! -d "$target_folder/opt" ]; then
    echo -e "${RED}ERROR: Cannot find the folder 'opt' in the target folder ${NC}"
    exit 10
fi

# Copy frontend/* to /www
cp -r "$temp_folder/frontend"/* "$target_folder/www"

# Copy server/* to /opt/bin folder
cp -r "$temp_folder/server"/* "$target_folder/opt/bin"

# Empty the temp folder
rm -rf "$temp_folder"/*

# ubus -t 30 wait_for network.interface network.wireless
# /opt/bin/kobra-server &

cat <<EOF >"$target_folder/opt/etc/init.d/S99kobra-server"
#!/bin/sh

PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin

APP="/opt/bin/kobra-server"

kobra_status ()
{
    # Check if the process is running using pidof command
    [ -n "\$(pidof kobra-server)" ]
}

start()
{
    # Start the kobra server
    ubus -t 30 wait_for network.interface network.wireless
    \$APP &
}

stop()
{
    kill -9 \$(pidof kobra-server)
}
case "\$1" in
	start)
		if kobra_status
        then
            echo kobra-server already running
        else
            start
        fi
		;;
	stop)
		if kobra_status
        then
            stop
        else
            echo kobra-server is not running
        fi
		;;
	status)
		if kobra_status
        then
            echo kobra-server already running
        else
            echo kobra-server is not running
        fi
		;;
	restart)
		stop
		sleep 3
		start
		;;
	*)
		echo "Usage: \$0 {start|stop|restart|status}"
		;;
esac
EOF

# Make it executable
chmod +x "$target_folder/opt/bin/kobra-server"
chmod +x "$target_folder/opt/etc/init.d/S99kobra-server"

echo -e "${GREEN}kobra_unleashed has been installed successfully!${NC}"
