#!/bin/bash
#------------------------------------------
#                                          | 
#     Slice creation  v 2.0              |
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

##Need to check SLicing ID Part!!!
echo -n "Input Sllicing ID (Integers only): "
read Slicing




export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$PASS
export OS_AUTH_URL=http://$IP/identity/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2





##Checking Network

net_list=`openstack network list | grep vxlan_$Slicing`


if [ "$net_list" == "" ]; then
echo ""
echo ""
  echo "Creating slice...."
  echo
  echo ""
echo ""
  # Create Network
  #openstack network create --project $User_ID --provider-network-type vlan --provider-physical-network provider --provider-segment $Slicing vlan_$Slicing
openstack network create vxlan_$Slicing --provider-network-type vxlan  --provider-segment $Slicing

echo ""

echo "#################### Slice has been created #####################"
echo ""
echo ""

  # Obtain Network ID
  Net_ID=`openstack network list | grep vxlan_$Slicing | awk '{print $2}'`

  # Create Subnet
  subnet=`cat network_pool | grep $Slicing | awk '{print $3}'`
  allocation=`cat network_pool | grep $Slicing | awk '{print $4}'`


echo "#################### IP address assignment #####################"
echo ""
echo ""

echo -n "Input Subnet range(eg. 10.0.0.0/24): "
read subnet_ip
echo ""
echo ""

echo -n "Input Gateway address (eg. 10.0.0.1):  "
read gt_add

echo ""
echo ""

  openstack subnet create --project $User_ID --subnet-range $subnet_ip --ip-version 4 --network $Net_ID --dhcp --gateway $gt_add sub_$Slicing


  export OS_PROJECT_DOMAIN_NAME=default
  export OS_USER_DOMAIN_NAME=default
  export OS_PROJECT_NAME=$User_ID
  export OS_USERNAME=$User_ID
  export OS_PASSWORD=$Password
  export OS_AUTH_URL=http://$IP/identity/v3
  export OS_IDENTITY_API_VERSION=3
  export OS_IMAGE_API_VERSION=2

  
  # Create Router
  openstack router create router_$Slicing

  # Setting External Gateway
  openstack router set --external-gateway public router_$Slicing

  # Add Port
  openstack router add subnet router_$Slicing sub_$Slicing
else
 
 echo "####################  Slice has been created  #####################"
 echo ""
echo ""

fi


export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=$User_ID
export OS_USERNAME=$User_ID
export OS_PASSWORD=$Password
export OS_AUTH_URL=http://$IP/identity/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


# Flavor & Image
 echo ""
echo ""
 echo "#################### Starting VM Creation #####################"
echo ""
echo ""
openstack flavor list
echo ""
echo ""
echo -n "Input Flavor for VM creation from the list: "
read Flavor

 echo ""
echo ""
openstack image list
echo ""
echo ""
echo -n "Input Image for VM creation from the list: "
read Image


 echo ""
echo ""

# obtain Network ID
Net_ID=`openstack network list | grep vxlan_$Slicing | awk '{print $2}'`



# Create Instance
openstack server create --flavor $Flavor --image $Image --nic net-id=$Net_ID Cloud_Instance_$Slicing

echo ""
echo ""
 echo "#################### VM have been created successfully #####################"
echo ""
echo ""

echo ""
echo ""

 echo "Slice have been created successfully with slice ID:" $Slicing

echo ""
echo ""
echo ""
echo ""
#Instance_ID=`openstack server list | grep Cloud_Instance_$2 | awk '{print $2}'`

# Add DB
#cat << EOF | mysql -h 172.20.90.167 -uroot -p$PASSWORD
#use Slicing_Management;
#INSERT INTO Slicing_Instance('Slicing_ID', 'Instance_ID') VALUES ($2, $Instance_ID);
#quit
#EOF
