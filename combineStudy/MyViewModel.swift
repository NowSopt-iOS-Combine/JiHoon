//
//  MyViewModel.swift
//  combineStudy
//
//  Created by 이지훈 on 5/3/24.
//
//
//import Foundation
//import Combine
//
//class MyViewModel {
//    
//    // published 통해 구독 설정
//    @Published var passwordInput : String = "" {
//        didSet {
//            print("MyViewModel / passwordInput: \(passwordInput)")
//        }
//    }
//    @Published var passwordConfirmInput : String = "" {
//        didSet {
//            print("MyViewModel / passwordConfirmInput: \(passwordConfirmInput)")
//        }
//    }
//    var cancellables = Set<AnyCancellable>()  // private를 제거하거나 private(set)을 사용
//
//    // 들어온 퍼블리셔들의 값 일치 여부를 반환 하는 퍼블리셔
//    lazy var isMatchPasswordInput : AnyPublisher<Bool, Never> = Publishers
//        .CombineLatest($passwordInput, $passwordConfirmInput)
//        .map({ (password: String, passwordConfirm: String) in
//            if password == "" || passwordConfirm == "" {
//                return false
//            }
//            if password == passwordConfirm {
//                return true
//            } else {
//                return false
//            }
//        })
//        .print()
//        .eraseToAnyPublisher()
//        
//    
//    
//}
