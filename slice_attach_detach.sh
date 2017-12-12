#!/bin/bash


#------------------------------------------
#                                          | 
#     Slice_attach_datach v.1              |
#                           		   |	
#------------------------------------------



if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


IP=192.168.42.11
Port=35357
PASS=labstack


Flavor=$3
Image=$4



#Authentication
echo ""
echo ""
echo ""
echo -n "Input your Dashboard ID: "
read User_ID
echo ""
echo -n "Input your Password: "
stty -echo
read Password
echo ""
stty echo




export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=$User_ID
export OS_USERNAME=$User_ID
export OS_PASSWORD=$Password
export OS_AUTH_URL=http://$IP/identity/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

echo "######################## Successfully login ################"
echo ""
echo ""
echo "Generating Token for" $User_ID
echo ""
echo ""
Output=`openstack token issue`

echo "check is $Output"

if [ "$Output" == "" ]; then
   echo "Authentication Failed"
   exit 1
fi
echo ""
echo ""
echo "######################## Token generated successfully ################"
echo ""
echo ""


echo "VM attach/deatch:
1: Attach
2: Detach"

echo -n "Input:  "

read img_num


if [ "$img_num" == "2" ]; then
novalist=`nova list`

echo "Available VM are: $novalist"
echo ""
echo ""
echo -n "Type VM to deatch:"
read img_name

echo ""
echo ""

nova suspend $img_name




echo "Detaching VM" $img_name 
echo ""
echo ""
echo "####################### Image Deatched Successfully ####################"
echo ""
echo ""
   exit 1
fi



if [ "$img_num" == "1" ]; then
  novalist=`nova list`

echo "Available VM are: $novalist"
echo ""
echo ""
echo -n "Type VM to Reattach:"
read img_name

echo ""
echo ""

nova resume $img_name

echo "Rettaching VM" $img_name
echo ""
echo ""
echo "####################### Image Reattched Successfully ####################"
echo ""
echo ""





   exit 1
fi





novalist=`nova list`

echo "Available VM are: $novalist"






##Need to check SLicing ID Part!!!


export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$PASS
export OS_AUTH_URL=http://$IP/identity/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2




export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=$User_ID
export OS_USERNAME=$User_ID
export OS_PASSWORD=$Password
export OS_AUTH_URL=http://$IP/identity/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2



#Instance_ID=`openstack server list | grep Cloud_Instance_$2 | awk '{print $2}'`

# Add DB
#cat << EOF | mysql -h 172.20.90.167 -uroot -p$PASSWORD
#use Slicing_Management;
#INSERT INTO Slicing_Instance('Slicing_ID', 'Instance_ID') VALUES ($2, $Instance_ID);
#quit
#EOF
