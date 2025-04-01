import SnapKit
import UIKit

protocol ActionsViewDelegate: AnyObject {
    func tapActionsView(type: ActionsView.ActionsType, switchValue: Bool)
}

final class ActionsView: UIControl {
    enum ActionsType {
        case upgrade
        case restorePurchases
        case notifications
        case cashe

        var title: String {
            switch self {
            case .upgrade: return L.upgrade()
            case .restorePurchases: return L.restore()
            case .notifications: return L.notifications()
            case .cashe: return L.clearCache()
            }
        }

        var image: UIImage? {
            switch self {
            case .upgrade: return R.image.set_upgrade_icon()
            case .restorePurchases: return R.image.set_restore_icon()
            case .notifications: return R.image.set_notifications_icon()
            case .cashe: return R.image.set_cashe_icon()
            }
        }
    }

    // MARK: - Properties

    weak var delegate: ActionsViewDelegate?

    private let buttonBackgroundView = UIButton(type: .system)
    private let typeImageView = UIImageView()
    private let titleLabel = UILabel()
    private let switchControl = UISwitch()
    private let arrowImageView = UIImageView()

    private var observation: NSKeyValueObservation?
    private let type: ActionsType

    // MARK: - Init

    init(type: ActionsType, delegate: ActionsViewDelegate) {
        self.type = type
        self.delegate = delegate

        super.init(frame: .zero)
        drawSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Draw

    private func drawSelf() {
        arrowImageView.image = R.image.set_arrow_icon()
        buttonBackgroundView.addTarget(self, action: #selector(didTapView), for: .touchUpInside)

        observation = buttonBackgroundView.observe(\.isHighlighted, options: [.old, .new], changeHandler: { [weak self] _, change in
            guard let self, let oldValue = change.oldValue, let newValue = change.newValue else {
                return
            }
            guard oldValue != newValue else { return }

            titleLabel.textColor = newValue ? .white.withAlphaComponent(0.7) : .white
        })

        typeImageView.image = type.image
        typeImageView.contentMode = .scaleAspectFit

        buttonBackgroundView.isUserInteractionEnabled = true

        titleLabel.do { make in
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.bodyRegular
            make.text = type.title
        }

        switchControl.do { make in
            make.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
            make.onTintColor = UIColor(hex: "#30D158")
            make.thumbTintColor = UIColor(hex: "#E8E8E8")
            make.backgroundColor = .clear
            make.layer.cornerRadius = 32
        }

        addSubviews(buttonBackgroundView)
        buttonBackgroundView.addSubview(typeImageView)
        buttonBackgroundView.addSubview(titleLabel)

        if type != .notifications {
            buttonBackgroundView.addSubview(arrowImageView)
        }

        if type == .notifications {
            addSubviews(switchControl)
        }

        buttonBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        }

        typeImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(titleLabel.snp.leading).offset(-12)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(56)
        }

        if type == .notifications {
            switchControl.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-16)
                make.height.equalTo(31)
                make.width.equalTo(51)
            }
        } else {
            arrowImageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-15)
            }
        }
    }

    // MARK: - Actions

    @objc private func didTapView() {
        if type != .notifications {
            delegate?.tapActionsView(type: type, switchValue: false)
        }
    }

    @objc private func switchValueChanged() {
        let value = switchControl.isOn

        if type == .notifications {
            delegate?.tapActionsView(type: type, switchValue: value)
        }
    }
}
