import SnapKit
import UIKit

protocol NotificationsViewDelegate: AnyObject {
    func tapNotificationsView(switchValue: Bool)
}

final class NotificationsView: UIControl {
    // MARK: - Properties

    weak var delegate: NotificationsViewDelegate?

    private let backgroundView = UIButton(type: .system)
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let switchControl = UISwitch()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        drawSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Draw

    private func drawSelf() {
        imageView.contentMode = .scaleAspectFit
        backgroundView.isUserInteractionEnabled = true

        titleLabel.do { make in
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.bodyRegular
        }

        switchControl.do { make in
            make.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
            make.onTintColor = UIColor(hex: "#30D158")
            make.thumbTintColor = UIColor(hex: "#E8E8E8")
            make.backgroundColor = .clear
            make.layer.cornerRadius = 32
        }

        addSubviews(backgroundView, switchControl)
        backgroundView.addSubview(imageView)
        backgroundView.addSubview(titleLabel)

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        }

        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(titleLabel.snp.leading).offset(-12)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(56)
        }
        
        switchControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(31)
            make.width.equalTo(51)
        }
    }
    
    func configureNotificationsView(icon: UIImage?, title: String) {
        imageView.image = icon
        titleLabel.text = title
    }

    // MARK: - Actions
    @objc private func switchValueChanged() {
        let value = switchControl.isOn
        delegate?.tapNotificationsView(switchValue: value)
    }
}
