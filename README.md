# pressure

#### 介绍
CPU,内存,网卡,磁盘 压力测试工具脚本

## 系统环境
```
系统版本：CentOS Linux release 7.6.1810 (Core)
系统内核：3.10.0-957.el7.x86_64
网络环境：要求服务器可以连通网络
规格大小：建议使用不小于1C1G
网卡数量：建议不小于1块网卡
系统盘：  建议使用不小于100GB的空间
数据盘：  建议使用不小于100GB的空间（可选）
```

## 配置YUM仓库
```
rm -f /etc/yum.repos.d/*.repo
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo
yum repolist
```

## 软件包安装
```
yum -y install ansible vim git
```

## 拉取远程代码
```
cd /root/
git clone https://gitee.com/chriscentos/pressure.git
```

## 复制模版信息
```
cd /root/system-init/
\cp group_vars/all-template group_vars/all
\cp hosts-example hosts
```

## 配置主机列表
vim hosts
```
[nodes01]
192.168.56.29 
192.168.56.30

[all:vars]
ansible_ssh_port=22            ## 设置远程服务器端口
ansible_ssh_user=root          ## 设置远程服务器用户
ansible_ssh_pass="bkce123"     ## 设置远程服务器密码
```


## 初始化变量
vim group_vars/all
```
## 设置CPU的核数，例如设置1核 则1核CPU会打满至100%
cpu_pressure_limit: '7'

## 设置打满内存的百分比
mem_pressure_limit: 95

## network check config
check_test_ping_ip: '80'
check_net_name: 'eth1'
check_net_speed: '1000'
check_net_mtu: '1500'
check_net_segment: '192.168.56'
check_net_internet: 'www.baidu.com'

## network pressure config
net_segment: '{{ check_net_segment }}'
net_pressure_size: '50'
net_pressure_time: '999999'
net_pressure_iptables_accept_port: '5001'

## disk pressure test config
disk_test_time: 14400
disk_numjobs: 16
disk_block_size: '4k'               # 4k 4m 16k
disk_readwrite_type: 'randwrite'    #  write or  read
disk_iodepth: 8
disk_name_list:
  - '/data/iotest'
```
公钥信息获取方式：cat /root/.ssh/id_rsa.pub 

## 服务器检查
检查远程服务器的SSH连接状态
```
ansible -m ping nodes01
192.168.56.29 | SUCCESS => {
192.168.56.30 | SUCCESS => {
```

## CPU压力测试

CPU压力测试
```
ansible-playbook playbooks/cpu_pressure.yml -e "nodes=nodes" --tags=cpu_pressure
```
CPU取消压力测试
```
ansible-playbook playbooks/cpu_pressure.yml -e "nodes=nodes" --tags=clear_cpu_pressure
```

## 内存压力测试
内存压力测试
```
ansible-playbook playbooks/mem_pressure.yml -e "nodes=nodes" --tags="mem_pressure"
```

内存取消压力测试
```
ansible-playbook playbooks/mem_pressure.yml -e "nodes=nodes" --tags="clear_mem_pressure"
```

## 网络压力测试

网络压力测试
```
ansible-playbook playbooks/net_pressure.yml -e "nodes=nodes" --tags="net_env_check,net_pressure"
```

网络取消压力测试
```
ansible-playbook playbooks/net_pressure.yml -e "nodes=nodes" --tags="clear_net_pressure"
```


## 磁盘压力测试
关于此盘压力测试，在测试之前，一定要确保测试的此盘为裸盘，没有任何数据
磁盘压力测试
```
ansible-playbook playbooks/disk_pressure.yml -e "nodes=nodes" --tags="disk_pressure"
```

磁盘取消压力测试
```
ansible-playbook playbooks/disk_pressure.yml -e "nodes=nodes" --tags="disk_mem_pressure"
```






