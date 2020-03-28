# Site-to-Site VPN Workshop - CloudFormation 模版

![Site-to-Site VPN](https://raw.githubusercontent.com/aobao32/transit-gateway-workshop/master/transit-gateway-with-Inter-region-peering.png)

# 使用方式

使用方法如下：

- 1、获取CloudFormation文件
- 2、分别在第一个Region和第二个Reion运行两个模版
- 3、查看CloudFormation输出

# 模版内容说明

### 实验三、创建两个VPC之间的Peering打通VPC的模版说明

本实验模版如下（支持AWS中国北京和宁夏区域）：

- vpc1.yml
- vpc2.yml

首先在Cloudformation中加载模版。输入模版名称，可以选择参数包括：

- 跳板机规格（保持默认即可）
- VPN Gateway 网关所用EC2的规格；如果用于生产，可选c5.large，测试的话可选t2.small

模版都会生成：

- 1个VPC、2个公有子网，2个私有子网，和一个互联网网关；
- 公有子网包含独立的路由表，有NAT网关，VPN网关，跳板机；
- 私有子网包含应用服务器；
- 自动生成3个EC2：
    - 第一个是Windows Server 2019位于公有子网作为堡垒机
    - 第二个是Amazon Linux 2位于公有子网作为VPN网关
    - 第三个是Amazon Linux 2位于私有子网作为应用服务器
- 三个EC2自动生成对应的安全规则组

***

# 反馈

请联系 pcman.biti-at-gmail.com
