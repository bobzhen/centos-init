#!/bin/bash
# Program: system_init_shell
# Author Looly
cat << EOF
 +--------------------------------------------------------------+
 |          === Welcome to CentOS 7.x System init ===           |
 +--------------------------------------------------------------+
 +---------------------------by Looly--------------------------+
EOF

#update system pack
yum -y install net-tools lrzsz gcc gcc-c++ make cmake libxml2-devel openssl-devel curl curl-devel unzip sudo ntp libaio-devel wget vim ncurses-devel autoconf automake zlib* fiex* libxml* libmcrypt* libtool-ltdl-devel* python-devel git

#set ntp
echo "* */5 * * * /usr/sbin/ntpdate ntp.api.bz > /dev/null 2>&1" >> /var/spool/cron/root
service crond restart

#set ulimit
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
 *           soft   nofile       102400
 *           hard   nofile       102400
 *           soft   nproc        102400
 *           hard   nproc        102400
EOF

#set ssh
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
#sed -i 's/#Port 22/Port 6343/' /etc/ssh/sshd_config
service sshd restart

#set sysctl
true > /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
 net.ipv4.ip_forward = 0
 net.ipv4.conf.default.rp_filter = 1
 net.ipv4.conf.default.accept_source_route = 0
 kernel.sysrq = 0
 kernel.core_uses_pid = 1
 net.ipv4.tcp_syncookies = 1
 kernel.msgmnb = 65536
 kernel.msgmax = 65536
 kernel.shmmax = 68719476736
 kernel.shmall = 4294967296
 net.ipv4.tcp_max_tw_buckets = 6000
 net.ipv4.tcp_sack = 1
 net.ipv4.tcp_window_scaling = 1
 net.ipv4.tcp_rmem = 4096 87380 4194304
 net.ipv4.tcp_wmem = 4096 16384 4194304
 net.core.wmem_default = 8388608
 net.core.rmem_default = 8388608
 net.core.rmem_max = 16777216
 net.core.wmem_max = 16777216
 net.core.netdev_max_backlog = 262144
 net.core.somaxconn = 262144
 net.ipv4.tcp_max_orphans = 3276800
 net.ipv4.tcp_max_syn_backlog = 262144
 net.ipv4.tcp_timestamps = 0
 net.ipv4.tcp_synack_retries = 1
 net.ipv4.tcp_syn_retries = 1
 net.ipv4.tcp_tw_recycle = 1
 net.ipv4.tcp_tw_reuse = 1
 net.ipv4.tcp_mem = 94500000 915000000 927000000
 net.ipv4.tcp_fin_timeout = 1
 net.ipv4.tcp_keepalive_time = 1200
 net.ipv4.ip_local_port_range = 1024 65535
EOF
/sbin/sysctl -p
echo "sysctl set OK!!"

#disable selinux
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
setenforce 0

#vim setting
sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
cat >> /root/.vimrc << EOF
set fenc=utf-8 "设定默认解码
set fencs=utf-8,usc-bom,euc-jp,gb18030,gbk,gb2312,cp936
set nocp "或者 set nocompatible 用于关闭VI的兼容模式
set number "显示行号
set ai "或者 set autoindent vim使用自动对齐，也就是把当前行的对齐格式应用到下一行
set si "或者 set smartindent 依据上面的对齐格式，智能的选择对齐方式
set tabstop=4 "设置tab键为4个空格
set sw=4 "或者 set shiftwidth 设置当行之间交错时使用4个空格
set ruler "设置在编辑过程中,于右下角显示光标位置的状态行
set incsearch "设置增量搜索,这样的查询比较smart
set showmatch "高亮显示匹配的括号
set matchtime=5 "匹配括号高亮时间(单位为 1/10 s)
set ignorecase "在搜索的时候忽略大小写
syntax on
EOF

#bash setting
cat >> /root/.vimrc << EOF

alias ls='ls --color=auto'
alias ll='ls -Al'
alias la='ll -A'

alias vi='vim'

alias df='df -h'
alias du='du -h'
EOF

#setup pip
wget -O - 'https://bootstrap.pypa.io/get-pip.py' | python

#关闭firewall，打开iptables
systemctl mask firewalld
systemctl stop firewalld
yum -y install iptables-services
systemctl enable iptables
systemctl start iptables
echo 'iptables Ok!'

cat << EOF
 +--------------------------------------------------------------+
 |                    ===System init over===                    |
 +--------------------------------------------------------------+
 +---------------------------by Looly--------------------------+
EOF
echo "###############################################################"