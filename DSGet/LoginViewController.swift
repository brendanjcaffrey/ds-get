import UIKit
import SnapKit

class LoginViewController: UIViewController {
    private let mainView = UIView()
    private let titleView = UILabel()
    private let inputWrapper = UIView()
    private let hostWrapper = UIView()
    private let hostInput = UITextField()
    private let userWrapper = UIView()
    private let userInput = UITextField()
    private let passwordWrapper = UIView()
    private let passwordInput = UITextField()
    private let loginButton = UIButton(type: .system)

    static let background = UIColor(red: 251.0 / 255.0, green: 139.0 / 255.0, blue: 7.0 / 255.0, alpha: 1.0)
    static let buttonNormal = UIColor(red: 252.0 / 255.0, green: 198.0 / 255.0, blue: 130.0 / 255.0, alpha: 1.0)
    static let buttonHighlighted = UIColor(red: 252.0 / 255.0, green: 175.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
    static let border = UIColor(red: 225.0 / 255.0, green: 225.0 / 255.0, blue: 225.0 / 255.0, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"

        view.backgroundColor = LoginViewController.background
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))

        mainView.backgroundColor = LoginViewController.background
        view.addSubview(mainView)

        titleView.text = "DS get"
        titleView.textColor = UIColor.white
        titleView.font = UIFont.systemFont(ofSize: 45)
        mainView.addSubview(titleView)

        inputWrapper.backgroundColor = UIColor.white
        mainView.addSubview(inputWrapper)

        setupInput(wrapper: hostWrapper, field: hostInput, placeholder: "Host", parent: titleView, password: false, offset: 30)
        setupInput(wrapper: userWrapper, field: userInput, placeholder: "User", parent: hostWrapper, password: false)
        setupInput(wrapper: passwordWrapper, field: passwordInput, placeholder: "Password", parent: userWrapper, password: true)

        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        loginButton.setBackgroundImage(backgroundImage(color: LoginViewController.buttonNormal), for: .normal)
        loginButton.setBackgroundImage(backgroundImage(color: LoginViewController.buttonHighlighted), for: .highlighted)
        loginButton.setTitleColor(UIColor.black, for: .normal)
        loginButton.setTitleColor(UIColor.black, for: .highlighted)
        loginButton.layer.cornerRadius = 20
        loginButton.clipsToBounds = true
        mainView.addSubview(loginButton)

        mainView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view)
        }

        titleView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(mainView).multipliedBy(0.30)
            make.centerX.equalTo(mainView)
        }

        inputWrapper.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(hostWrapper)
            make.bottom.equalTo(passwordWrapper)
            make.width.equalTo(view)
        }

        loginButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(inputWrapper.snp.bottom).offset(30)
            make.width.equalTo(mainView).multipliedBy(0.75)
            make.centerX.equalTo(mainView)
            make.height.equalTo(40)
        }
    }

    private func setupInput(wrapper: UIView, field: UITextField, placeholder: String, parent: UIView, password: Bool, offset: Int = 4) {
        inputWrapper.addSubview(wrapper)

        field.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        field.isSecureTextEntry = password
        field.placeholder = placeholder
        wrapper.addSubview(field)

        wrapper.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(parent.snp.bottom).offset(offset)
            make.width.equalTo(mainView)
            make.height.equalTo(field).multipliedBy(2.25)
        }

        field.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(wrapper).offset(10)
            make.centerY.right.equalTo(wrapper)
        }

        if !password {
            let border = UIView(frame: .zero)
            border.backgroundColor = LoginViewController.border
            wrapper.addSubview(border)
            border.snp.makeConstraints { (make) -> Void in
                make.width.centerX.equalTo(field)
                make.height.equalTo(1)
                make.top.equalTo(wrapper.snp.bottom)
            }
        }
    }

    private func backgroundImage(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return colorImage!
        }
        abort()
    }

    @objc func login(_ sender: Any) {
    }
}
