import UIKit

class TaskCell: UITableViewCell {
    let iconView = UILabel()
    let titleView = UILabel()
    let leftSubtitleView = UILabel()
    let rightSubtitleView = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator
        iconView.font = UIFont.systemFont(ofSize: 30)
        iconView.textAlignment = .center
        titleView.font = UIFont.boldSystemFont(ofSize: 20)
        titleView.numberOfLines = 0
        leftSubtitleView.font = UIFont.systemFont(ofSize: 12)
        leftSubtitleView.textColor = UIColor.lightGray
        rightSubtitleView.font = UIFont.systemFont(ofSize: 12)
        rightSubtitleView.textColor = UIColor.lightGray
        rightSubtitleView.textAlignment = .right

        contentView.addSubview(iconView)
        contentView.addSubview(titleView)
        contentView.addSubview(leftSubtitleView)
        contentView.addSubview(rightSubtitleView)

        iconView.snp.makeConstraints { (make) in
            make.left.top.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.15)
        }
        titleView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(iconView.snp.right).offset(8)
            make.width.equalToSuperview().multipliedBy(0.83)
        }
        leftSubtitleView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(rightSubtitleView)
            make.left.equalTo(titleView)
        }
        rightSubtitleView.snp.makeConstraints { (make) in
            // setting this priority below suppresses an error when deleting cells
            make.top.equalTo(titleView.snp.bottom).offset(4).priority(500)
            make.bottom.equalToSuperview().offset(-8)
            make.right.equalTo(titleView)
        }

        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(task: Task) {
        iconView.text = task.icon()
        titleView.text = task.title

        if task.downloadedSize < task.totalSize {
            leftSubtitleView.text = task.downloadSpeedString()
            rightSubtitleView.text = task.downloadPercentString()
        } else {
            leftSubtitleView.text = ""
            rightSubtitleView.text = task.downloadTotalString()
        }
    }
}
