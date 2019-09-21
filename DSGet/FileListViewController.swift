import UIKit

class FileListViewController: ViewControllerUtil, UITableViewDataSource {
    private let mainView = UIView()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let api: API
    private var task: Task

    private static let reuseIdentifier = "FilesListCell"

    init(api: API, task: Task) {
        self.api = api
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = task.title

        view.backgroundColor = Colors.textBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.width.equalTo(view)
        }

        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.insetsContentViewsToSafeArea = true

        refreshControl.tintColor = Colors.background
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applicationDidBecomeActive()
    }

    @objc override func applicationDidBecomeActive() {
        if AppDelegate.launchURL != nil {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return task.files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = task.files[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FileListViewController.reuseIdentifier) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: FileListViewController.reuseIdentifier)

        cell.textLabel?.text = file.title
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = file.downloadPercentString()
        cell.detailTextLabel?.textAlignment = .right
        cell.selectionStyle = .none

        return cell
    }

    @objc func refresh(_ sender: Any) {
        api.getTask(taskId: task.taskId) { (task: Task?) in
            DispatchQueue.main.async { self.refreshControl.endRefreshing() }

            if let task = task {
                DispatchQueue.main.async {
                    self.task = task
                    self.tableView.reloadData()
                }
            } else {
                self.showError(title: "Error", message: "Unable to refresh files")
            }
        }
    }
}
