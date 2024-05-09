//
//  WelcomeVC.swift
//  combineStudy
//
//  Created by 이지훈 on 5/8/24.
//

import UIKit
import Then
import SnapKit

protocol WelcomeViewControllerDelegate: AnyObject {
    func didLoginWithId(id: String)
}

class WelcomeViewController: UIViewController {
    
    weak var delegate: WelcomeViewControllerDelegate?
    //delegate에서 받은값
    var id: String = ""
    //closure에서 받은값
    var nickname: String?
    
    let imageView = UIImageView().then {
        $0.image = UIImage(named: "tving")
        $0.contentMode = .scaleToFill
    }
    
    let welcomeLabel = UILabel().then {
        $0.textColor = UIColor(named: "gray84")
        $0.font = UIFont(name: "Pretendard-Bold", size: 23)
        $0.textAlignment = .center
        $0.numberOfLines = 2
        
    }
    
    let backButton = UIButton().then {
        $0.setTitle("메인으로", for: .normal)
        $0.backgroundColor = UIColor(named: "red")
        $0.layer.cornerRadius = 3
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
       // presentNicknameViewController()
        configureLabel()
        backButton.addTarget(self, action: #selector(backToMain), for: .touchUpInside)
        addSubViews()
        Layouts()
        
        print(id)
        print(nickname)
    }
    
    func configureLabel() {
        if let nickname = nickname {
            welcomeLabel.text = "\(nickname)님\n 반가워요!"
            print(nickname)
        } else {
            welcomeLabel.text = "\(id)님\n 반가워요!"
        }
    }

    
    func addSubViews() {
        let views = [imageView, welcomeLabel, backButton]
        views.forEach { view.addSubview($0) }
    }
    
    func Layouts() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(58)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        welcomeLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(67)
            $0.leading.trailing.equalTo(view).inset(20)
        }
        
        backButton.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom).offset(-66)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.height.equalTo(52)
        }
    }
    
    @objc func backToMain() {
        self.dismiss(animated: true, completion: nil)
    }

    
}
//
//#Preview {
//    WelcomeViewController()
//}
