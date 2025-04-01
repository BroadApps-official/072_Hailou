import SnapKit
import UIKit

final class TabBarController: UITabBarController {
    static let shared = TabBarController()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        let homeVC = UINavigationController(
            rootViewController: HomeViewController()
        )

        let emptyVC = UINavigationController(
            rootViewController: UIViewController()
        )

        let historyVC = UINavigationController(
            rootViewController: HistoryViewController()
        )

        homeVC.tabBarItem = UITabBarItem(
            title: L.home(),
            image: UIImage(systemName: "heart.fill"),
            tag: 0
        )

        emptyVC.tabBarItem = UITabBarItem(
            title: "",
            image: nil,
            tag: 0
        )

        historyVC.tabBarItem = UITabBarItem(
            title: L.history(),
            image: UIImage(systemName: "doc.on.doc.fill"),
            tag: 2
        )

        emptyVC.tabBarItem.isEnabled = false
        let viewControllers = [homeVC, emptyVC, historyVC]
        self.viewControllers = viewControllers

        addCenterButton()

        addSeparatorLine()
        updateTabBar()
    }

    func updateTabBar() {
        tabBar.backgroundColor = UIColor.bgPrimary
        tabBar.tintColor = UIColor.accentPrimary
        tabBar.unselectedItemTintColor = UIColor.labelsQuaternary
        tabBar.itemPositioning = .centered
    }

    private func addSeparatorLine() {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.bgSecond
        tabBar.addSubview(separatorLine)

        separatorLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalTo(tabBar)
            make.top.equalTo(tabBar.snp.top)
        }
    }

    private func addCenterButton() {
        let centerButton = UIButton(type: .custom)
        centerButton.setImage(R.image.tab_add_button(), for: .normal)
        centerButton.backgroundColor = UIColor.colorsSecondary
        centerButton.layer.cornerRadius = 30
        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)

        tabBar.addSubview(centerButton)

        centerButton.snp.makeConstraints { make in
            make.centerX.equalTo(tabBar)
            make.width.height.equalTo(40)
            if UIDevice.isIphoneBelowX {
                make.centerY.equalTo(tabBar)
            } else {
                make.centerY.equalTo(tabBar).offset(-15)
            }
        }
    }

    @objc private func centerButtonTapped() {
        let createVC = CreateViewController(selectedIndex: 0)
        let navigationController = UINavigationController(rootViewController: createVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}
