* *Курс: Введение в маршрутизацию на предприятии*

* *Студент: Маноменов Иван Андреевич*

* *Группа: К3323*

* *Дата сдачи: 30.10.24*

# Отчет по лабораторной работе №1 "Установка ContainerLab и развёртывание тестовой сети связи"

## Цель работы
Ознакомиться с инструментом ContainerLab и методами работы с ним, изучить работу VLAN, IP адресации и т.д.
## Ход работы
Лабораторная работа выполнялась на компьютере с операционной системой Linux, оболочка Ubuntu 22.04.3

Перед началом лабораторной работы на компьютер были установлены Docker и Containerlabs, а также скачан требуемый репозиторий с GitHub

### Настройка роутера и маршрутизаторов

В папке config были созданы файлы с конфигурацией роутера и маршрутизаторов

Файл switch1.cfg:

```
/interface bridge
add name=bridge10
add name=bridge20
/interface vlan
add interface=ether2 name=vlan10 vlan-id=10
add interface=ether3 name=vlan11 vlan-id=10
add interface=ether2 name=vlan20 vlan-id=20
add interface=ether4 name=vlan21 vlan-id=20
/interface bridge port
add bridge=bridge10 interface=vlan10
add bridge=bridge10 interface=vlan11
add bridge=bridge20 interface=vlan21
add bridge=bridge20 interface=vlan20
/ip dhcp-client
add disabled=no interface=bridge10
add disabled=no interface=bridge20
```

Файл switch2.cfg:

```
/interface bridge
add name=bridge10
/interface vlan
add interface=ether2 name=vlan10 vlan-id=10
/interface bridge port
add bridge=bridge10 interface=vlan10
add bridge=bridge10 interface=ether3
/ip dhcp-client
add disabled=no interface=bridge10
```

Файл switch3.cfg:

```
/interface bridge
add name=bridge20
/interface vlan
add interface=ether2 name=vlan20 vlan-id=20
/interface bridge port
add bridge=bridge20 interface=vlan20
add bridge=bridge20 interface=ether3
/ip dhcp-client
add disabled=no interface=bridge20
```

Файл router.cfg:

```
/interface vlan
add interface=ether2 name=vlan10 vlan-id=10
add interface=ether2 name=vlan20 vlan-id=20
/ip pool
add name=vlan10_pool ranges=10.10.10.0-10.10.10.254
add name=vlan20_pool ranges=10.10.20.0-10.10.20.254
/ip dhcp-server
add address-pool=vlan10_pool disabled=no interface=vlan10 name=dhcp-vlan10
add address-pool=vlan20_pool disabled=no interface=vlan20 name=dhcp-vlan20
/ip address
add address=10.10.10.129/25 interface=vlan10 network=10.10.10.128
add address=10.10.20.129/25 interface=vlan20 network=10.10.20.128
add address=10.10.2.2/19 interface=ether2 network=10.10.0.0
/ip dhcp-server network
add address=10.10.10.128/25 gateway=10.10.10.129
add address=10.10.20.128/25 gateway=10.10.20.129
```

### Создание топологии

Был написан файл lab_1.yaml, задающий топологию сети:

```
name: lab_1

topology:
 nodes:
  Router1:
   kind: vr-mikrotik_ros
   image: vrnetlab/mikrotik_routeros:6.47.9
   mgmt-ipv4: 192.168.2.254
   startup-config: /home/man-men-off/ITMO/routing_labs/lab1/configs/router.cfg
  L3_Switch1:
   kind: vr-mikrotik_ros
   image: vrnetlab/mikrotik_routeros:6.47.9
   startup-config: /home/man-men-off/ITMO/routing_labs/lab1/configs/switch1.cfg

   mgmt-ipv4: 192.168.2.10
  L3_Switch2:
   kind: vr-mikrotik_ros
   image: vrnetlab/mikrotik_routeros:6.47.9
   mgmt-ipv4: 192.168.2.20
   startup-config: /home/man-men-off/ITMO/routing_labs/lab1/configs/switch2.cfg

  L3_Switch3:
   kind: vr-mikrotik_ros
   image: vrnetlab/mikrotik_routeros:6.47.9
   mgmt-ipv4: 192.168.2.30
   startup-config: /home/man-men-off/ITMO/routing_labs/lab1/configs/switch3.cfg

  PC1:
   kind: linux
   image: alpine:latest
   mgmt-ipv4: 192.168.2.100
  PC2:
   kind: linux
   image: alpine:latest
   mgmt-ipv4: 192.168.2.101
 links:
   - endpoints: ["Router1:eth1", "L3_Switch1:eth1"]
   - endpoints: ["L3_Switch2:eth1", "L3_Switch1:eth2"]
   - endpoints: ["L3_Switch3:eth1", "L3_Switch1:eth3"]
   - endpoints: ["PC1:eth1", "L3_Switch2:eth2"]
   - endpoints: ["PC2:eth1", "L3_Switch3:eth2"]

mgmt:
 network: static
 ipv4-subnet: 192.168.2.0/24
```
При помощи команды sudo containerlab deploy -t lab1.yml топология была создана, а при помощи sudo containerlab graph -t lab1.yml визуализирована, также на граф были добавлены назначенные ip (результат на рисунке ниже)
![Топология сети с ip](https://github.com/IvanManomenov/routing_2024_Manomenov_Ivan_K3323/blob/main/lab1/topology_with_ip.png)
### Присвоение ip ПК

Для присвоения ip запустим компьютеры через оболочку sh следующей командой:
```
docker exec -it clab-lab_1-PC1 sh
```

Далее запустим udhcpc для автоматического присвоения ip, получим следующее:

```
/ # udhcpc -i eth1
udhcpc: started, v1.36.1
udhcpc: broadcasting discover
udhcpc: broadcasting select for 10.10.10.252, server 10.10.10.129
udhcpc: lease of 10.10.10.252 obtained from 10.10.10.129, lease time 600
```

Таким образом, PC1 получил ip 10.10.10.252


Аналогично PC2 был присвоен ip 10.10.20.252

### Проверка связности

Сделаем несколько пингов.

Пинг первого компьютера с роутера:

![Пинг1](https://github.com/IvanManomenov/routing_2024_Manomenov_Ivan_K3323/blob/main/lab1/ping_router_pc1.png)

Пинг второго компьютера с маршрутизатора:

![Пинг2](https://github.com/IvanManomenov/routing_2024_Manomenov_Ivan_K3323/blob/main/lab1/ping_L3_pc2.png)

Как можно видеть, пакеты доходят успешно

## Выводы

В рамках выполнения лабораторной работы были изучены основы работы с Containerlabs: написание топологии сети, конфигурации элементов.
