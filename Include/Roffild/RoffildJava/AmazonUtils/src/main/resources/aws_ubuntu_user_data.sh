#!/bin/bash
Hours=1
agentStartPort=5000
agentPassword=amazon99
bucket=
### Using a IAM Role is preferable to a key.
#export AWS_ACCESS_KEY_ID=
#export AWS_SECRET_ACCESS_KEY=
#export AWS_DEFAULT_REGION=
################################
USER=ubuntu
NHOME=/mnt/$USER
usermod -m -d $NHOME $USER
SHUTTIME=`awk -v hr=$Hours '{print int((int(hr) - 1) * 60 + 55 - (int($1) % 3600) / 60)}' /proc/uptime`
shutdown -h +$SHUTTIME timer &
dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/Release.key
apt-key add Release.key
apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get install -y --allow-unauthenticated winehq-devel awscli
apt-get clean -y
MQF="$NHOME/.wine/drive_c/users/$USER/Application Data/MetaQuotes/"
sudo -u $USER -- mkdir -m ug+rwx -p "$MQF"
if [ -n "$AWS_ACCESS_KEY_ID" ]
then
sudo -u $USER -- env AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION aws s3 sync s3://$bucket/MetaQuotes/ "$MQF"
else
sudo -u $USER -- aws sts get-caller-identity
sudo -u $USER -- aws s3 sync s3://$bucket/MetaQuotes/ "$MQF"
fi
CPU=`cat /proc/cpuinfo | awk '/^processor/{print $3}' | tail -1`
for port in `seq 0 $CPU`
do
sudo -u $USER -- /usr/bin/wine "$MQF/metatester64.exe" /dlls /local /password:$agentPassword /address:0.0.0.0:$(($port + $agentStartPort)) &
done
