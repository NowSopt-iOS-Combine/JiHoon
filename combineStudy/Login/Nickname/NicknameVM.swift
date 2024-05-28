//  NicknameVM.swift
//  assignment
//
//  Created by 이지훈 on 5/27/24.
//

import Foundation

protocol NicknameViewModelType {
    var nickname: ObservablePattern<String?> { get }
    var isValid: ObservablePattern<Bool> { get }
    var errorMessage: ObservablePattern<String?> { get }
    
    func updateNickname(_ nickname: String)
    func saveNickname(completion: (String?) -> Void)
}

final class NicknameViewModel: NicknameViewModelType {
    var nickname: ObservablePattern<String?> = ObservablePattern<String?>(nil)
    var isValid: ObservablePattern<Bool> = ObservablePattern<Bool>(false)
    var errorMessage: ObservablePattern<String?> = ObservablePattern<String?>(nil)
    
    private let validNicknameRegex = "^[가-힣]{1,10}$"
    
    func updateNickname(_ nickname: String) {
        self.nickname.value = nickname
        validateNickname(nickname)
    }
    
    func saveNickname(completion: (String?) -> Void) {
        guard let nickname = nickname.value, validateNickname(nickname) else {
            errorMessage.value = "닉네임을 한글 1~10자로 입력해주세요."
            completion(nil)
            return
        }
        errorMessage.value = nil
        completion(nickname)
    }
    
    @discardableResult
    private func validateNickname(_ nickname: String) -> Bool {
        let isValid = nickname.range(of: validNicknameRegex, options: .regularExpression) != nil
        self.isValid.value = isValid
        return isValid
    }
}

