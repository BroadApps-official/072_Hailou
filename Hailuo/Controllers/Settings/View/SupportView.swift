import SnapKit
import UIKit

protocol SupportViewDelegate: AnyObject {
    func tapSupportView(type: SupportView.SupportType)
}

final class SupportView: UIControl {
    enum SupportType {
        case contact
        case privacyPolicy
        case usagePolicy

        var title: String {
            switch self {
            case .contact: return L.contact()
            case .privacyPolicy: return L.privacy()
            case .usagePolicy: return L.usage()
            }
        }

        var image: UIImage? {
            switch self {
            case .contact: return R.image.set_contact_icon()
            case .privacyPolicy: return R.image.set_privacy_icon()
            case .usagePolicy: return R.image.set_usage_icon()
            }
        }
    }

    // MARK: - Properties

    weak var delegate: SupportViewDelegate?

    private let buttonBackgroundView = UIButton(type: .system)
    private let typeImageView = UIImageView()
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()

    private var observation: NSKeyValueObservation?
    private let type: SupportType

    // MARK: - Init

    init(type: SupportType, delegate: SupportViewDelegate) {
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

        addSubviews(buttonBackgroundView)
        buttonBackgroundView.addSubview(typeImageView)
        buttonBackgroundView.addSubview(titleLabel)
        buttonBackgroundView.addSubview(arrowImageView)

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

        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
        }
    }

    // MARK: - Actions

    @objc private func didTapView() {
        delegate?.tapSupportView(type: type)
    }
}
