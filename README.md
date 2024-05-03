# [VChatCloud](https://vchatcloud.com) iOS Sample App

![Languages](https://img.shields.io/badge/language-Swift-informational)  
![Platform](https://img.shields.io/badge/platform-iOS-informational)

This sample demonstrates how you can use [VChatCloud Swift SDK](https://github.com/e7works-git/VChatCloud-Swift-SDK) in your own Flutter application. VChatCloud provides an easy-to-use Chat API, Chat SDKs, and a fully-managed chat platform on the backend that provides upload files, open graph, translation.

## Table of contents

- [VChatCloud iOS Sample App](#vchatcloud-ios-sample-app)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Requirements](#requirements)
  - [Getting started](#getting-started)
    - [Notice!](#notice)
  - [Getting Help](#getting-help)

## Introduction

This sample consists of several features, including:

- Connecting and disconnecting from VChatCloud server
- Join channel
- Send a message (text, emoticon and file message)
- Receive channel events and handle appropriately

## Requirements

The minimum requirements for this demo are:

- Xcode 14 and later versions
- Swift 5

## Getting started

This sample demonstrates a few example how you can use SDK on your application. The sample consists of the following:

- Connect and disconnect from VChatCloud Server
- Join channel
- Send / fetch a message (text and file message)
- Receive channel events and handle appropriately
- Update / Fetch user profile information (profile image / nickname)
- Get the last messages of a channel

### Notice!

To run this demo, create a chat room in VChatCloud's CMS, copy the ChannelKey of the chat room created in the dashboard, and paste it into the roomId value in `views/login/LoginView.swift`. You can then run the sample from the directory by typing flutter run in the command window.

```swift
// views/login/LoginView.swift
let channelKey = "YOUR_CHANNEL_KEY"; // input your channel key from VChatCloud CMS
```

## Getting Help

Check out the Official VChatCloud [iOS docs](https://vchatcloud.com/doc/ios/chat/gettingStarted.html) tutorials.
