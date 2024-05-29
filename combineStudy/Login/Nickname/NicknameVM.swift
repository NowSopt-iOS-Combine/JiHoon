//
//  NicknameViewModel.swift
//  assignment
//
//  Created by 이지훈 on 4/12/24.
//
import Foundation
import Combine

final class NicknameViewModel {
    @Published var nickname: String? = nil
    @Published var isValid: Bool = false
    @Published var errorMessage: String? = nil
    
    private let validNicknameRegex = "^[가-힣]{1,10}$"
    private var nicknameSubject = PassthroughSubject<String?, Never>()
    
    var nicknamePublisher: AnyPublisher<String?, Never> {
        return nicknameSubject.eraseToAnyPublisher()
    }

    func updateNickname(_ nickname: String) {
        self.nickname = nickname
        validateNickname(nickname)
    }
    
    func saveNickname() {
        if let nickname = nickname, validateNickname(nickname) {
            errorMessage = nil
            nicknameSubject.send(nickname)
        } else {
            errorMessage = "닉네임을 한글 1~10자로 입력해주세요."
            nicknameSubject.send(nil)
        }
    }
    
    @discardableResult
    private func validateNickname(_ nickname: String) -> Bool {
        let isValid = nickname.range(of: validNicknameRegex, options: .regularExpression) != nil
        self.isValid = isValid
        return isValid
    }
}
