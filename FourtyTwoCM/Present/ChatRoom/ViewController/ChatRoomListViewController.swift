//
//  ChattingViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Toast

class ChatRoomListViewController: BaseViewController {
    
    private lazy var chatRoomListTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(GenericTableViewCell.self, forCellReuseIdentifier: "GenericTableViewCell")
    }
    
    private let refreshControl = UIRefreshControl()
    private let viewModel = ChatRoomListViewModel()
    private let viewDidLoadTrigger = PublishSubject<Void>()
    private let refreshTrigger = PublishSubject<Void>()
    
//    private var chatRooms: [ChatRoomModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadTrigger.onNext(())
    }
    
    override func bind() {
        let input = ChatRoomListViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            refreshTrigger: refreshTrigger.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        Observable.merge(output.initialLoad.asObservable(), output.refreshLoad.asObservable())
            .asDriver(onErrorJustReturn: [])
            .drive(chatRoomListTableView.rx.items(cellIdentifier: "GenericTableViewCell", cellType: GenericTableViewCell.self)) { row, model, cell in
                cell.configure(with: model.participants, lastChat: model.lastChat, updatedAt: model.updatedAt)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage
            .drive(onNext: { [weak self] errorMessage in
                self?.view.makeToast(errorMessage, duration: 3.0, position: .center)
            })
            .disposed(by: disposeBag)
        
        output.isRefreshing
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        chatRoomListTableView.refreshControl = refreshControl
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: refreshTrigger)
            .disposed(by: disposeBag)
    }
    
    override func configHierarchy() {
        view.addSubview(chatRoomListTableView)
    }
    
    override func configLayout() {
        chatRoomListTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
