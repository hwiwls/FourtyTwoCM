//
//  ViewModelType.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import Foundation
import RxSwift

protocol ViewModelType {
    // associatedtype: input, output 구조가 다 다르기 때문에 제네릭 사용
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }  // 연산 프로퍼티에서는 let을 사용 못한다.
    
    func transform(input: Input) -> Output
    
}
