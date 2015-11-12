iOS SDK 
=================

****

## 简介

lib 文件夹下是 iOS SDK 文件，  
example 文件夹里面是一个简单的接入示例，该示例仅供参考。

## 版本要求

iOS SDK 要求 iOS 6 及以上版本

## 接入方法

关于如何使用 SDK 请参考 [技术文档](https://pingplusplus.com/document) 或者参考 [example](https://github.com/PingPlusPlus/pingpp-ios/tree/master/example) 文件夹里的示例。

## 注意事项

由于百度钱包 SDK 不支持 iOS 模拟器，目前带有百度钱包的 Ping++ SDK 只能运行于真机。

## 「壹收款」 更新日志

### 0.9.8
* 更改：  
更新银联 SDK 到 3.1.1 版本  
添加 customParams  
添加 timeout 设置  
添加 debug 模式，用于打印 log  
银联渠道 channel 字段更改为 upacp

### 0.9.7
* 更改：  
更新银联 SDK 到 3.1.0 版本

### 0.9.6
* 更改：  
兼容 libWeChatSDK.a 1.5 版本

### 0.9.5
* 更改：  
修正 completion 中 result 的值

### 0.9.4
* 新增：  
添加微信安装提示  
添加隐藏按钮接口

## SDK 更新日志

### 2.0.2
* 更改：  
新的测试模式

### 2.0.0
* 更改：  
支持 arm64  
添加新渠道：百付宝  
调用方法更改  
callback 添加返回错误信息

### 1.0.5
* 更改：  
更换了测试环境 URL
