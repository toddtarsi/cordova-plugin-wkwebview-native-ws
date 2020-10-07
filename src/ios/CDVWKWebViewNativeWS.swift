//
// CDVWkWebviewSocket.swift
// HelloCordova
//
// Created by Todd Tarsi on 10/02/20.
//
import Foundation

@interface CDVInvokedUrlCommand : NSObject {
  NSString* _callbackId;
  NSString* _className;
  NSString* _methodName;
  NSArray* _arguments;
}

struct IDSocket {
  socket: URLSessionWebSocketTask
  ID: Int
}
class SocketManager {
  let socketID = 0
  let socketsWithIDs: [IDSocket] = []
  func getIndex(ID: Int) -> Int
  {
    for (index, socketWithID) in socketsWithIDs.enumerated() {
      if (socketWithID.ID == ID) {
        return socketWithID.socket
      }
    }
    return -1
  }
  func getID(socket: URLSessionWebSocketTask) -> Int
  {
    for (index, socketWithID) in socketsWithIDs.enumerated() {
      if (socketWithID.socket == socket) {
        return socketWithID.ID
      }
    }
    return -1  
  }
  func getSocket(ID: Int) -> URLSessionWebSocketTask
  {
    let index = self.getIndex(ID)
    if (index != -1) {
      return socketsWithIDs[index].socket
    }
    return nil
  }
  func store(socket: URLSessionWebSocketTask) -> Int
  {
    let _socketID: Int = socketID
    let socketWithID = IDSocket(socket: socket, ID: _socketID)
    socketsWithIDs.append(socketWithID)
    socketID += 1
    return _socketID
  }
  func release(ID: Int) -> URLSessionWebSocketTask
  {
    let index = self.getIndex(ID)
    if (index != -1) {
      return sockets.removeAt(index).socket
    }
    return nil
  }
}

let socketManager = SocketManager() 
class CDVWKWebviewNativeWS : CDVPlugin {
  @objc(open:)
  func open(command : CDVInvokedUrlCommand) //this method will be called web app
  {
    let url = command._arguments[0];
    let protocols = command._arguments[1];
    let data: Data = command._arguments[2];
    let request = URLRequest(url: URL(string: url)!)
    let urlSession = URLSession(configuration: .default)
    let webSocketTask = urlSession.webSocketTask(with: url, protocols: protocols)
    webSocketTask.resume()
    socketManager.store(webSocketTask)

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
  @objc(receive:)
  func receive(command : CDVInvokedUrlCommand) //this method will be called web app
  {
    let ID = command._arguments[0]
    let webSocketTask = socketManager.getSocket(ID)
    webSocketTask.receive { result in
      switch result {
        case .failure(let error):
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"error\", \"error\": \"\(error)\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
        case .success(let message):
          switch message {
            case .string(let text):
              let result = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "{ \"event\": \"string\", \"string\": \"\(string)\" }"
              )
              self.commandDelegate.send(result, callbackId: command.callbackId)
            case .data(let data):
              let result = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "{ \"event\": \"data\", \"data\": \"\(data)\" }"
              )
              self.commandDelegate.send(result, callbackId: command.callbackId)
          }
        default:
          let result = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "{ \"event\": \"none\" }"
          )
          self.commandDelegate.send(result, callbackId: command.callbackId)
      }
    }
  }
  @objc(send:)
  func send(command : CDVInvokedUrlCommand) //this method will be called web app
  {
    let ID = command._arguments[0]
    let webSocketTask = socketManager.getSocket(ID)
    let body = command._arguments[1];
    webSocketTask.send(body)
    let result = CDVPluginResult(
      status: CDVCommandStatus_OK,
      messageAs: "{ \"event\": \"sent\" }"
    )
    self.commandDelegate.send(result, callbackId: command.callbackId)
  }
  @objc(close:)
  func close(command : CDVInvokedUrlCommand) //this method will be called web app
  {
    let ID = command._arguments[0]
    let webSocketTask = socketManager.getSocket(ID)
    webSocketTask.cancel(closeCode: .goingAway, reason: nil)
    let result = CDVPluginResult(
      status: CDVCommandStatus_OK,
      messageAs: "{ \"event\": \"closed\" }"
    )
    self.commandDelegate.send(result, callbackId: command.callbackId)
  }
}
