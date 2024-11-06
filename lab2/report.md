* *Курс: Введение в маршрутизацию на предприятии*

* *Студент: Маноменов Иван Андреевич*

* *Группа: К3323*

* *Дата сдачи: 06.11.24*

# Отчет по лабораторной работе №2 "Эмуляция распределенной корпоративной сети связи, настройка статической маршрутизации между филиалами"

## Цель работы
Ознакомиться с принципами планирования IP адресов, настройке статической маршрутизации и сетевыми функциями устройств.

## Задача

Требуется обеспечить работу 3 офисов компании "RogaIKopita Games" в разных городах (Москва, Франкфурт, Берлин).
Нужно чтобы сотрудники из разных городов могли обмениваться файлами. Для этого требуется установить 3 роутера, назначить на них IP адресацию и поднять статическую маршрутизацию.

## Ход работы
Лабораторная работа выполнялась на компьютере с операционной системой Linux, оболочка Ubuntu 22.04.3

### Прописывание кофигураций

Сначала были прописаны файлы конфигураций для роутеров, назначающие адресацию в локальной сети

Конфигурация Московского роутера в файле *R1.cfg*:

```
/ip pool
add name=msk_pool ranges=10.10.10.128-10.10.10.254
/ip dhcp-server
add address-pool=msk_pool disabled=no interface=ether4 name=dhcp-msk
/ip address
add address=10.10.10.129/25 interface=ether4 network=10.10.10.128
add address=2.2.2.2/24 interface=ether2 network=2.2.2.0
add address=3.3.3.3/24 interface=ether3 network=3.3.3.0
/ip dhcp-server network
add address=10.10.10.128/25 gateway=10.10.10.129
/ip route
add dst-address=4.4.4.0/24 gateway=2.2.2.3
add dst-address=10.10.20.128/25 gateway=2.2.2.3
add dst-address=10.10.30.128/25 gateway=3.3.3.2
```

Конфигурация Берлинского роутера в файле *R2.cfg*:

```
/ip pool
add name=brl_pool ranges=10.10.20.128-10.10.20.254
/ip dhcp-server
add address-pool=brl_pool  disabled=no interface=ether4 name=dhcp-brl
/ip address
add address=10.10.20.129/25 interface=ether4 network=10.10.20.128
add address=2.2.2.3/24 interface=ether2 network=2.2.2.0
add address=4.4.4.3/24 interface=ether3 network=4.4.4.0
/ip dhcp-server network
add address=10.10.20.128/25 gateway=10.10.20.129
/ip route
add dst-address=10.10.10.128/25 gateway=2.2.2.2
add dst-address=3.3.3.0/24 gateway=2.2.2.2
add dst-address=10.10.30.128/25 gateway=4.4.4.2
```

И конфигурация Франкфуртского роутера в файле *R3.cfg*:

```
/ip pool
add name=frt_pool ranges=10.10.30.128-10.10.30.254
/ip dhcp-server
add address-pool=frt_pool disabled=no interface=ether4 name=dhcp-frt
/ip address
add address=10.10.30.129/25 interface=ether4 network=10.10.30.128
add address=3.3.3.2/24 interface=ether2 network=3.3.3.0
add address=4.4.4.2/24 interface=ether3 network=4.4.4.0
/ip dhcp-server network
add address=10.10.30.128/25 gateway=10.10.30.129
/ip route
add dst-address=2.2.2.0/24 gateway=4.4.4.3
add dst-address=10.10.10.128/25 gateway=4.4.4.3
add dst-address=10.10.20.128/25 gateway=3.3.3.3
```

### Создание топологии

Также как в первой лабораторной работе, был создан файл топологии *lab2.yml*:

```
name: lab2

topology:
  nodes:
    R01.MSK:
      kind: vr-mikrotik_ros
      image: vrnetlab/mikrotik_routeros:6.47.9
      mgmt-ipv4: 192.168.2.10 
      startup-config: /home/man-men-off/ITMO/routing_labs/lab2/configs/R1.cfg
   
    R02.BRL:
      kind: vr-mikrotik_ros
      image: vrnetlab/mikrotik_routeros:6.47.9
      mgmt-ipv4: 192.168.2.20
      startup-config: /home/man-men-off/ITMO/routing_labs/lab2/configs/R2.cfg

    R03.FRT:
      kind: vr-mikrotik_ros
      image: vrnetlab/mikrotik_routeros:6.47.9
      mgmt-ipv4: 192.168.2.30 
      startup-config: /home/man-men-off/ITMO/routing_labs/lab2/configs/R3.cfg
      
    PC1.MSK:
      kind: linux
      image: alpine:latest
      mgmt-ipv4: 192.168.2.110 

    PC2.BRL:
      kind: linux
      image: alpine:latest
      mgmt-ipv4: 192.168.2.120

    PC3.FRT:
      kind: linux
      image: alpine:latest
      mgmt-ipv4: 192.168.2.130 

  links:
    - endpoints: ["PC1.MSK:eth1", "R01.MSK:eth3"]
    - endpoints: ["PC2.BRL:eth1", "R02.BRL:eth3"]
    - endpoints: ["PC3.FRT:eth1", "R03.FRT:eth3"]
    - endpoints: ["R02.BRL:eth1", "R01.MSK:eth1"]
    - endpoints: ["R02.BRL:eth2", "R03.FRT:eth2"]
    - endpoints: ["R01.MSK:eth2", "R03.FRT:eth1"]
   
mgmt:
 network: static
 ipv4-subnet: 192.168.2.0/24
 
 # PC1.MSK - 10.10.20.254
```

Далее, через команды *sudo containerlab deploy -t lab2.yml* и *sudo containerlab graph -t lab2.yml* был создан контейнер и выведена графическая схема топологии:

![Топология сети с ip](https://github.com/IvanManomenov/routing_2024_Manomenov_Ivan_K3323/blob/main/lab2/topology_graph_ip.png)

Проверим настройку конфигураций роутеров через команду *export*:
![Результат настройки роутера](https://github.com/IvanManomenov/routing_2024_Manomenov_Ivan_K3323/blob/main/lab2/Router_result.png)

Как мы видим, все настройки сохранились

### Настройка адресации ПК

Для настройки адресации компьютеров перейдем в их терминал через команду docker exec -it clab-lab2-PC... sh

Далее для каждого из компьютеров необходимо было выполнить след.последовательность комманд:

```
apk add iproute2
apk add iputils-ping
udhcpc -i eth1
ip route change default via *адрес_указанны в конфигах*
```

Третья команда назначает адрес для обращения к компьютерам. Адреса следующие:

* PC1.MSK - 10.10.10.254
* PC2.BRL - 10.10.20.254
* PC3.FRT - 10.10.30.254

### Проверка связи в сети

Проверим, пингуют ли компьютеры друг друга

Пинг Московского ПК с Берлинского:

![Пинг Московского ПК с Берлинского](https://github.com/IvanManomenov/routing_2024_Manomenov_Ivan_K3323/blob/main/lab2/ping_brl-msk.png)

Пинг Берлинского ПК с Франкфуртского:

![Пинг Берлинского ПК с Франкфуртского](https://github.com/IvanManomenov/routing_2024_Manomenov_Ivan_K3323/blob/main/lab2/ping_frt-brl.png)

Как можно видеть, сигнал успешно проходит

## Выводы

Цель лабораторной работы достигнута: создана требуемая сеть, коммуникация внутри сети работает
