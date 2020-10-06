//
// CDVWkWebviewSocket.swift
// HelloCordova
//
// Created by Todd Tarsi on 10/02/20.
//
import Foundation
import StarScream

@interface CDVInvokedUrlCommand : NSObject {
  NSString* _callbackId;
  NSString* _className;
  NSString* _methodName;
  NSArray* _arguments;
}

class CDVWKWebviewNativeWS : CDVPlugin {
  @objc(createSocket:)
  func createSocket(command : CDVInvokedUrlCommand) //this method will be called web app
  {
    let data: Data // received from a network request, for example
    let json = try? JSONSerialization.jsonObject(with: data, options: [])
    let request = URLRequest(url: URL(string: data.url)!)
    request.timeoutInterval = 5
    socket = WebSocket(request: request)
    socket.delegate = self
    socket.connect()
    socket.onEvent = { event in
      switch event {
        case .connected(let headers):
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"connected\", \"headers\": \"\(headers)\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .disconnected(let reason, let closeCode):
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"disconnected\", \"reason\": \"\(reason)\", \"closeCode\": \"\(closeCode)\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .text(let text):
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"text\", \"text\": \"\(text)\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .binary(let data):
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"binary\", \"data\": \"\(data)\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .pong(let pongData):
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"pong\", \"data\": \"\(pongData)\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .ping(let pingData):
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"ping\", \"data\": \"\(pingData)\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .error(let error):
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"error\", \"error\": \"\(error)\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .viabilityChanged:
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"viabilityChanged\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .reconnectSuggested:
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"reconnectSuggested\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .cancelled:
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"cancelled\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
      }
    }
  }
}
