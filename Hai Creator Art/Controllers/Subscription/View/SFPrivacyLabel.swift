import UIKit

protocol SFPrivacyDelegate: AnyObject {
    func privacyTapped()
}

class SFPrivacyButton: UIButton {
    weak var delegate: SFPrivacyDelegate?

    var mainColor: UIColor = UIColor.labelsQuaternary {
        didSet {
            setTitleColor(mainColor, for: .normal)
        }
    }

    init() {
        super.init(frame: .zero)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        setTitle("Privacy Policy", for: .normal)
        titleLabel?.font = UIFont.CustomFont.caption2Regular
        setTitleColor(mainColor, for: .normal)
        backgroundColor = .clear
        addTarget(self, action: #selector(didTapPrivacyPolicy), for: .touchUpInside)
    }

    @objc private func didTapPrivacyPolicy() {
        animateClick { [weak self] in
            self?.delegate?.privacyTapped()
        }
    }

    private func animateClick(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.05, 
                       animations: {
                           self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
                       }) { _ in
            UIView.animate(withDuration: 0.05,
                           animations: {
                               self.transform = .identity
                           }) { _ in
                completion()
            }
        }
    }
}
