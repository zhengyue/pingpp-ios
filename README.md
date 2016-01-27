# Pingpp iOS SDK

## Overview

This demo is based on the original [Pingpp iOS SDK](https://github.com/PingPlusPlus/pingpp-ios). The UI is changed to English and some comments were added.

- `lib` - Ping++ iOS SDK file
- `example` - a simple demo application

## iOS version requirement

iOS 6.0+

## Installation

### Using CocoaPods

    pod 'Pingpp', '~> 2.2.0'
    pod 'Pingpp/Wx', '~> 2.2.0'
    pod 'Pingpp/Alipay', '~> 2.2.0'
    pod 'Pingpp/UnionPay', '~> 2.2.0'

### Extra configuration for iOS 9

To use AliPay and WeChat Pay in iOS 9, add following to `Info.plist`:

    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>weixin</string>
        <string>wechat</string>
        <string>alipay</string>
     </array>
