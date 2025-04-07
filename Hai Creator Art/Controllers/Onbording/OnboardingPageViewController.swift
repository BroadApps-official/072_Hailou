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
        imageView.image = UIImage(named: "onb_effects_image")

        mainLabel.do { make in
            make.text = "Lots of effects"
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.largeTitleBold
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = "Try all the effects and create a unique masterpiece."
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
        imageView.image = UIImage(named: "onb_photo_image")

        mainLabel.do { make in
            make.text = "Add photos"
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.largeTitleBold
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = "Create a video with your image in a few taps"
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
        imageView.image = UIImage(named: "onb_request_image")

        mainLabel.do { make in
            make.text = "Create a request"
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.largeTitleBold
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = "Generate an image using AI to the maximum"
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
        imageView.image = UIImage(named: "onb_rate_image")

        mainLabel.do { make in
            make.text = "Rate our app in the AppStore"
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
        imageView.image = UIImage(named: "onb_notifications_image")

        mainLabel.do { make in
            make.text = "Don't miss new trends"
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.largeTitleBold
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = "Allow notifications"
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
