//
//  Network.swift
//
//
//  Created by Joe Maghzal on 6/5/24.
//

import Foundation

//public struct Network {
//    public static let client = NetworkClient()
//}
//
//@Client
//public struct NetworkClient {
//    public var command: ClientCommand {
//        RequestCommand()
//            
//    }
//}

// Adapter
// Request 
    // Authenticator
    // Trust
// Validator
// Retrier 
// Handler
// Redirect

actor NetworkClient {
    var tasks: [URLRequest: NetworkTask] = [:]
    
    func request() {
        
    }
}

open class NetworkClientDelegate: NSObject {
    
}

//MARK: - URLSessionDelegate
extension NetworkClientDelegate: URLSessionDelegate {
    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        //
    }
}

//MARK: - URLSessionTaskDelegate
extension NetworkClientDelegate: URLSessionTaskDelegate {
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        return (URLSession.AuthChallengeDisposition.useCredential, nil)
    }
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        
    }
}

struct NetworkTask {
    private let id: UUID
    private let sessionTask: URLSessionTask
    private let decoder: JSONDecoder
    
    var state: URLSessionTask.State {
        return sessionTask.state
    }
}

//actor NetworkTask: NSObject {
//    let request: any Request
////    var state
//    init(request: some Request) {
//        self.request = request
//    }
//    func ks() async {
//        URLSessionDataTask().progress
//        URLSessionDataTask().priority
//        URLSessionDataTask().state
//        URLSessionDataTask().resume()
//        URLSessionDataTask().cancel()
//        URLSessionDataTask().suspend()
//        URLSessionDataTask().countOfBytesReceived //
////        URLSession.shared.dataTask(with: URLRequest(url: URL(string: "")!)).sus x
//    }
//}



extension NetworkTask {
    enum State: Int {
        case running
        case suspended
        case cancelled
        case finished
    }
}
