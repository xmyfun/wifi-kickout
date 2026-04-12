# WiFi信号弱客户端踢出脚本

Copyright (c) 2026 XMyFun

[English](README.md) | 简体中文

## 简介

这是一个专为OpenWrt设计的shell脚本，用于通过比较信号强度与阈值来踢出WiFi信号过弱的客户端。该脚本可以定期通过crontab触发或通过循环`sleep`命令执行，从而改善网络漫游性能。

该脚本在原始OpenWrt (ash shell)上运行，无需额外安装任何软件包，同时也兼容bash shell。

本仓库受到 [nikito7/kickout-wifi](https://github.com/nikito7/kickout-wifi) 的启发，感谢他的原创工作！

我对部分踢出规则进行了修改以满足个人需求，因此开设了此新仓库以接受我版本的问题反馈。

## 参数设置

使用前建议根据您的偏好设置以下4个参数：

**thr**=-75 是阈值（dBm），始终为负数！

**mode** 可设置为 "white" 或 "black"（始终小写）：
- 在 "blacklist" 模式下，**仅**黑名单中的客户端可以被踢出；
- 在 "whitelist" 模式下，脚本会踢出**除**白名单外**所有**客户端。

因此有**黑名单**和**白名单**，注意类型是字符串而不是数组，不同的MAC地址用逗号分隔。

默认选择的是 "white"list 模式，并且白名单为空时，任何连接的客户端如果信号强度低于阈值 (**thr**) 都可能会被路由器踢出。

## 隐藏功能

脚本中包含注释掉的代码，提供额外的功能。如果您不理解这些功能，请保持这些行被注释掉即可。

## 安装方法

首先，将脚本文件 `kickout.sh` 复制到您的路由器（例如使用 scp），在我的情况下位置是 `/usr/kickout.sh`。

然后，我建议通过crontab定期触发脚本，最高频率为每分钟1次。要做到这一点，请在 `/etc/crontabs/root` 文件中添加以下行：

`*/1 * * * * /bin/sh /usr/kickout.sh`

否则，您可能更喜欢使用更高的频率，通过在 kickout.sh 中使用 "sleep" 命令然后再次调用自身来实现。另一种方法是使用带有 "sleep" 命令的 *while* - *do* - *done* 循环。

日志文件位于 `/tmp/wifi-kickout.log`。某些操作也会记录在系统日志 `/var/log/message` 中。

## 未来改进

使用类似数组的结构为路由器的不同wlan设备设置不同的阈值。由于ash不支持列表，因此似乎需要进行字符串操作。

## 问题反馈

欢迎随时通过 [issues](issues) 页面提出问题。

## 许可证

本项目采用 MIT 许可证。详细信息请查看 [LICENSE](LICENSE) 文件。