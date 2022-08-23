#!/bin/bash
### https://habr.com/ru/company/ruvds/blog/326328/
printhelp () {
	echo "Помощь по использованию:
    -p, --proc - работа с директорией /proc
    -c, --cpu - работа с процессором
    -m, --memory - работа с памятью
    -d, --disks - работа с дисками
    -n, --network - работа с сетью
    -la, --loadaverage - вывод средней нагрузки на систему
    -k, --kill - отправка сигналов процессам (простой аналог утилиты kill)
    -o, --output - сохранение результатов работы скрипта на диск
    -h, --help - вывод предназначения скрипта, помощи для верного запуска и описания всех команд с примерами"
}

fullprog () {

echo "$0"
echo "$1"
echo "$2"

while [ -n "$1" ]
do
	echo "while fullprog works"
	case $1 in
		-p|--proc)
			echo "proc"
			;;
		-c|--cpu) # работа с процессором
			# current load
			top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
			top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.1f%%\n", prefix, 100 - v }'
			# cpu temperature
			cat /sys/devices/virtual/thermal/thermal_zone?/temp | awk '{printf "cpu temp = %5.2f °C\n" , $1/1000}'
			# stresstest CPU
			### fulload() { for ((i=1; i<=`nproc --all`; i++)); do while : ; do : ; done & done }; fulload; read; killall bash # get PID of process & kill only them
			;;
		-m|--memory) # работа с памятью
			
			;;
		-d|--disks) # работа с дисками
			
			;;
		-n|--network) # работа с сетью
			
			;;
		-la|--loadaverage) # вывод средней нагрузки на систему
			cat /proc/loadavg | awk -F ':' '{print $3}'
			;;
		-k|--kill) # отправка сигналов процессам (простой аналог утилиты kill) список зомби процессов и их килл
			
			;;
		-o|--output) # сохранение результатов работы скрипта на диск
			continue # пропускаем чтоб пройти во втором цикле wile для параметров
			;;
		-t|--time) # текущее время
			
			;;
		# -te|--temperature) # температура с доступных датчиков
		# 	paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'
		# 	smartctl -A /dev/sda
		#	;;
		-h|--help)
			printhelp ;;
		*)
			echo "unknown parameter"
			;;
	esac
shift
done

while [ -n "$1" ]
do
	case "$1" in
		-o|--output)
			# сохранение результатов работы скрипта на диск
			# дополнительная проверка на существование путей
			# output в файл с проверкой если он больше количества строк, то записывается сначала
			echo "$2"
			;;
	esac
shift
shift
done
}

if test -z "$@"
then
	printhelp
else
	fullprog
fi
