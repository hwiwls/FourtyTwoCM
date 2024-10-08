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
    private var realm: Realm

    init(userId: String) {
        if let realm = RealmManager.shared.configureRealm(for: userId) {
            self.realm = realm
        } else {
            fatalError("Failed to configure Realm for user: \(userId)")
        }
    }
    
    // 채팅방 저장 함수
    func saveChatRoom(_ chatRoomModel: ChatRoomModel) {
        let participants = List<User>()
        participants.append(objectsIn: chatRoomModel.participants.map {
            User(userId: $0.userID, nick: $0.nick)
        })
        
        let chatRoom = ChatRoom(roomId: chatRoomModel.roomID)
        chatRoom.participants = participants
        
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
    
    // 특정 roomId에 대해 서버로부터 온 채팅 내역 응답값(배열)을 저장할 함수
    func saveMessages(_ chatDetails: [ChatDetail]) {
        try! realm.write {
            for detail in chatDetails {
                let sender = User(userId: detail.sender.userId, nick: detail.sender.nick)
                let message = ChatMessage(
                    chatId: detail.chatID,
                    roomId: detail.roomID,
                    content: detail.content,
                    createdAt: detail.createdAt.toISO8601Date()!,
                    sender: sender
                )
                realm.add(message, update: .modified)
            }
        }
    }
    
    // 특정 roomId의 모든 메시지를 가져오는 함수
    func fetchMessages(for roomId: String) -> [ChatMessage] {
        let results = realm.objects(ChatMessage.self)
            .filter("roomId == %@", roomId)
            .sorted(byKeyPath: "createdAt", ascending: true)
        
        return Array(results)
    }
}
