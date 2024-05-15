//
//  LikesViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import UIKit
import RxSwift
import RxCocoa

class MyLikesViewController: BaseViewController {
    var viewModel = MyLikesViewModel()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        let loadNextPageTrigger = collectionView.rx.reachedBottom.asObservable()

        let input = MyLikesViewModel.Input(trigger: Observable.just(()), loadNextPage: loadNextPageTrigger)
        let output = viewModel.transform(input: input)

        output.posts
            .drive(collectionView.rx.items(cellIdentifier: "PostCollectionViewCell", cellType: PostCollectionViewCell.self)) { row, post, cell in
                cell.configure(with: post)
            }
            .disposed(by: disposeBag)


        output.isLoading
            .drive(onNext: { isLoading in
                print(isLoading ? "Loading more items..." : "Finished loading.")
            })
            .disposed(by: disposeBag)
    }
    
    override func configView() {
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "PostCollectionViewCell")
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
    }
    
    override func configHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configLayout() {
        collectionView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(60)
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let totalSpacing: CGFloat = 40
        let numberOfItemsPerRow: CGFloat = 2
        let spacingBetweenCells: CGFloat = 12

        let itemWidth = (view.bounds.width - totalSpacing - (numberOfItemsPerRow - 1) * spacingBetweenCells) / numberOfItemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: 260)

        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = spacingBetweenCells
        
        let sideInset = (view.bounds.width - (numberOfItemsPerRow * itemWidth + (numberOfItemsPerRow - 1) * spacingBetweenCells)) / 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)

        return layout
    }

    
}
