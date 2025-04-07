import SnapKit
import UIKit

protocol SettingsViewDelegate: AnyObject {
    func tapSettingsView(type: SettingsView.SettingsType)
}

final class SettingsView: UIControl {
    enum SettingsType {
        case rate
        case upgrade
        case cache
        case restore
        case contact
        case privacyPolicy
        case usagePolicy
    }

    // MARK: - Properties

    weak var delegate: SettingsViewDelegate?

    private let backgroundView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let type: SettingsType

    // MARK: - Init

    init(type: SettingsType) {
        self.type = type

        super.init(frame: .zero)
        drawSelf()
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Draw

    private func drawSelf() {
        arrowImageView.image = UIImage(named: "set_arrow_icon")
        backgroundView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSettingsView))
        backgroundView.addGestureRecognizer(tapGesture)
        imageView.contentMode = .scaleAspectFit

        titleLabel.do { make in
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.bodyRegular
        }

        addSubviews(backgroundView)
        backgroundView.addSubview(imageView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(arrowImageView)

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

        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
        }
    }
    
    func configureSettingsView(icon: UIImage?, title: String) {
        imageView.image = icon
        titleLabel.text = title
    }

    // MARK: - Actions

    @objc private func didTapSettingsView() {
        delegate?.tapSettingsView(type: type)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.7
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1.0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        alpha = 1.0
    }
}
