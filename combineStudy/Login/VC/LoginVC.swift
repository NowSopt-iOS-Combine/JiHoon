//
//  ViewController.swift
//  combineStudy
//
//  Created by 이지훈 on 5/3/24.
//
import UIKit
import SnapKit
import Combine
import CombineCocoa

class LoginViewController: UIViewController, UITextFieldDelegate, WelcomeViewControllerDelegate {
    
    var viewModel = LoginViewModel()
    var cancellables = Set<AnyCancellable>()
    
    func didLoginWithId(id: String) {
        print(1)
    }
    
    // MARK: - Properties
    @Published var nickname: String?  // 클로저로 받을 닉네임
    
    let loginLabel = UILabel().then {
        $0.text = "TVING ID 로그인"
        $0.textColor = UIColor(named: "gray84")
        $0.font = UIFont(name: "Pretendard-Medium", size: 24)
    }
    
    let idTextFieldView = UITextField().then {
        $0.backgroundColor = UIColor(named: "gray4")
        $0.layer.cornerRadius = 3
        $0.attributedPlaceholder = NSAttributedString(string: "아이디", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "gray2")])
    }
    
    let passwordTextFieldView = UITextField().then {
        $0.backgroundColor = UIColor(named: "gray4")
        $0.layer.cornerRadius = 3
        $0.attributedPlaceholder = NSAttributedString(string: "비밀번호", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "gray2")])
        $0.isSecureTextEntry = true
    }
    
    let loginButton = UIButton().then {
        $0.backgroundColor = UIColor.clear
        $0.layer.borderColor = UIColor(named: "gray4")?.cgColor
        $0.layer.borderWidth = 1
        $0.setTitle("로그인하기", for: .normal)
        $0.layer.cornerRadius = 3
        $0.isEnabled = false
    }
    
    let findId = UILabel().then {
        $0.text = "아이디 찾기"
        $0.textColor = UIColor(named: "gray2")
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 14)
    }
    
    let findPw = UILabel().then {
        $0.text = "비밀번호 찾기"
        $0.textColor = UIColor(named: "gray2")
    }
    
    let noAccount = UILabel().then {
        $0.text = "아직계정이 없으신가요?"
        $0.textColor = UIColor(named: "gray3")
    }
    
    let makeAccount = UIButton().then {
        let title = "닉네임 만들러 가기"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "gray2")!,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        $0.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    let spaceView = UIView().then {
        $0.backgroundColor = UIColor(named: "gray2")
    }
    
    let eyeButton = UIButton(type: .custom)
    let xCircleButton = UIButton(type: .custom)
    
    let nicknameLabel = UILabel().then {
        $0.textColor = UIColor(named: "gray2")
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.textAlignment = .center
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
        layoutUI()
        bind()
    }

    private func configureUI() {
        view.backgroundColor = .black
        idTextFieldView.delegate = self
        passwordTextFieldView.delegate = self

        eyeButton.setImage(UIImage(named: "eyeIcon"), for: .normal)
        xCircleButton.setImage(UIImage(named: "xCircle"), for: .normal)
    }

    private func setupBindings() {
        idTextFieldView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextFieldView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        eyeButton.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        xCircleButton.addTarget(self, action: #selector(handleXCircleButtonTap), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        makeAccount.addTarget(self, action: #selector(presentModalView), for: .touchUpInside)
    }

    private func layoutUI() {
        addSubViews()
        setConstraints()

        eyeButton.snp.makeConstraints { make in
            make.trailing.equalTo(passwordTextFieldView.snp.trailing).offset(-20)
            make.centerY.equalTo(passwordTextFieldView)
            make.width.height.equalTo(24)
        }
        xCircleButton.snp.makeConstraints { make in
            make.trailing.equalTo(eyeButton.snp.leading).offset(-20)
            make.centerY.equalTo(passwordTextFieldView)
            make.width.height.equalTo(24)
        }
    }

    // MARK: - DataBind
    private func bind() {
        let input = LoginViewModel.Input(
            username: idTextFieldView.textPublisher
                .compactMap { $0 ?? "" }
                .eraseToAnyPublisher(),
            password: passwordTextFieldView.textPublisher
                .compactMap { $0 ?? "" }
                .eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input, cancelBag: &cancellables)

        output.isButtonEnabled
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)

        output.buttonBackgroundColor
            .receive(on: RunLoop.main)
            .sink { [weak self] color in
                self?.loginButton.backgroundColor = color
            }
            .store(in: &cancellables)
        
        $nickname
            .receive(on: RunLoop.main)
            .sink { [weak self] nickname in
                self?.nicknameLabel.text = nickname
            }
            .store(in: &cancellables)
    }

    @objc func handleLogin() {
        viewModel.username = idTextFieldView.text ?? ""
        viewModel.password = passwordTextFieldView.text ?? ""
        
        print("Current username: \(viewModel.username)")
        print("Current password: \(viewModel.password)")
        
        viewModel.login()
        
        // 로그인 성공 후 WelcomeViewController를 모달로 표시
        let welcomeVC = WelcomeViewController()
        welcomeVC.id = viewModel.username  // id로 username을 전달
        welcomeVC.modalPresentationStyle = .fullScreen
        self.present(welcomeVC, animated: true, completion: nil)
    }

    @objc func handleXCircleButtonTap() {
        viewModel.clearFields()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == idTextFieldView {
            viewModel.updateUsername(textField.text ?? "")
        } else if textField == passwordTextFieldView {
            viewModel.updatePassword(textField.text ?? "")
        }
    }
    
    // MARK: - AddSubview
    func addSubViews() {
        let views = [
            loginLabel,
            idTextFieldView,
            passwordTextFieldView,
            loginButton,
            findId,
            findPw,
            noAccount,
            makeAccount,
            spaceView,
            eyeButton,
            xCircleButton,
            nicknameLabel
        ]
        views.forEach {
            view.addSubview($0)
        }
    }
    
    // MARK: - layout
    func setConstraints() {
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
        
        passwordTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(idTextFieldView.snp.bottom).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(335)
            make.height.equalTo(52)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextFieldView.snp.bottom).offset(21)
            make.centerX.equalTo(view)
            make.width.equalTo(335)
            make.height.equalTo(52)
        }
        
        findId.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(31)
            make.leading.equalTo(view).offset(85)
        }
        
        spaceView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(loginButton.snp.bottom).offset(31)
            make.width.equalTo(2)
            make.height.equalTo(14)
        }
        
        findPw.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(31)
            make.trailing.equalTo(view).offset(-86)
        }
        
        noAccount.snp.makeConstraints { make in
            make.top.equalTo(findId.snp.bottom).offset(12)
            make.leading.equalTo(view.snp.leading).offset(51)
        }
        
        makeAccount.snp.makeConstraints { make in
            make.top.equalTo(findPw.snp.bottom).offset(12)
            make.trailing.equalTo(view.snp.trailing).offset(-43)
        }
        
        // PlaceHolder 왼쪽공간 띄우기
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 10))
        idTextFieldView.leftViewMode = .always
        idTextFieldView.leftView = spacerView
        
        let spacerViewForPassword = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 10))
        passwordTextFieldView.leftViewMode = .always
        passwordTextFieldView.leftView = spacerViewForPassword
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(makeAccount.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
    }
    
    // TF 포커스 호출
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 테두리 색상 변경
        textField.layer.borderColor = CGColor(gray: 1, alpha: 1)
        textField.layer.borderWidth = 1.0
    }
    
    // TF 포커스 해제
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0.0
    }
    
    // 비밀번호 보안처리
    @objc func togglePasswordView() {
        passwordTextFieldView.isSecureTextEntry.toggle()
    }
    
    // 닉네임 만들기
    @objc func presentModalView() {
        let modalViewController = NicknameViewController()
        modalViewController.onSaveNickname = { [weak self] nickname in
            self?.nickname = nickname  // 닉네임 저장
            print("닉네임 저장됨: \(nickname)")
        }
        modalViewController.modalPresentationStyle = .formSheet
        if let sheet = modalViewController.sheetPresentationController {
            let smallDetent = UISheetPresentationController.Detent.custom { context in
                return 200
            }
            sheet.detents = [smallDetent]
            sheet.prefersGrabberVisible = true
        }
        self.present(modalViewController, animated: true, completion: nil)
    }
}

extension UITextField {
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { $0.object as? UITextField }
            .map { $0?.text }
            .eraseToAnyPublisher()
    }
}
