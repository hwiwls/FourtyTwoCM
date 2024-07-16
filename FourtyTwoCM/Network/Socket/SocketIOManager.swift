//
//  ChatSocketManager.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/19/24.
//

import UIKit
import SocketIO
import RxSwift
import RxCocoa
import Foundation

final class SocketIOManager {
    static let shared = SocketIOManager()

    var manager: SocketManager!
    var socket: SocketIOClient!

    let receiveChatData = PublishSubject<Result<ChatDetail, APIError>>()

    private init() {
        print("socket init")

        let baseURL = URL(string: BaseURL.baseURL.rawValue)!
        manager = SocketManager(socketURL: baseURL, config: [.log(true), .compress])
    }

    func configureSocket(with roomID: String) {
        let roomNamespace = "/chats-\(roomID)"
        socket = manager.socket(forNamespace: roomNamespace)

        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected")
        }

        socket.on(clientEvent: .disconnect) { data, ack in
            print("socket disconnected")
        }

        socket.on("chat") { [weak self] dataArray, ack in
            print("chat event received", dataArray, ack)

            guard let data = dataArray.first as? [String: Any] else {
                self?.receiveChatData.onNext(.failure(.unknown("유효하지 않은 데이터입니다. 관리자에게 문의하세요.")))
                return
            }

            do {
                let result = try JSONSerialization.data(withJSONObject: data)
                let decodedData = try JSONDecoder().decode(ChatDetail.self, from: result)
                self?.receiveChatData.onNext(.success(decodedData))
            } catch {
                let errorMessage: String
                if let errorResponseData = try? JSONSerialization.data(withJSONObject: data),
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: errorResponseData) {
                    errorMessage = errorResponse.message
                } else {
                    errorMessage = "알 수 없는 오류가 발생했습니다."
                }
                self?.receiveChatData.onNext(.failure(.unknown(errorMessage)))
            }
        }
    }

    func establishConnection() {
        socket.connect()
    }

    func leaveConnection() {
        socket.disconnect()
    }
}
