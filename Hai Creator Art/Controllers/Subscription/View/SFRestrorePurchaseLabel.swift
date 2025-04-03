import StoreKit
import UIKit

protocol SFRestorePurchaseButtonDelegate: AnyObject {
    func didFailToRestorePurchases()
}

class SFRestorePurchaseButton: UIButton {
    weak var delegate: SFRestorePurchaseButtonDelegate?
    private let purchaseManager = PaymentManager()
    
    var mainColor: UIColor = UIColor.labelsTertiary {
        didSet {
            updateAppearance()
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
        setTitle(L.restoreLabel(), for: .normal)
        titleLabel?.font = UIFont.CustomFont.caption1Regular
        setTitleColor(mainColor, for: .normal)
        backgroundColor = .clear
        addTarget(self, action: #selector(didTapRestorePurchases), for: .touchUpInside)
    }
    
    private func updateAppearance() {
        setTitleColor(mainColor, for: .normal)
    }
    
    @objc private func didTapRestorePurchases() {
        animateClick { [weak self] in
            self?.restorePurchases()
        }
    }

    private func animateClick(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.05, animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.05, animations: {
                self.transform = .identity
            }) { _ in
                completion()
            }
        }
    }

    private func restorePurchases() {
        purchaseManager.restorePurchase { [weak self] success in
            guard let self = self else { return }
            
            if success {
                print("Restore purchase succeeded.")
            } else {
                print("Restore purchase failed.")
                self.delegate?.didFailToRestorePurchases()
            }
        }
    }
}
