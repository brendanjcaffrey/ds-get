import UIKit

class TaskListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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

    @objc func refresh(_ sender: Any) {
        api.getTasks { (tasks: [Task]?) in
            DispatchQueue.main.async { self.refreshControl.endRefreshing() }
            if let tasks = tasks {
                DispatchQueue.main.async {
                    self.tasks = tasks
                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Unable to refresh tasks", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
