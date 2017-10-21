#!/bin/ash
set -x

if [ -z "${CORES}" ]; then
export CORES=`grep -c processor /proc/cpuinfo`
fi

export AUTO_CONFIGURATION=$(/app/xmr-stak-cpu | grep "low_power_mode")

envtpl /app/xmr-stak-cpu.conf.tpl -o /app/xmr-stak-cpu.conf --allow-missing --keep-template
if [ -z "${SELF}" ]; then
#this will ping itself
nohup watch -n 60 curl -G -o /dev/null https://${SELF}.now.sh &>/dev/null &
fi


if [ "$1" = 'xmr-stak-cpu' ]; then
    exec /app/xmr-stak-cpu /app/xmr-stak-cpu.conf
fi

exec "$@"
