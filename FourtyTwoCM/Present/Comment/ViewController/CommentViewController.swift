//
//  CommentViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/11/24.
//

import UIKit
import RxSwift
import RxCocoa

final class CommentViewController: BaseViewController {
    
    private let viewModel = CommentViewModel()
    
    var comments = BehaviorSubject<[Comment]>(value: [])
    
    private var fullScreenMode = false
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
        $0.imageView?.contentMode = .scaleAspectFit
    }
 
    private lazy var commentTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.register(CommentTableViewCell.self, forCellReuseIdentifier: "CommentTableViewCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .superDarkGray
    }
    
    override func bind() {
        let input = CommentViewModel.Input(
            closeTrigger: closeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.dismiss
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        comments.asObservable()
            .map { $0.reversed() }
            .bind(to: commentTableView.rx.items(cellIdentifier: "CommentTableViewCell", cellType: CommentTableViewCell.self)) { _, comment, cell in
                cell.configure(with: comment)
            }
            .disposed(by: disposeBag)
    }
    
    override func configHierarchy() {
        view.addSubviews([
            closeButton,
            commentTableView
        ])
    }
    
    override func configLayout() {
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-10)
            $0.width.height.equalTo(30)
        }
        
        commentTableView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(20)
            $0.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
   
    
}
