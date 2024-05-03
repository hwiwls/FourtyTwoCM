//
//  ViewModelErrorProtocol.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/3/24.
//

import RxSwift

protocol ViewModelErrorProtocol {
    var tokenRefreshFailed: Observable<Void> { get }
}
