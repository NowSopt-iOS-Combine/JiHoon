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
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private func bindViewModel() {
        viewModel.$nickname
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: nicknameTextField)
            .store(in: &cancellables)
        
        viewModel.$isValid
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                guard let self = self else { return }
                self.saveBtn.isEnabled = isValid
                self.saveBtn.backgroundColor = isValid ? (UIColor(named: "red") ?? UIColor.red) : (UIColor(named: "gray84") ?? UIColor.lightGray)
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    print("Error: \(errorMessage)")
                }
            }
            .store(in: &cancellables)
    }
    
    func addSubViews() {
        let views = [
            nicknameLabel,
            nicknameTextField,
            saveBtn
        ]
        views.forEach {
            view.addSubview($0)
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
    
    func setupActions() {
        saveBtn.addTarget(self, action: #selector(saveNickname), for: .touchUpInside)
        
        nicknameTextField.textPublisher
            .compactMap { $0 }
            .sink { [weak self] text in
                self?.viewModel.updateNickname(text)
            }
            .store(in: &cancellables)
    }
    
    @objc func saveNickname() {
        viewModel.saveNickname()
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
