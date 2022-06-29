
import UIKit
import CoreData

class ActivityDetailedViewController: UITabBarController, DeleteAlertProtocol {
    var activity: Activity
    var selectedIndexToDelete: Int
    lazy var conformDeleteAlert = DeleteAlert(delegate: self)
    lazy var titleRowEditAlert = TitleRowEditAlert()
    lazy var descRowEditAlert = DescRowEditAlert()
    lazy var favRowEditAlert = FavRowEditAlert()
    lazy var focusRowEditAlert = FocusRowEditAlert()

    init(activity: Activity, selectedIndexToDelete: Int) {
        self.activity = activity
        self.selectedIndexToDelete = selectedIndexToDelete
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var activityTableView: UITableView = {
        let activityTableView = UITableView()
        activityTableView.translatesAutoresizingMaskIntoConstraints = false
        activityTableView.delegate = self
        activityTableView.dataSource = self
        activityTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        activityTableView.backgroundColor = darkMoonColor
        return activityTableView
    }()

    private func confTableView() {
        NSLayoutConstraint.activate([
            activityTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityTableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityTableView.topAnchor.constraint(equalTo: view.topAnchor),
            activityTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = darkMoonColor
        title = "Details"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(activityTableView)
        confTableView()
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        let trashButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action:  #selector(trashButtonDidTapped))
        self.navigationItem.rightBarButtonItem = trashButton
        self.navigationItem.rightBarButtonItem?.tintColor = sandyYellowColor
        self.navigationController?.navigationBar.tintColor = sandyYellowColor
    }

    @objc func trashButtonDidTapped() {
        conformDeleteAlert.deleteActivity(on: self, with: "Are you sure?", message: "This will delete the activity forever")

        TimerViewControllerStruct.timerViewController.timerView.focusLabel.text = "tap to focus on activity"
        TimerViewControllerStruct.timerViewController.timerView.focusLabel.textColor = .systemGray
        TimerViewControllerStruct.timerViewController.timerView.focusLabel.layer.opacity = 0.1
        TimerViewControllerStruct.timerViewController.timerView.focusTextField.isHidden = false

        activity.isFocused = false
        TimerViewControllerStruct.timerViewController.stopActionDidPressed()
        TimerViewControllerStruct.timerViewController.stopTimer()
        print("Now activity (\(activity.title ?? "")) is deleted and NOT marked FOCUSED")
    }

    func deleteActivity() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        SelectedActivity.selectedActivity = self.activity

        do {
            if let selectedActivity = SelectedActivity.selectedActivity {
                appDelegate.persistentContainer.viewContext.delete(selectedActivity)
                selectedActivity.deletedDate = Date()
            }
            try appDelegate.persistentContainer.viewContext.save()
        } catch {
            print("Fetch failed")
        }

        SelectedActivity.selectedActivity = nil
        ActivitiesObject.arrayOfActivities.remove(at: selectedIndexToDelete)

        print("\(self.activity) is deleted")
        navigationController?.popViewController(animated: true)
    }
}
