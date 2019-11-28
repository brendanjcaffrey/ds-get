import UIKit
import SnapKit

class LoginViewController: ViewControllerUtil, UITextFieldDelegate {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"

        view.backgroundColor = Colors.background
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))

        mainView.backgroundColor = Colors.background
        view.addSubview(mainView)

        titleView.text = "DS get"
        titleView.textColor = Colors.textOnBackground
        titleView.font = UIFont.systemFont(ofSize: 45)
        mainView.addSubview(titleView)

        inputWrapper.backgroundColor = Colors.textBackground
        mainView.addSubview(inputWrapper)

        let values = Defaults.load()
        setupInput(wrapper: hostWrapper, field: hostInput, parent: titleView, placeholder: "Host", value: values.host, password: false, offset: 30)
        setupInput(wrapper: userWrapper, field: userInput, parent: hostWrapper, placeholder: "User", value: values.user, password: false)
        setupInput(wrapper: passwordWrapper, field: passwordInput, parent: userWrapper, placeholder: "Password", value: values.password)

        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        loginButton.backgroundColor = Colors.buttonNormal
        loginButton.adjustsImageWhenHighlighted = true
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

        updateButtonEnabled(textField: nil, updatedText: "")

        if loginButton.isEnabled {
            DispatchQueue.main.async {
                self.login(self)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        updateButtonEnabled(textField: textField, updatedText: updatedText)
        return true
    }

    func updateButtonEnabled(textField: UITextField?, updatedText: String) {
        let host = textField == hostInput ? updatedText : hostInput.text!
        let user = textField == userInput ? updatedText : userInput.text!
        let password = textField == passwordInput ? updatedText : passwordInput.text!
        loginButton.isEnabled = !host.isEmpty && !user.isEmpty && !password.isEmpty
    }

    private func setupInput(wrapper: UIView, field: UITextField, parent: UIView, placeholder: String, value: String, password: Bool = true, offset: Int = 4) {
        inputWrapper.addSubview(wrapper)

        field.delegate = self
        field.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        field.isSecureTextEntry = password
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.placeholder = placeholder
        field.text = value
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
            border.backgroundColor = Colors.border
            wrapper.addSubview(border)
            border.snp.makeConstraints { (make) -> Void in
                make.width.centerX.equalTo(field)
                make.height.equalTo(1)
                make.top.equalTo(wrapper.snp.bottom)
            }
        }
    }

    @objc func login(_ sender: Any) {
        let values: Defaults.Values = (hostInput.text!, userInput.text!, passwordInput.text!)
        Defaults.save(values)
        showLoading()

        let api = API()
        api.login(values: values) { (success: Bool) in
            if success {
                self.getTasks(api)
            } else {
                self.errorOut(title: "Login failed", message: "Please check your host/user/password")
            }
        }
    }

    private func getTasks(_ api: API) {
        api.getTasks { (tasks: [Task]?) in
            if let tasks = tasks {
                self.showTasks(api, tasks)
            } else {
                self.errorOut(title: "Unable to load tasks", message: "Please check your internet connection")
            }
        }
    }

    private func showTasks(_ api: API, _ tasks: [Task]) {
        hideLoading(completion: {
            self.navigationController?.pushViewController(TaskListViewController(api: api, tasks: tasks), animated: true)
        })
    }
}
