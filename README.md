# Site-to-Site VPN Workshop - CloudFormation 模版

![Site-to-Site VPN](https://raw.githubusercontent.com/aobao32/site-to-site-vpn-workshop/master/images/Site-to-Site-vpn.png)

本文是基于AWS中国区域使用EC2搭建Site-to-Site VPN的workshop环境。对应的Cloudformation可用于实验学习，也可以用于生产。

# 一、使用方法

使用方法如下：

- 从本代码仓库的CloudFormation目录下template文件；
- 分别在第一个Region和第二个Reion运行两个模版；
- 查看CloudFormation输出；

# 二、使用CloudFormation模版创建环境

### 1、支持区域

本实验的Cloudformation支持：

- 中国：北京和宁夏区域
- 海外：新加坡、东京、美西俄勒冈、美东俄亥俄、欧洲法兰克福、爱尔兰、伦敦。

### 2、使用场景

如果是完整实验，两端都在AWS上模拟，则可以分别在北京和宁夏各自运行一个模版。如果是用于生产环境，另一侧对接私有数据中心的物理防火墙设备，则只需要vpc1模版即可。

### 3、模版需要输入参数

本实验要求必须事先创建好用于EC2登录的Keypair，且在使用模版时候会自动查询当前Region已经存在的Keypair。如果不存在，则可以新建Keypair。如果忘记了Keypair，则必须新建，AWS无法找回丢失的Keypair。

然后进入Cloudformation中加载模版。输入模版名称，可以选择参数包括：

- 跳板机规格（保持默认即可）；
- VPN Gateway 网关所用EC2的规格；如果用于生产，可选c5.large，测试的话可选t2.small规格；

然后一路继续即可。

### 4、模版内自动创建服务清单

模版会生成如下组件：

- 1个VPC、2个公有子网（Public Subnet），2个私有子网（Private Subnet），和一个互联网网关（IGW）；
- 公有子网包含独立的路由表，有NAT网关，VPN网关，跳板机；
- 私有子网包含应用服务器；自有子网的默认路由指向NAT网关，可经NAT网关后访问外网，即可使用yum安装下载软件；
- 生成3个EC2：
    - 第一个是Windows Server 2019位于公有子网作为堡垒机；
    - 第二个是Amazon Linux 2位于公有子网作为VPN网关；
    - 第三个是Amazon Linux 2位于私有子网作为应用服务器；
- 申请3个EIP，分别绑定在：
    - NAT网关；
    - Windows跳板机；
    - VPNGateway网关；
- 三个EC2自动生成对应的安全规则组

其中，VPN网关服务器会预先完成OS级别路由转发和iptable设置，并创建VPN连接的模版文件。下一步，需要替换配置文件中的IP地址为实验中使用的真实EIP。

### 5、验证CloudFormation环境

启动模版完成后，分别验证如下：

- 登录到Windows跳板机；
- 从Windows跳板机使用Private IP登录VPN网关；
- 从Windows跳板机使用Private IP登录位于Private Subnet内部子网的Application Server；
- 从Windows跳板机使用浏览器，访问 http://应用服务器内网IP/ ，验证内网应用服务器工作正常；

验证成功后，继续下一步。

## 三、配置IPSEC VPN

### 1、创建IPSEC VPN连接

模版创建完毕后，VPN Gateway只能通过Windows跳板机登录，不允许从公网使用SSH登录。查看CloudFormation里边的Output，找到Windows跳板机IP登录到远程桌面，再从Output中找到VPN Gateway内网IP，用SSH登录。

登录到VPC1的VPN Gateway上，编辑配置文件 /etc/ipsec.d/cisco.conf，将其中的LOCALEIP和REMOTEEIP分别换成本VPC的VPC Gateway的EIP，和远端的EIP。

```
conn cisco
    authby=secret
    auto=start
    leftid=LOCALEIP
    left=%defaultroute
    leftsubnet=10.1.0.0/16
    leftnexthop=%defaultroute
    right=REMOTEEIP
    rightsubnet=192.16.0.0/16
    keyingtries=%forever
    ike=aes128-sha1;modp1024
    ikelifetime=86400s
    phase2alg=aes128-sha1
    salifetime=3600s
    pfs=no
```

编辑配置文件 /etc/ipsec.d/cisco.conf，将其中的LOCALIP和REMOTEIP分别换成本VPC的VPC Gateway的EIP，和远端的EIP。注意格式，在远端EIP地址后以冒号结尾，然后是空格，才是认证方式PSK。请保持符号和空格。

```
LOCALEIP REMOTEEIP: PSK "aws123@@@888"
```

保存退出。完成对VPC1的修改。

接下来对VPC2做相同的配置。请注意，VPC2的配置文件中，本地网关EIP需要替换为VPC2的EIP，而配置文件中的远程EIP就是VPC1的EIP。

### 2、启动VPN服务

执行如下命令启动IPSEC VPN。

```
service ipsec start
```

执行如下命令，查看配置是否正确。

```
ipsec verify
```

返回结果如下截图，则表示配置正确。

![Site-to-Site VPN](https://raw.githubusercontent.com/aobao32/site-to-site-vpn-workshop/master/images/ipsec-verify.png)

### 3、从VPN网关发起对远端的VPN网关的Ping测试

登录到本VPC的VPN网关，ping远端VPN节点的内网IP，ping成功则表示IPSEC VPN建立正常。

至此两个路由器之间已经打通。

## 四、打通路由器背后的子网

### 1、为本VPC添加去往远端VPC的路由条目

VPC1的配置步骤如下：

- 进入AWS控制台的VPC模块；
- 从左侧菜单找到路由表，找到VPC1Public和VPC1Private两张路由表，分别做如下修改；
- 点击页面下半部分，第二个标签页Route Table路由表，点击Edit Route编辑路由按钮；
- 现有路由条目不要修改，点击Add Route添加路由按钮增加一行新的路由
- Destation目标填写为192.168.0.0/16，Targe目标从下拉框中选择Instance，然后从Instance带出来的EC2清单中选择VPC1VPNGateway；
- 点击保存路由按钮；

VPC2的配置步骤如下：

- 进入AWS控制台的VPC模块；
- 从左侧菜单找到路由表，找到VPC2Public和VPC2Private两张路由表，分别做如下修改；
- 点击页面下半部分，第二个标签页Route Table路由表，点击Edit Route编辑路由按钮；
- 现有路由条目不要修改，点击Add Route添加路由按钮增加一行新的路由
- Destation目标填写为192.168.0.0/16，Targe目标从下拉框中选择Instance，然后从Instance带出来的EC2清单中选择VPC1VPNGateway；
- 点击保存路由按钮；
路由表配置完成。

### 2、使用浏览器访问远端内网应用

上述路由表配置完成后，执行如下操作：

- 在VPC1的Windows跳板机，打开浏览器，访问VPC2的内网的应用服务器80端口;
- 在VPC2的Windows跳板机，打开浏览器，访问VPC1的内网的应用服务器80端口;

交叉访问正常，表示路由配置完全正确。

### 3、在Private Subnet测试内网互相访问

从Windows跳板机上，登录位于Private Subnet的Application Server。登录成功后，ping远端另一侧位于内网的Application Server 内网IP。

如果ping成功得到响应，则表示配置完成。

## 五、使用Smokeping监控流量

### 1、修改Smokeping配置文件

### 2、查看监控数据

至此实验结束。

***

# 反馈

参考文档（有大量配置参数修正）
https://amazonaws-china.com/cn/blogs/china/openswan-vpn-solutions/

请联系 pcman.biti-at-gmail.com
