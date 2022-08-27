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
}

if [ $# -eq 0 ]; then
	usage
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
        case $2 in
            load) 
                top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "cpu current load: " 100 - $1"%"}'
                ;;
            temp)
                if [[ -f "/sys/class/thermal/thermal_zone*/temp" ]]
                then
                    paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'
                fi
                ;;
            # stress)
            #     fulload() { for ((i=1; i<=`nproc --all`; i++)); do while : ; do : ; done & done }; fulload; read; killall bash ### лучше сразу брать PID процессов и кикать их отдельно
            #     ;;
            *)
                cat /proc/cpuinfo | grep name
                echo "используйте аругмент 'load' для отображения текущей нагрузки"
                echo "используйте аргумент 'temp' для отображения текущей температуры"
                # echo "используйте аргумент 'stress' для стресс теста всех ядер процессора"
                ;;
        esac
        shift
        ;;
    -m|--memory) # работа с памятью
        case $2 in
            total) 
                cat /proc/meminfo | grep MemTotal | awk -F " " '{printf "total memory: " $2/1024 " MB\n"}'
                ;;
            available)
                cat /proc/meminfo | grep MemAvailable | awk -F " " '{printf "available memory: " $2/1024 " MB\n"}'
                ;;
            swapinfo)
                cat /proc/meminfo | grep SwapTotal | awk -F " " '{printf "total swap: " $2/1024 " MB\n"}'
                cat /proc/meminfo | grep SwapFree | awk -F " " '{printf "free swap: " $2/1024 " MB\n"}'                
                ;;
            *)
                free -m
                echo "используйте аругмент 'total' для отображения общего объёма ОЗУ"
                echo "используйте аргумент 'available' для отображения доступного к использованию объёма ОЗУ"
                echo "используйте аргумент 'swapinfo' для отображения информации о SWAP"
                ;;
        esac
        shift
        ;;
    -d|--disks) # работа с дисками
        case $2 in
            quantity) 
                lsblk | grep part | wc -l | awk '{printf "number of partitions: " $1 "\n"}'
                ;;
            available)
                if [[ -f "$3" ]]
                then
                    df -Th | grep $3 | awk '{printf "available space: " $5 "\n"}'
                    shift
                else
                    echo "disk not exist"
                    shift
                fi
                ;;
            iostat)
                if [[ -f "$3" ]]
                then
                    cat /proc/diskstats | grep $3 | awk -F " " '{printf "I/Os currently in progress: " $9" \n"}'
                    shift
                else
                    echo "disk not exist"
                    shift
                fi
                ;;
            *)
                lsblk | grep sd
                echo "используйте аругмент 'quantity' для отображения общего количества разделов дисков"
                echo "используйте аргумент 'available *имя диска*' для отображения доступного к использованию объёма ОЗУ"
                echo "используйте аргумент 'iostat *имя диска*' для отображения текущего количества IO в очереди"
                ;;
        esac
        shift
        ;;
    -n|--network) # работа с сетью
        cat /proc/net/dev
        ;;
    -la|--loadaverage) # вывод средней нагрузки на систему
        cat /proc/loadavg | awk '{print "15 min load average: "$3"%"}'
        ;;
    -k|--kill) # отправка сигналов процессам (простой аналог утилиты kill) список зомби процессов и их килл
        if [[ -f "$2" ]]
        then
            echo $2
            # killall -9 $2
        else
            echo "process name not entered"
        fi
        shift
        ;;
    -o|--output) # сохранение результатов работы скрипта на диск
        if [[ -f "$2" ]]
        then
            echo "output path $2"
        else
            echo "output path not exist"
        fi
		shift
		;;
    -t|--time) # текущее время
        echo "$1"
        ;;
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

### output!!!