import AVKit
import UIKit

final class OnboardingPageViewController: UIViewController {
    // MARK: - Types

    enum Page {
        case effects, photo, request, rate, notifications
    }

    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    private let imageView = UIImageView()

    // MARK: - Properties info

    private let page: Page

    // MARK: - Init

    init(page: Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.bgPrimary

        switch page {
        case .effects: drawEffects()
        case .photo: drawPhoto()
        case .request: drawRequest()
        case .rate: drawRate()
        case .notifications: drawNotifications()
        }
    }

    // MARK: - Draw

    private func drawEffects() {
        imageView.image = R.image.onb_effects_image()

        mainLabel.do { make in
            make.text = L.effectsLabel()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.largeTitleBold
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = L.effectsSubLabel()
            make.textColor = UIColor.labelsTertiary
            make.font = UIFont.CustomFont.bodyRegular
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, subLabel, mainLabel)

        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(-40)
                make.height.equalTo(UIScreen.main.bounds.height * (625.0 / 844.0))
            } else {
                make.top.equalToSuperview()
            }
            if UIDevice.isIpad {
                make.height.equalTo(UIScreen.main.bounds.height * (585.0 / 844.0))
            }
        }

        mainLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(imageView.snp.bottom)
        }

        subLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(37)
            make.top.equalTo(mainLabel.snp.bottom).offset(6)
        }
    }

    private func drawPhoto() {
        imageView.image = R.image.onb_photo_image()

        mainLabel.do { make in
            make.text = L.photoLabel()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.largeTitleBold
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = L.photoSubLabel()
            make.textColor = UIColor.labelsTertiary
            make.font = UIFont.CustomFont.bodyRegular
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, subLabel, mainLabel)

        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(-40)
                make.height.equalTo(UIScreen.main.bounds.height * (625.0 / 844.0))
            } else {
                make.top.equalToSuperview()
            }
            if UIDevice.isIpad {
                make.height.equalTo(UIScreen.main.bounds.height * (585.0 / 844.0))
            }
        }

        mainLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(imageView.snp.bottom)
        }

        subLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(37)
            make.top.equalTo(mainLabel.snp.bottom).offset(6)
        }
    }

    private func drawRequest() {
        imageView.image = R.image.onb_request_image()

        mainLabel.do { make in
            make.text = L.requestLabel()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.largeTitleBold
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = L.requestSubLabel()
            make.textColor = UIColor.labelsTertiary
            make.font = UIFont.CustomFont.bodyRegular
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, subLabel, mainLabel)

        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(-40)
                make.height.equalTo(UIScreen.main.bounds.height * (625.0 / 844.0))
            } else {
                make.top.equalToSuperview()
            }
            if UIDevice.isIpad {
                make.height.equalTo(UIScreen.main.bounds.height * (585.0 / 844.0))
            }
        }

        mainLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(imageView.snp.bottom)
        }

        subLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(37)
            make.top.equalTo(mainLabel.snp.bottom).offset(6)
        }
    }

    private func drawRate() {
        imageView.image = R.image.onb_rate_image()

        mainLabel.do { make in
            make.text = L.rateLabel()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.largeTitleBold
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, mainLabel)

        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(-40)
                make.height.equalTo(UIScreen.main.bounds.height * (625.0 / 844.0))
            } else {
                make.top.equalToSuperview()
            }
            if UIDevice.isIpad {
                make.height.equalTo(UIScreen.main.bounds.height * (585.0 / 844.0))
            }
        }

        mainLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(imageView.snp.bottom)
        }
    }

    private func drawNotifications() {
        imageView.image = R.image.onb_notifications_image()

        mainLabel.do { make in
            make.text = L.notificationsLabel()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.largeTitleBold
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = L.notificationsSubLabel()
            make.textColor = UIColor.labelsTertiary
            make.font = UIFont.CustomFont.bodyRegular
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, subLabel, mainLabel)

        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(-40)
                make.height.equalTo(UIScreen.main.bounds.height * (625.0 / 844.0))
            } else {
                make.top.equalToSuperview()
            }
            if UIDevice.isIpad {
                make.height.equalTo(UIScreen.main.bounds.height * (585.0 / 844.0))
            }
        }

        mainLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(imageView.snp.bottom)
        }

        subLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(37)
            make.top.equalTo(mainLabel.snp.bottom).offset(6)
        }
    }
}
