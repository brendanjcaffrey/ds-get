import UIKit

class TaskListViewController: ViewControllerUtil, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let api: API
    private var tasks: [Task]

    private static let reuseIdentifier = "TaskListCell"

    init(api: API, tasks: [Task]) {
        self.api = api
        self.tasks = tasks

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tasks"

        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskListViewController.reuseIdentifier)

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
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
                self.hideLoading()

                if success {
                    DispatchQueue.main.async {
                        self.tasks.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                } else {
                    self.errorOut(title: "Error", message: "Unable to delete task")
                }
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
}
