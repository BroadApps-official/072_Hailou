import UIKit

protocol SFTermsOfUseDelegate: AnyObject {
    func termsOfUseTapped()
}

class SFTermsOfUseButton: UIButton {
    weak var delegate: SFTermsOfUseDelegate?

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
        setTitle(L.termsOfUse(), for: .normal)
        titleLabel?.font = UIFont.CustomFont.caption2Regular
        setTitleColor(mainColor, for: .normal)
        backgroundColor = .clear
        addTarget(self, action: #selector(didTapTermsOfUse), for: .touchUpInside)
    }
    
    @objc private func didTapTermsOfUse() {
        animateClick { [weak self] in
            self?.delegate?.termsOfUseTapped()
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
