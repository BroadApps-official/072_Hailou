import SnapKit
import UIKit

protocol SelectorDelegate: AnyObject {
    func didSelect(at index: Int)
}

final class SelectorView: UIControl {
    private let mainContainerView = UIView()
    private let imageView = UIView()
    private let textView = UIView()
    private let imageLabel = UILabel()
    private let textLabel = UILabel()
    private let containerStackView = UIStackView()
    
    private var selectedIndex: Int? {
        didSet { updateViewsAppearance() }
    }

    private var views: [UIView] = []
    weak var delegate: SelectorDelegate?

    init(selectedIndex: Int, frame: CGRect) {
        super.init(frame: frame)
        self.selectedIndex = selectedIndex
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        mainContainerView.backgroundColor = UIColor.bgTertiary
        mainContainerView.layer.cornerRadius = 12

        [imageView, textView].forEach { view in
            view.backgroundColor = UIColor.accentPrimary
            view.isUserInteractionEnabled = true
            view.layer.cornerRadius = 12
        }

        containerStackView.axis = .horizontal
        containerStackView.spacing = 0
        containerStackView.distribution = .fillEqually

        imageLabel.text = L.imageVideo()
        imageLabel.textAlignment = .center

        textLabel.text = L.textVideo()
        textLabel.textAlignment = .center

        imageView.addSubview(imageLabel)
        textView.addSubview(textLabel)
        containerStackView.addArrangedSubviews([imageView, textView])
        mainContainerView.addSubview(containerStackView)
        addSubview(mainContainerView)

        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textTapped)))

        views = [imageView, textView]
        updateViewsAppearance()
    }

    private func setupConstraints() {
        mainContainerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        [imageLabel, textLabel].forEach {
            $0.snp.makeConstraints { $0.center.equalToSuperview() }
        }

        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(48)
        }

        [imageView, textView].forEach {
            $0.snp.makeConstraints {
                $0.top.bottom.equalTo(containerStackView).inset(2)
                $0.height.equalTo(45)
            }
        }

        imageView.snp.makeConstraints { $0.leading.equalTo(containerStackView).offset(2) }
        textView.snp.makeConstraints { $0.trailing.equalTo(containerStackView).offset(-2) }
    }

    @objc private func imageTapped() { selectedIndex = 0 }
    @objc private func textTapped() { selectedIndex = 1 }

    private func updateViewsAppearance() {
        views.enumerated().forEach { index, view in
            let isSelected = index == selectedIndex
            let label = (view == imageView) ? imageLabel : textLabel

            view.layer.sublayers?
                .filter { $0 is CAGradientLayer }
                .forEach { $0.removeFromSuperlayer() }

            if isSelected {
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [
                    UIColor(red: 249 / 255, green: 171 / 255, blue: 251 / 255, alpha: 1).cgColor,
                    UIColor(red: 151 / 255, green: 208 / 255, blue: 248 / 255, alpha: 1).cgColor
                ]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
                gradientLayer.frame = view.bounds
                gradientLayer.cornerRadius = 12
                view.layer.insertSublayer(gradientLayer, at: 0)
            } else {
                view.backgroundColor = .clear
            }

            label.font = isSelected ? UIFont.CustomFont.footnoteSemibold : UIFont.CustomFont.footnoteRegular
            label.textColor = isSelected ? UIColor.labelsPrimaryInverted : UIColor.labelsTertiary

            view.bringSubviewToFront(label)
        }

        delegate?.didSelect(at: selectedIndex ?? 0)
    }

    func configure(selectedIndex: Int) {
        guard (0..<views.count).contains(selectedIndex) else { return }
        self.selectedIndex = selectedIndex
    }

    func updateFirstLabel(_ text: String) { imageLabel.text = text }
    func updateSecondLabel(_ text: String) { textLabel.text = text }
}
