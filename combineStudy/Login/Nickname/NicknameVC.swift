//
//  NicknameViewController.swift
//  assignment
//
//  Created by 이지훈 on 4/12/24.
//
import UIKit

import SnapKit
import Then
import Combine

class NicknameViewController: UIViewController {

    private var viewModel: NicknameViewModel
    private var cancellables = Set<AnyCancellable>() // 구독을 저장할 Set -> 구독 취소되면 자동으로 메모리에서 해제

    init(viewModel: NicknameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nicknameLabel = UILabel().then {
        $0.text = "닉네임을 입력해주세요"
        $0.textColor = UIColor.black
        $0.font = UIFont(name: "Pretendard-Medium", size: 23)
    }
    
    let nicknameTextField = UITextField().then {
        $0.backgroundColor = UIColor(named: "gray84") ?? UIColor.lightGray
        $0.layer.cornerRadius = 3
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        $0.textColor = UIColor(named: "gray4") ?? UIColor.darkGray
        $0.attributedPlaceholder = NSAttributedString(string: "닉네임", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "gray2") ?? UIColor.gray])
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: $0.frame.height))
        $0.leftView = paddingView
        $0.leftViewMode = .always
        $0.isUserInteractionEnabled = true
    }
    
    let saveBtn = UIButton().then {
        $0.backgroundColor = UIColor(named: "red") ?? UIColor.red
        $0.setTitle("저장하기", for: .normal)
        $0.layer.cornerRadius = 3
        $0.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addSubViews()
        setConstraints()
        bindViewModel()
        setupActions()
    }

    //MARK: - Layout
    func addSubViews() {
        let views = [
            nicknameLabel,
            nicknameTextField,
            saveBtn
        ]
        views.forEach {
            view.addSubview($0) // 서브뷰 추가.
        }
    }
    
    func setConstraints() {
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
        
        saveBtn.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
    }
    
    private func bindViewModel() {
        viewModel.$nickname
            .receive(on: RunLoop.main) // 메인 스레드에서 구독.
            .assign(to: \.text, on: nicknameTextField) // nicknameTextField의 text 속성에 값 할당.
            .store(in: &cancellables) // 구독을 cancellables에 저장 -> cancellables가 메모리에서 해제될 때까지 구독이 유지되도록 "잡아두는" 역할
        
        viewModel.$isValid
            .receive(on: RunLoop.main) // 메인 스레드에서 구독.
            .sink { [weak self] isValid in
                self?.saveBtn.isEnabled = isValid // 저장 버튼 활성화 상태 업데이트.
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: RunLoop.main) // 메인 스레드에서 구독.
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    print("Error: \(errorMessage)") // 에러 메시지 출력.
                }
            }
            .store(in: &cancellables)
    }
    
    func setupActions() {
        saveBtn.addTarget(self, action: #selector(saveNickname), for: .touchUpInside)
        nicknameTextField.textPublisher
            .compactMap { $0 }
            .sink { [weak self] text in
                print("Text Changed: \(text)") // 텍스트 변경 로그 추가
                self?.viewModel.updateNickname(text) // ViewModel의 updateNickname 호출.
            }
            .store(in: &cancellables) // 구독을 cancellables에 저장.
    }
    
    @objc func saveNickname() {
        viewModel.saveNickname() // ViewModel의 saveNickname 호출.
        if viewModel.isValid {
            dismiss(animated: true) // 닉네임이 유효한 경우 모달 닫기.
        }
    }
}

extension UITextField {
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self) // 텍스트 필드의 텍스트 변경 이벤트 발행.
            .map { $0.object as? UITextField } // UITextField로 변환.
            .map { $0?.text } // 텍스트 필드의 텍스트를 추출.
            .eraseToAnyPublisher() // Publisher의 타입을 AnyPublisher로 변환.
    }
}
