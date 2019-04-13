import UIKit

class AddViewController: ViewControllerUtil, UITextViewDelegate {
    private let mainView = UIView()
    private let labelView = UILabel()
    private let textInput = UITextView()
    private var addButton = UIBarButtonItem()
    private let api: API

    static let background = UIColor(red: 239.0 / 255.0, green: 238.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)

    init(api: API) {
        self.api = api
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create download"

        addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(add(_:)))
        navigationItem.setRightBarButton(addButton, animated: false)

        view.backgroundColor = AddViewController.background
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))

        mainView.backgroundColor = AddViewController.background
        view.addSubview(mainView)

        labelView.text = "Enter URL"
        labelView.textColor = UIColor.black
        labelView.font = UIFont.boldSystemFont(ofSize: 16)
        mainView.addSubview(labelView)

        textInput.delegate = self
        textInput.autocorrectionType = .no
        textInput.autocapitalizationType = .none
        mainView.addSubview(textInput)

        mainView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view)
        }

        labelView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
        }

        textInput.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(labelView.snp.bottom).offset(8)
            make.height.equalTo(300)
            make.left.right.equalToSuperview()
        }

        textViewDidChange(textInput)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applicationDidBecomeActive()
    }

    @objc override func applicationDidBecomeActive() {
        if AppDelegate.launchURL != nil {
            DispatchQueue.main.async {
                self.textInput.text = AppDelegate.launchURL
                self.textViewDidChange(self.textInput)
                AppDelegate.launchURL = nil
            }
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        addButton.isEnabled = !textView.text.isEmpty
    }

    @objc func add(_ sender: Any) {
        showLoading()
        api.addTask(uri: textInput.text) { (success) in
            self.hideLoading()

            if success {
                DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
            } else {
                self.errorOut(title: "Error", message: "Unable to create task")
            }
        }
    }
}
