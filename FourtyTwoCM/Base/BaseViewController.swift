//
//  BaseViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundBlack
        bind()
        configView()
        configHierarchy()
        configLayout()
        configNav()
    }
    
    
    func bind() {
        
    }
    
    func configView() {
        
    }
    
    func configHierarchy() {
        
    }
    
    func configLayout() {
        
    }
    
    func configNav() {
        
    }
    
    // 코드베이스에서 자주 사용하는 패턴.
    // '*, unavailable'은 모든 플랫폼과 버전에서 해당 기능이 사용할 수 없음. 즉, 이 초기화 방법은 사용할 수 없도록 의도적으로 비활성화
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


    
        

