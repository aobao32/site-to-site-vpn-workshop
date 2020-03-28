# Site-to-Site VPN Workshop - CloudFormation 模版

![Site-to-Site VPN](https://raw.githubusercontent.com/aobao32/site-to-site-vpn-workshop/master/Site-to-Site-vpn.png)

本文是基于AWS中国区域使用EC2搭建Site-to-Site VPN的workshop环境。对应的Cloudformation可用于实验学习，也可以用于生产。

- vpc1.yml
- vpc2.yml

# 一、使用方法

使用方法如下：

- 从本代码仓库的CloudFormation目录下template文件；
- 分别在第一个Region和第二个Reion运行两个模版；
- 查看CloudFormation输出；

# 二、说明

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

- 登录到Windows跳板机
- 从Windows跳板机使用Private IP登录VPN网关
- 从Windows跳板机使用Private IP登录位于Private Subnet内部子网的Application Server
- 从Windows跳板机使用浏览器，访问 http://应用服务器内网IP/ ，验证内网应用服务器工作正常 

验证成功后，继续下一步。

### 6、后续实验过程

（1）模版创建完毕后，VPN Gateway只能通过Windows跳板机登录，不允许从公网使用SSH登录。
（2）对VPNGateway服务器完成openswan的配置，替换配置文件中的IP地址为实验中使用的真实EIP。
（3）启动VPN服务，确认连接建立
（4）从两个VPN网关互相ping
（5）从Windows跳板机登录到位于内网的Application服务器，然后ping另一侧的Applicatin服务。如果ping通则表示内网通过VPN网关转发成功。

至此实验结束。

***

# 反馈

请联系 pcman.biti-at-gmail.com
