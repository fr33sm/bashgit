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
            quantity)
                cat /proc/cpuinfo | grep processor | wc -l
                ;;
            # stress)
            #     fulload() { for ((i=1; i<=`nproc --all`; i++)); do while : ; do : ; done & done }; fulload; read; killall bash ### лучше сразу брать PID процессов и кикать их отдельно
            #     ;;
            *)
                echo "используйте аругмент 'load' для отображения текущей нагрузки"
                echo "используйте аргумент 'temp' для отображения текущей температуры"
                echo "используйте аргумент 'quantity' для отображения количества ядер"
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
            list)
                lsblk | grep sd
                ;;
            available)
                df -Th | grep $3 | awk '{printf "available space: " $5 "\n"}'
                shift
                ;;
            *)
                echo "используйте аругмент 'quantity' для отображения общего количества разделов дисков"
                echo "используйте 'list' для отображения списка дисков sd? (sda, sdb ...)"
                echo "используйте аргумент 'available *имя диска*' для отображения доступного к использованию объёма ОЗУ"
                ;;
        esac
        shift
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