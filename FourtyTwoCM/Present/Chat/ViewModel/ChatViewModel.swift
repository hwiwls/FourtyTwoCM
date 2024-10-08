//
//  ChatViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/12/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    let chatRepository = ChatRepository(userId: UserDefaults.standard.string(forKey: "userID") ?? "")
    
    let participantId: String
    let participantNick: String
    let messagesRelay = BehaviorRelay(value: [ChatMessage]())
    let errorRelay = PublishRelay<String>()

    init(participantId: String, participantNick: String) {
        self.participantId = participantId
        self.participantNick = participantNick
        
        NotificationCenter.default.rx.notification(.appDidBecomeActive)
            .subscribe(onNext: { [weak self] _ in
                self?.reconnectSocket()
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(.appDidEnterBackground)
            .subscribe(onNext: { [weak self] _ in
                self?.disconnectSocket()
            })
            .disposed(by: disposeBag)
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let messageSent: Observable<String>
    }
    
    struct Output {
        let messages: Driver<[ChatMessage]>
        let error: Driver<String>
        let messageSentSuccess: Signal<Void>
    }
    
    func transform(input: Input) -> Output {
        let messageSentSuccessRelay = PublishRelay<Void>()
        
        input.viewWillAppear
            .flatMapLatest { [weak self] _ -> Observable<[ChatMessage]> in
                guard let self = self else { return .just([]) }
                
                if let roomId = self.chatRepository.fetchChatRoomId(with: self.participantId) {
                    return self.updateAndFetchMessages(roomId: roomId)
                        .do(onSuccess: { _ in
                            self.configureSocket(with: roomId)
                        })
                        .asObservable()
                } else {
                    return NetworkManager.performRequest(route: .getChatRoomList, dataType: ChatRoomListModel.self)
                        .asObservable()
                        .map { $0.data }
                        .do(onNext: { chatRoomList in
                            chatRoomList.forEach { self.chatRepository.saveChatRoom($0) }
                        })
                        .flatMap { chatRoomList -> Single<[ChatMessage]> in
                            guard let chatRoom = chatRoomList.first(where: { $0.participants.contains(where: { $0.userID == self.participantId }) }) else {
                                return .just([])
                            }
                            return self.updateAndFetchMessages(roomId: chatRoom.roomID)
                                .do(onSuccess: { _ in
                                    self.configureSocket(with: chatRoom.roomID)
                                })
                        }
                        .asObservable()
                }
            }
            .subscribe(with: self) { owner, messages in
                owner.messagesRelay.accept(messages)
            } onError: { owner, error in
                owner.handleError(error)
            }
            .disposed(by: disposeBag)
        
        input.viewWillDisappear
            .subscribe(onNext: {
                SocketIOManager.shared.leaveConnection()
            })
            .disposed(by: disposeBag)
        
        input.messageSent
            .flatMapLatest { [weak self] message -> Observable<ChatDetail> in
                guard let self = self else { return .empty() }
                
                if self.chatRepository.isChatRoomExists(with: self.participantId) {
                    guard let roomId = self.chatRepository.fetchChatRoomId(with: self.participantId) else {
                        return .empty()
                    }
                    return self.sendMessage(roomId: roomId, content: message)
                        .asObservable()
                } else {
                    let query = CreateChatRoomQuery(opponentId: self.participantId)
                    return NetworkManager.performRequest(route: .createChatRoom(query: query), dataType: ChatRoomModel.self)
                        .flatMap { chatRoomModel in
                            self.chatRepository.saveChatRoom(chatRoomModel)
                            return self.sendMessage(roomId: chatRoomModel.roomID, content: message)
                        }
                        .asObservable()
                }
            }
            .subscribe(with: self) { owner, chatDetail in
                owner.chatRepository.saveMessages([chatDetail])
                owner.messagesRelay.accept(owner.chatRepository.fetchMessages(for: chatDetail.roomID))
                messageSentSuccessRelay.accept(())
            } onError: { owner, error in
                owner.handleError(error)
            }
            .disposed(by: disposeBag)
        
        return Output(
            messages: messagesRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다."),
            messageSentSuccess: messageSentSuccessRelay.asSignal()
        )
    }
    
    private func configureSocket(with roomId: String) {
        SocketIOManager.shared.configureSocket(with: roomId)
        SocketIOManager.shared.establishConnection()
        
        SocketIOManager.shared.receiveChatData
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let chatDetail):
                    self?.chatRepository.saveMessages([chatDetail])
                    self?.messagesRelay.accept(self?.chatRepository.fetchMessages(for: chatDetail.roomID) ?? [])
                case .failure(let error):
                    self?.errorRelay.accept(error.errorMessage)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateAndFetchMessages(roomId: String) -> Single<[ChatMessage]> {
        let lastMessageDate = chatRepository.fetchLastMessageTimestamp(for: roomId)
        let cursorDate = lastMessageDate?.toISO8601String()
        let query = ChatHistoryQuery(cursor_date: cursorDate)
        
        return NetworkManager.performRequest(route: .getChatHistory(roomId: roomId, query: query), dataType: ChatMessageModel.self)
            .map { $0.data }
            .do(onSuccess: { chatDetails in
                self.chatRepository.saveMessages(chatDetails)
            })
            .flatMap { _ in
                Single.just(self.chatRepository.fetchMessages(for: roomId))
            }
    }
    
    private func sendMessage(roomId: String, content: String) -> Single<ChatDetail> {
        let query = MessageToSendQuery(content: content)
        
        return NetworkManager.performRequest(route: .sendMessage(roomId: roomId, query: query), dataType: ChatDetail.self)
            .do(onSuccess: { chatDetail in
                self.chatRepository.saveMessages([chatDetail])
            })
    }
    
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            errorRelay.accept(apiError.errorMessage)
        } else {
            errorRelay.accept("알 수 없는 오류가 발생했습니다.")
        }
    }

    private func reconnectSocket() {
        if let roomId = self.chatRepository.fetchChatRoomId(with: self.participantId) {
            updateAndFetchMessages(roomId: roomId)
                .subscribe(onSuccess: { [weak self] messages in
                    self?.messagesRelay.accept(messages)
                    self?.configureSocket(with: roomId)
                }, onFailure: { [weak self] error in
                    self?.handleError(error)
                })
                .disposed(by: disposeBag)
        }
    }

    private func disconnectSocket() {
        SocketIOManager.shared.leaveConnection()
    }
}
