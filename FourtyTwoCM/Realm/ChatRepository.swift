//
//  ChatRepository.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/11/24.
//

import Foundation
import RealmSwift
import RxSwift

class ChatRepository {
    private let realm = try! Realm()
    
    // 채팅방 저장 함수
    func saveChatRoom(_ chatRoom: ChatRoom) {
        try! realm.write {
            realm.add(chatRoom, update: .modified)
        }
    }

    // 특정 roomID에 대해 가장 최근 메세지의 전송 시간을 불러오는 함수
    func fetchLastMessageTimestamp(for roomId: String) -> Date? {
        return realm.objects(ChatMessage.self)
            .filter("roomId == %@", roomId)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .first?
            .createdAt
    }

    // 특정 roomId에 대해 서버로부터 온 채팅 내역 응답값(배열)을 저장할 함수
    func saveMessages(_ messages: [ChatMessage]) {
        try! realm.write {
            realm.add(messages, update: .modified)
        }
    }

    // 특정 유저와의 채팅방이 존재하는지 확인하는 함수
    func isChatRoomExists(with userId: String) -> Bool {
        return !realm.objects(ChatRoom.self)
            .filter("ANY participants.userId == %@", userId)
            .isEmpty
    }
    
    // 특정 유저와의 채팅방 ID를 확인하는 함수
    func fetchChatRoomId(with userId: String) -> String? {
        return realm.objects(ChatRoom.self)
            .filter("ANY participants.userId == %@", userId)
            .first?
            .roomId
    }
    
    // 특정 유저의 participantId와 일치하는 채팅방의 모든 메시지를 가져오는 함수
    func fetchMessagesUsingRoomId(for participantId: String) -> [ChatMessage] {
        guard let roomId = fetchChatRoomId(with: participantId) else {
            print("해당 participantId로 채팅방을 찾을 수 없습니다: \(participantId)")
            return []
        }
        
        let results = realm.objects(ChatMessage.self)
            .filter("roomId == %@", roomId)
            .sorted(byKeyPath: "createdAt", ascending: true)
        
        return Array(results)
    }
    
    // 서버와 통신하여 최신 채팅 내역을 받아오는 함수
    func updateChatHistory(roomId: String) -> Single<[ChatDetail]> {
        let lastMessageDate = fetchLastMessageTimestamp(for: roomId)
        let dateFormatter = ISO8601DateFormatter()
        let cursorDate = lastMessageDate != nil ? dateFormatter.string(from: lastMessageDate!) : nil
        let query = ChatHistoryQuery(cursor_date: cursorDate)
        
        return NetworkManager.performRequest(route: .getChatHistory(roomId: roomId, query: query), dataType: ChatMessageModel.self)
            .map { $0.data }
            .do(onSuccess: { chatDetails in
                try! self.realm.write {
                    for detail in chatDetails {
                        let sender = ChatSender(userId: detail.sender.userID, nick: detail.sender.nick)
                        let message = ChatMessage(
                            chatId: detail.chatID,
                            roomId: detail.roomID,
                            content: detail.content,
                            createdAt: dateFormatter.date(from: detail.createdAt)!,
                            sender: sender
                        )
                        self.realm.add(message, update: .modified)
                    }
                }
            })
    }
    
}
