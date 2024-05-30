//
//  ViewController.swift
//  combineStudy
//
//  Created by 이지훈 on 5/3/24.
//\

import UIKit

import Combine
import SnapKit

class LoginViewController: UIViewController {

    var viewModel = LoginViewModel() // ViewModel 인스턴스 생성
    var cancellables = Set<AnyCancellable>() // 구독을 저장할 Set

    @Published var nickname: String? // ViewController에서 nickname 변화를 구독할 수 있도록 @Published 속성 사용

    // MARK: - Properties
    let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "TVING ID 로그인"
        label.textColor = UIColor(named: "gray84") ?? .gray
        label.font = UIFont(name: "Pretendard-Medium", size: 24)
        return label
    }()

    let idTextFieldView: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(named: "gray4") ?? .lightGray
        textField.layer.cornerRadius = 3
        textField.attributedPlaceholder = NSAttributedString(string: "아이디", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "gray2") ?? .darkGray])
        return textField
    }()

    let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(named: "gray4") ?? .lightGray
        textField.layer.cornerRadius = 3
        textField.attributedPlaceholder = NSAttributedString(string: "닉네임", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "gray2") ?? .darkGray])
        return textField
    }()

    let mirroredNicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Pretendard-SemiBold", size: 24)
        label.text = "" // 초기값 설정
        return label
    }()

    let saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.layer.borderColor = UIColor(named: "gray4")?.cgColor ?? UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.setTitle("저장하기", for: .normal)
        button.layer.cornerRadius = 3
        button.isEnabled = false
        return button
    }()

    let addNicknameButton: UIButton = {
        let button = UIButton()
        button.setTitle("닉네임 추가하기", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        return button
    }()

    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Pretendard-SemiBold", size: 14)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI() // UI 설정
        setupBindings() // UI 요소와 액션 바인딩
        layoutUI() // UI 레이아웃 설정
        bind() // ViewModel과 바인딩
    }

    private func configureUI() {
        view.backgroundColor = .black
    }

    private func setupBindings() {
        addNicknameButton.addTarget(self, action: #selector(presentModalView), for: .touchUpInside) // 닉네임 추가 버튼 클릭 시 액션 설정
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside) // 저장 버튼 클릭 시 액션 설정

        nicknameTextField.textPublisher
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // 500밀리초 동안 입력이 없을 때 반영
            .compactMap { $0 }
            .sink { [weak self] text in
                print("Debounced Text: \(text)") // 로그 추가
                self?.mirroredNicknameLabel.text = text // 미러 레이블에 텍스트 반영
            }
            .store(in: &cancellables) // 구독을 cancellables에 저장
    }

    private func layoutUI() {
        addSubviews(
            loginLabel,
            idTextFieldView,
            nicknameTextField,
            mirroredNicknameLabel,
            saveButton,
            addNicknameButton,
            nicknameLabel
        )
        setConstraints()
    }

    private func bind() {
        let input = LoginViewModel.Input(
            nickname: nicknameTextField.textPublisher
                .compactMap { $0 ?? "" } // 텍스트 필드의 텍스트 변화를 구독
                .eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input) // ViewModel의 transform 메소드 호출

        output.isButtonEnabled
            .receive(on: RunLoop.main) // 메인 스레드에서 구독
            .assign(to: \.isEnabled, on: saveButton) // 저장 버튼의 활성화 상태를 업데이트
            .store(in: &cancellables)

        output.buttonBackgroundColor
            .receive(on: RunLoop.main) // 메인 스레드에서 구독
            .sink { [weak self] color in
                self?.saveButton.backgroundColor = color // 저장 버튼의 배경색을 업데이트
            }
            .store(in: &cancellables)

        $nickname
            .receive(on: RunLoop.main) // 메인 스레드에서 구독
            .sink { [weak self] nickname in
                self?.nicknameLabel.text = nickname // 닉네임 레이블의 텍스트를 업데이트
            }
            .store(in: &cancellables)
    }

    @objc func handleSave() {
        viewModel.nickname = nicknameTextField.text ?? "" // ViewModel의 nickname 업데이트

        print("Current nickname: \(viewModel.nickname)")

        viewModel.saveNickname() // ViewModel의 saveNickname 호출

        let welcomeVC = WelcomeViewController()
        welcomeVC.id = viewModel.nickname // WelcomeViewController에 닉네임 전달
        welcomeVC.modalPresentationStyle = .fullScreen
        self.present(welcomeVC, animated: true, completion: nil) // WelcomeViewController 표시
    }

    @objc func presentModalView() {
        let nicknameViewModel = NicknameViewModel()
        let modalViewController = NicknameViewController(viewModel: nicknameViewModel)

        nicknameViewModel.nicknamePublisher
            .receive(on: RunLoop.main) // 메인 스레드에서 구독
            .sink { [weak self] nickname in
                self?.nickname = nickname // 닉네임 업데이트
                self?.nicknameLabel.text = nickname // 닉네임을 레이블에 반영
            }
            .store(in: &cancellables)

        modalViewController.modalPresentationStyle = .formSheet
        if let sheet = modalViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        self.present(modalViewController, animated: true, completion: nil)
    }

    private func addSubviews(_ views: UIView...) {
        views.forEach { view.addSubview($0) }
    }

    private func setConstraints() {
        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(90)
            make.centerX.equalTo(view)
        }

        idTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(335)
            make.height.equalTo(52)
        }

        mirroredNicknameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(idTextFieldView.snp.top).offset(-20)
            make.centerX.equalTo(view)
        }

        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(idTextFieldView.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(335)
            make.height.equalTo(52)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(21)
            make.centerX.equalTo(view)
            make.width.equalTo(335)
            make.height.equalTo(52)
        }

        addNicknameButton.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }

        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(addNicknameButton.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
    }
}
