//
//  NicknameViewController.swift
//  assignment
//
//  Created by 이지훈 on 4/12/24.
//

import UIKit
import SnapKit
import Then

class NicknameViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var onSaveNickname: ((String) -> Void)?
    private var viewModel: NicknameViewModelType = NicknameViewModel()
    
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
        nicknameTextField.delegate = self
        
        addSubViews()
        setConstraints()
        bindViewModel()
        setupActions()
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        viewModel.nickname.bind { [weak self] nickname in
            self?.nicknameTextField.text = nickname
        }
        
        viewModel.isValid.bind { [weak self] isValid in
            guard let self = self else { return }
            self.saveBtn.isEnabled = isValid
            self.saveBtn.backgroundColor = isValid ? (UIColor(named: "red") ?? UIColor.red) : (UIColor(named: "gray84") ?? UIColor.lightGray)
        }
        
        viewModel.errorMessage.bind { errorMessage in
            if let errorMessage = errorMessage {
                print("Error: \(errorMessage)")
            }
        }
    }
    
    // MARK: - AddSubViews
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
    
    // MARK: - Layouts
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
    
    // MARK: - Setup Actions
    func setupActions() {
        saveBtn.addTarget(self, action: #selector(saveNickname), for: .touchUpInside)
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Text Field Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if string.isEmpty { return true }
        return prospectiveText.count <= 10
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            viewModel.updateNickname(text)
        }
    }
    
    @objc func saveNickname() {
        viewModel.saveNickname { [weak self] nickname in
            guard let nickname = nickname else {
                return
            }
            self?.onSaveNickname?(nickname)
        }
    }
}

