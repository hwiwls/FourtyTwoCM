//
//  UICollectionView+ReachedBottom.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/14/24.
//

import UIKit
import RxSwift

extension Reactive where Base: UIScrollView {
    var reachedBottom: Observable<Void> {
        return contentOffset
            .map { contentOffset in
                let scrollViewHeight = self.base.frame.size.height
                let scrollContentSizeHeight = self.base.contentSize.height
                let scrollOffset = contentOffset.y
                let bottomEdge = scrollOffset + scrollViewHeight
                return bottomEdge >= scrollContentSizeHeight - 50
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in Void() }
    }
}
