import UIKit

class TaskListViewController: ViewControllerUtil, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var addButton = UIBarButtonItem()
    private let api: API
    private var tasks: [Task]
    private var firstLoad: Bool

    private static let reuseIdentifier = "TaskListCell"

    init(api: API, tasks: [Task]) {
        self.api = api
        self.tasks = tasks
        self.firstLoad = true

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tasks"

        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:)))
        navigationItem.setRightBarButton(addButton, animated: false)

        view.backgroundColor = Colors.background
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.width.equalTo(view)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskListViewController.reuseIdentifier)
        tableView.insetsContentViewsToSafeArea = true

        refreshControl.tintColor = Colors.refresh
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false

        if firstLoad {
            firstLoad = false
        } else {
            refreshControl.beginRefreshing()
            refresh(self)
        }

        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }

        applicationDidBecomeActive()
    }

    @objc override func applicationDidBecomeActive() {
        if AppDelegate.launchURL != nil {
            DispatchQueue.main.async { self.add(self) }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: TaskListViewController.reuseIdentifier) as? TaskCell {
            cell.update(task: tasks[indexPath.row])
            return cell
        }
        fatalError()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showLoading()
            api.deleteTask(taskId: tasks[indexPath.row].taskId) { (success) in
                if success {
                    self.hideLoading(completion: {
                        self.tasks.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    })
                } else {
                    self.errorOut(title: "Error", message: "Unable to delete task")
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoading()
        api.getTask(taskId: tasks[indexPath.row].taskId) { (task) in
            self.hideLoading()

            if task == nil {
                self.errorOut(title: "Error", message: "Unable to load task info")
                self.hideRow(indexPath)
            } else if task!.files.isEmpty {
                self.errorOut(title: "", message: "No file information to show")
                self.hideRow(indexPath)
            } else {
                self.hideLoading(completion: {
                    self.navigationController?.pushViewController(FileListViewController(api: self.api, task: task!), animated: true)
                })
            }
        }
    }

    @objc func refresh(_ sender: Any) {
        api.getTasks { (tasks: [Task]?) in
            DispatchQueue.main.async { self.refreshControl.endRefreshing() }

            if let tasks = tasks {
                DispatchQueue.main.async {
                    self.tasks = tasks
                    self.tableView.reloadData()
                }
            } else {
                self.showError(title: "Error", message: "Unable to refresh tasks")
            }
        }
    }

    @objc func add(_ sender: Any) {
        navigationController?.pushViewController(AddViewController(api: api), animated: true)
    }

    private func hideRow(_ indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
