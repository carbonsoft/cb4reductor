# Автоматизация и автозагрузка

## ./etc/init.d/reductor
init-скрипт, позволяет запускать Carbon Reductor при старте системы.
После копирования в нужное место, необходимо выполнить:

	chkconfig --add reductor
	chkconfig --level 3 reductor on

и проверить

	chkconfig --list

## ./etc/cron.daily/zapret_info_update.sh

При нахождении в нужном месте - будет раз в день запускать
обновление списков с zapret-info.gov.ru

# Настройки файрвола

## ./etc/sysconfig/ebtables

хранит в себе правило для добавления в ebtables, при использовании
схемы зеркалирования с коммутатора. Нужно для того, чтобы трафик
попадал в iptables.

Можно восстановить выполнив 

	ebtables-restore < ./etc/sysconfig/ebtables

или положив в нужное место вместе с 

## ./etc/sysconfig/ebtables-config

Конфиг ebtables, в котором изменён один параметр для загрузки
./etc/sysconfig/ebtables при старте демона ebtables.

## ./etc/sysconfig/iptables

Пример файрвола, снижающего нагрузку на Reductor. Рекомендуется к
использованию, можно вносить свои изменения при необходимости.
Будет использоваться автоматически, если положить его в нужное
место.

# Настройки сети
Можно восстановить с помощью:

	iptables-restore < ./etc/sysconfig/iptables

## ./etc/sysconfig/network-scripts/ifcfg-eth0

Настройки внешнего интерфейса, к которому в последствии будем 
подключаться по SSH и через который должен быть доступ в интернет.

## ./etc/sysconfig/network-scripts/ifcfg-eth1

Пример настройки интерфейса на который приходит зеркало трафика
без vlan.

## ./etc/sysconfig/network-scripts/ifcfg-eth2
## ./etc/sysconfig/network-scripts/ifcfg-eth2.20

Пример настройки интерфейса на который приходит тэгированный 
трафик из зеркала.

## ./etc/sysconfig/network-scripts/ifcfg-br0

Настройки моста, необходимо при использовании зеркалирования
трафика с коммутатора.

## ./etc/sysconfig/network-scripts/ifup-eth

Модифицированный скрипт подъёма интерфейсов, отличается тем, что
не завершается после добавления vlan в bridge, а продолжает
работать и добавляет IP адрес на интерфейс, что необходимо для того,
чтобы трафик попадал в iptables.

# Настройки операционной системы

## ./etc/sysctl

Можно не использовать, достаточно:

* Включить ip_forward
* Включить bridge-nf-call-iptables
* Отключить rp_filter на всех интерфейсах, принимающих зеркало трафика.
