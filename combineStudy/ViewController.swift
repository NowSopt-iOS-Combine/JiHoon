//
//  ViewController.swift
//  combineStudy
//
//  Created by 이지훈 on 5/3/24.
//

import UIKit
import Combine

class ViewController: UIViewController {

    private var passwordTextField: UITextField!
    private var passwordConfirmTextField: UITextField!
    private var myBtn: UIButton!
    
    var viewModel : MyViewModel!
    
    //구독관리
    private var mySubscriptions = Set<AnyCancellable>()

    override func loadView() {
           super.loadView()
           
           // UI 요소 생성 및 설정
           view.backgroundColor = .white
           
           passwordTextField = UITextField()
           passwordTextField.borderStyle = .roundedRect
           passwordTextField.placeholder = "Enter your password"
           
           passwordConfirmTextField = UITextField()
           passwordConfirmTextField.borderStyle = .roundedRect
           passwordConfirmTextField.placeholder = "Confirm your password"
           
           myBtn = UIButton(type: .system)
           myBtn.setTitle("Submit", for: .normal)
           myBtn.backgroundColor = .lightGray
           myBtn.setTitleColor(.white, for: .disabled)
           myBtn.setTitleColor(.blue, for: .normal)
           
           // UI 요소를 뷰에 추가
           view.addSubview(passwordTextField)
           view.addSubview(passwordConfirmTextField)
           view.addSubview(myBtn)
           
           // Auto Layout 설정
           setConstraints()
       }
    
    
    private func setConstraints() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordConfirmTextField.translatesAutoresizingMaskIntoConstraints = false
        myBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordConfirmTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            passwordConfirmTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordConfirmTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            myBtn.topAnchor.constraint(equalTo: passwordConfirmTextField.bottomAnchor, constant: 20),
            myBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            myBtn.widthAnchor.constraint(equalToConstant: 100),
            myBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewModel = MyViewModel()
        
        
    }

    private func bindViewModel() {
        passwordTextField
            .myTextPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.passwordInput, on: viewModel)
            .store(in: &mySubscriptions)
        
        passwordConfirmTextField
            .myTextPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.passwordConfirmInput, on: viewModel)
            .store(in: &mySubscriptions)
        
        viewModel.isMatchPasswordInput
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: myBtn)
            .store(in: &mySubscriptions)
    }

}

extension UITextField {
    
    // UITextField의 텍스트 변경을 감지하는 퍼블리셔
    var myTextPublisher : AnyPublisher<String, Never> {
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap{ $0.object as? UITextField }
            // String 가져옴
            .map{ $0.text ?? "" }
            .print()
            .eraseToAnyPublisher()
        
    }
}

extension UIButton {
    var isValid: Bool {
        get {
            backgroundColor == .yellow
        }
        set {
            backgroundColor = newValue ? .yellow : .lightGray
            isEnabled = newValue
            setTitleColor(newValue ? .blue : .white, for: .normal)
        }
    }
}
