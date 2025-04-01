import SnapKit
import UIKit

protocol RateViewDelegate: AnyObject {
    func tapRateView()
}

final class RateView: UIControl {
    // MARK: - Properties

    weak var delegate: RateViewDelegate?

    private let buttonBackgroundView = UIButton(type: .system)
    private let typeImageView = UIImageView()
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()

    private var observation: NSKeyValueObservation?

    // MARK: - Init

    init(delegate: RateViewDelegate) {
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

        typeImageView.image = R.image.set_rate_icon()
        typeImageView.contentMode = .scaleAspectFit

        buttonBackgroundView.isUserInteractionEnabled = true

        titleLabel.do { make in
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.bodyRegular
            make.text = L.rateApp()
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
        delegate?.tapRateView()
    }
}
