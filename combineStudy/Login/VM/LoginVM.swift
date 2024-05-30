//
//  LoginVM.swift
//  combineStudy
//
//  Created by 이지훈 on 5/9/24.


import UIKit
import Combine

class LoginViewModel {
    var cancellables = Set<AnyCancellable>() // 구독을 저장할 Set.

    @Published var nickname: String = ""
    @Published var isSaveButtonEnabled: Bool = false
    @Published var saveButtonBackgroundColor: UIColor = .clear

    init() {
        setupBindings() // ViewModel 초기화 기본 바인딩 설정.
    }

    struct Input {
        var nickname: AnyPublisher<String, Never> // View로부터 nickname 입력을 받는 Publisher.
    }

    struct Output {
        var isButtonEnabled: AnyPublisher<Bool, Never> // 저장 버튼의 활성화 상태를 전달하는 Publisher.
        var buttonBackgroundColor: AnyPublisher<UIColor, Never> // 저장 버튼의 배경색을 전달하는 Publisher.
    }

    func transform(input: Input) -> Output {
        // input.nickname을 구독하여 저장 버튼의 활성화 상태를 결정.
        let isButtonEnabled = input.nickname
            .map { !$0.isEmpty } // nickname이 비어있지 않으면 true 반환.
            .eraseToAnyPublisher() // Publisher의 타입을 AnyPublisher로 변환.

        // isButtonEnabled를 구독하여 저장 버튼의 배경색을 결정.
        let buttonBackgroundColor = isButtonEnabled
            .map { $0 ? UIColor.red : UIColor.clear } // 활성화 상태에 따라 색상 변경.
            .eraseToAnyPublisher() // Publisher의 타입을 AnyPublisher로 변환.

        return Output(isButtonEnabled: isButtonEnabled, buttonBackgroundColor: buttonBackgroundColor)
    }

    private func setupBindings() {
        // nickname의 변경을 구독하여 isSaveButtonEnabled의 값을 설정.
        $nickname
            .map { !$0.isEmpty }
            .assign(to: \.isSaveButtonEnabled, on: self)
            .store(in: &cancellables)
    }

    func saveNickname() {
        print("Nickname saved: \(nickname)")
    }

    func clearFields() {
        nickname = ""
    }

    func updateNickname(_ nickname: String) {
        self.nickname = nickname // 닉네임 업데이트.
    }
}
