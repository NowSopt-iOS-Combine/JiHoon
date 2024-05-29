//
//  LoginVM.swift
//  combineStudy
//
//  Created by 이지훈 on 5/9/24.

import UIKit

import Combine

class LoginViewModel {
    var cancellables = Set<AnyCancellable>()

    @Published var nickname: String = ""
    @Published var isSaveButtonEnabled: Bool = false
    @Published var saveButtonBackgroundColor: UIColor = .clear

    init() {
        setupBindings()
    }

    struct Input {
        var nickname: AnyPublisher<String, Never>
    }

    struct Output {
        var isButtonEnabled: AnyPublisher<Bool, Never>
        var buttonBackgroundColor: AnyPublisher<UIColor, Never>
    }

    func transform(input: Input) -> Output {
        let isButtonEnabled = input.nickname
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()

        let buttonBackgroundColor = isButtonEnabled
            .map { $0 ? UIColor.red : UIColor.clear }
            .eraseToAnyPublisher()

        return Output(isButtonEnabled: isButtonEnabled, buttonBackgroundColor: buttonBackgroundColor)
    }

    private func setupBindings() {
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
        self.nickname = nickname
    }
}

