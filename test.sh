#!/bin/bash

function usage() {
	cat <<USAGE

	Usage: $0 [-o option] [--long-option]

Помощь по использованию:
    -p, --proc - работа с директорией /proc
    -c, --cpu - работа с процессором
    -m, --memory - работа с памятью
    -d, --disks - работа с дисками
    -n, --network - работа с сетью
    -la, --loadaverage - вывод средней нагрузки на систему
    -k, --kill - отправка сигналов процессам (простой аналог утилиты kill)
    -o, --output - сохранение результатов работы скрипта на диск
    -h, --help - вывод предназначения скрипта, помощи для верного запуска и описания всех команд с примерами
USAGE
	exit 1
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi


while [ "$1" != "" ]; do
	case $1 in
    -p|--proc)
        if [ "$2" == "" ]; then
            ls /proc/
        else
            cat "/proc/$2"
            shift
        fi
        ;;
    -c|--cpu) # работа с процессором
        
        # current load
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "cpu current load: " 100 - $1"%"}'
        # number of cores
        ### cat /proc/cpuinfo | grep processor | wc -l
        # stresstest CPU
        ### fulload() { for ((i=1; i<=`nproc --all`; i++)); do while : ; do : ; done & done }; fulload; read; killall bash # get PID of process & kill only them
        ;;
    -m|--memory) # работа с памятью
        cat /proc/meminfo | grep MemFree | awk -F " " '{printf "free memory: " $2/1024 " MB\n"}'
        cat /proc/meminfo | grep MemAvailable | awk -F " " '{printf "available memory: " $2/1024 " MB\n"}'
        ;;
    -d|--disks) # работа с дисками
        cat /proc/partitions | grep sda | wc -l | awk '{printf "number of disks: " $1 "\n"}'
        ;;
    -n|--network) # работа с сетью
        echo "network"
        ;;
    -la|--loadaverage) # вывод средней нагрузки на систему
        cat /proc/loadavg | awk '{print "15 min load average: "$3"%"}'
        ;;
    -k|--kill) # отправка сигналов процессам (простой аналог утилиты kill) список зомби процессов и их килл
        echo "$1"
        ;;
    -o|--output) # сохранение результатов работы скрипта на диск
		echo "output path: $2"
		shift
		;;
    -t|--time) # текущее время
        echo "$1"
        ;;
    # -te|--temperature) # температура с доступных датчиков
    # 	paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'
    # 	smartctl -A /dev/sda
    #	;;
    -h|--help)
        usage
        ;;
    *)
        echo "unknown parameter"
        usage
        exit 1
        ;;
	esac
    shift
done