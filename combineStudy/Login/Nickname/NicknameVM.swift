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
    private var cancellables = Set<AnyCancellable>() // 구독을 저장할 Set
    
    var nicknamePublisher: AnyPublisher<String?, Never> {
        return nicknameSubject.eraseToAnyPublisher() // nicknameSubject를 AnyPublisher로 변환하여 외부에 제공.
    }

    init() {
        setupBindings()
    }

    private func setupBindings() {
        $nickname
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // 디바운스 적용
            .sink { [weak self] nickname in
                print("Debounced Nickname: \(String(describing: nickname))") // 디바운스된 닉네임 출력
                self?.validateNickname(nickname ?? "")
            }
            .store(in: &cancellables)
    }

    func updateNickname(_ nickname: String) {
        self.nickname = nickname
    }
    
    func saveNickname() {
        if let nickname = nickname, validateNickname(nickname) {
            errorMessage = nil
            nicknameSubject.send(nickname)
        } else {
            errorMessage = "한글 1~10자로 입력해주세요."
            nicknameSubject.send(nil)
        }
    }
    
    private func validateNickname(_ nickname: String) -> Bool {
        let isValid = nickname.range(of: validNicknameRegex, options: .regularExpression) != nil
        self.isValid = isValid
        return isValid
    }
}
