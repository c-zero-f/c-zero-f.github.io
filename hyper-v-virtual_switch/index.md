# Hyper-V 配置虚拟交换机


## 注意事项

* **手动创建的** **​`10.10-NAT-Switch`​**​ **（Hyper-V 内部 / 专用类型交换机）本身不包含 DHCP 功能**，因此连接到该交换机的虚拟机或 Windows 系统都无法自动获取 IP，必须手动配置。

## 创建路由

* 创建 `10.10-NAT-Switch`​ 及绑定 NAT 规则的完整教程

### 步骤 1：创建内部类型的虚拟交换机 `10.10-NAT-Switch`​

内部类型的交换机是实现 NAT 功能的前提（仅虚拟机与宿主机互通，需绑定 NAT 规则才能上外网）。

```powershell
# 以管理员身份运行 PowerShell，创建内部虚拟交换机
New-VMSwitch -Name "10.10-NAT-Switch" -SwitchType Internal
```

### 步骤 2：为交换机对应的虚拟网卡分配静态网关 IP

创建内部交换机后，Windows 会自动生成一个同名的虚拟网卡，需要给它分配一个网段的网关 IP（例如 10.10.0.1/24）。

```powershell
# 1. 找到 10.10-NAT-Switch 对应的虚拟网卡的 ifIndex
$ifIndex = (Get-NetAdapter -Name "vEthernet (10.10-NAT-Switch)").ifIndex

# 2. 为该网卡分配静态 IP（网关，网段可根据需求修改）
New-NetIPAddress -IPAddress 10.10.0.1 -PrefixLength 24 -InterfaceIndex $ifIndex
```

* 网段说明：`10.10.0.1/24`​ 表示网关是 `10.10.0.1`​，虚拟机可分配的 IP 范围是 `10.10.0.2~10.10.0.254`​。
* 如果提示 IP 地址已存在，说明该网卡已有 IP，可跳过此步或先删除旧 IP：

```powershell
Remove-NetIPAddress -InterfaceIndex $ifIndex -Confirm:$false
```

### 步骤 3：创建 NAT 网络规则 `10.10-NAT-Network`​

将 NAT 规则绑定到上述网关所在的网段，让交换机具备 DHCP 分配 IP 和外网转发能力。

```powershell
# 创建 NAT 规则，网段必须和网关的网段一致（10.10.0.0/24）
New-NetNat -Name "10.10-NAT-Network" -InternalIPInterfaceAddressPrefix "10.10.0.0/24"

# 验证 NAT 规则是否创建成功
Get-NetNat
```

## 使用路由

### Redhat 手动配置 IP

* 编辑网卡配置文件（永久生效）

1. 打开 eth0 的配置文件：

    ```bash
    vi /etc/sysconfig/network-scripts/ifcfg-eth0
    ```

2. 修改以下参数（覆盖原有内容）：

    ```ini
    TYPE=Ethernet
    BOOTPROTO=static          # 静态 IP 模式
    NAME=eth0
    DEVICE=eth0
    ONBOOT=yes                # 开机自动激活
    IPADDR=10.10.0.3          # 手动配置的 IP
    PREFIX=24                 # 子网掩码（24 对应 255.255.255.0）
    GATEWAY=10.10.0.1         # 网关
    DNS1=223.5.5.5            # DNS 服务器 223.5.5.5 是阿里云提供的公共 DNS 服务器 IP 地址
    ```

3. 保存文件后，重启网络服务：

    ```bash
    systemctl restart NetworkManager
    ```

4. 验证配置：

    ```bash
    ip addr show eth0
    ```

### window 手动配置 IP

#### 进入配置界面

![image](/images/Hyper-V-Virtual_Switch/image-20251213203128-hv8xigz.png)

![image](/images/Hyper-V-Virtual_Switch/image-20251213203213-hbc9jdl.png)

![image](/images/Hyper-V-Virtual_Switch/image-20251213203321-greapjz.png)

#### 配置为固定的 IP

* 223.5.5.5 是阿里云提供的公共 DNS 服务器，配置这个就能正常的访问外网

![image](/images/Hyper-V-Virtual_Switch/image-20251213203726-0xw71c0.png)

‍

