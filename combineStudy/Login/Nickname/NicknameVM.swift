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
    private var nicknameSubject = PassthroughSubject<String?, Never>() // 닉네임을 발행할 Subject.
    
    var nicknamePublisher: AnyPublisher<String?, Never> {
        return nicknameSubject.eraseToAnyPublisher() // nicknameSubject를 AnyPublisher로 변환하여 외부에 제공.
    }

    func updateNickname(_ nickname: String) {
        self.nickname = nickname // 닉네임 업데이트.
    }
    
    func saveNickname() {
        if let nickname = nickname, validateNickname(nickname) {
            errorMessage = nil // 에러 메시지 초기화.
            nicknameSubject.send(nickname) // 닉네임 발행.
        } else {
            errorMessage = "닉네임을 한글 1~10자로 입력해주세요." // 에러 메시지 설정.
            nicknameSubject.send(nil) // nil 발행.
        }
    }
    
    private func validateNickname(_ nickname: String) -> Bool {
        let isValid = nickname.range(of: validNicknameRegex, options: .regularExpression) != nil // 닉네임 유효성 검사.
        self.isValid = isValid // 유효성 상태 업데이트.
        return isValid // 유효성 결과 반환.
    }
}
