import UIKit

class TaskListViewController: UIViewController {
    private let api: API
    private var tasks: [Task]

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
        view.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
