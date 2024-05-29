//
//  LoginVM.swift
//  combineStudy
//
//  Created by 이지훈 on 5/9/24.

import UIKit
import Combine

class LoginViewModel {
    var cancellables = Set<AnyCancellable>()

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoginButtonEnabled: Bool = false
    @Published var loginButtonBackgroundColor: UIColor = .clear

    init() {
        setupBindings()
    }

    struct Input {
        var username: AnyPublisher<String, Never>
        var password: AnyPublisher<String, Never>
    }

    struct Output {
        var isButtonEnabled: AnyPublisher<Bool, Never>
        var buttonBackgroundColor: AnyPublisher<UIColor, Never>
    }

    func transform(input: Input, cancelBag: inout Set<AnyCancellable>) -> Output {
        let isButtonEnabled = Publishers.CombineLatest(input.username, input.password)
            .map { !$0.isEmpty && !$1.isEmpty }
            .eraseToAnyPublisher()

        let buttonBackgroundColor = isButtonEnabled
            .map { $0 ? UIColor.red : UIColor.clear }
            .eraseToAnyPublisher()

        return Output(isButtonEnabled: isButtonEnabled, buttonBackgroundColor: buttonBackgroundColor)
    }

    private func setupBindings() {
        Publishers.CombineLatest($username, $password)
            .map { !$0.isEmpty && !$1.isEmpty }
            .assign(to: \.isLoginButtonEnabled, on: self)
            .store(in: &cancellables)
    }

    func login() {
        print("Login attempted with username: \(username) and password: \(password)")
    }

    func clearFields() {
        username = ""
        password = ""
    }

    func updateUsername(_ username: String) {
        self.username = username
    }

    func updatePassword(_ password: String) {
        self.password = password
    }
}

