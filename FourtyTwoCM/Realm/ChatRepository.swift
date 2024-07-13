//
//  ChatRepository.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/11/24.
//

import Foundation
import RealmSwift

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

    // 특정 roomId의 모든 ChatMessage의 내용 조회
    func fetchMessageUsingRoomId(for roomId: String) -> [String] {
        return realm.objects(ChatMessage.self)
            .filter("roomId == %@", roomId)
            .sorted(byKeyPath: "createdAt", ascending: true)
            .map { $0.content }
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
    
    // 특정 유저와의 모든 ChatMessage 조회 함수
    func fetchMessagesUsingUserId(for userId: String) -> [ChatMessage] {
        let results = realm.objects(ChatMessage.self)
            .filter("sender.userId == %@", userId)
            .sorted(byKeyPath: "createdAt", ascending: true)
        
        return Array(results)
    }
}
