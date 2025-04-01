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
        didSet {
            updateViewsAppearance()
        }
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
        mainContainerView.do { make in
            make.backgroundColor = UIColor.bgTertiary
            make.layer.cornerRadius = 12
        }

        imageView.do { make in
            make.backgroundColor = UIColor.accentPrimary
            make.isUserInteractionEnabled = true
            make.layer.cornerRadius = 12
        }

        textView.do { make in
            make.backgroundColor = UIColor.accentPrimary
            make.isUserInteractionEnabled = true
            make.layer.cornerRadius = 12
        }

        containerStackView.do { make in
            make.axis = .horizontal
            make.spacing = 0
            make.distribution = .fillEqually
        }

        imageLabel.do { make in
            make.text = L.imageVideo()
            make.textAlignment = .center
        }

        textLabel.do { make in
            make.text = L.textVideo()
            make.textAlignment = .center
        }

        imageView.addSubview(imageLabel)
        textView.addSubview(textLabel)

        containerStackView.addArrangedSubviews(
            [imageView, textView]
        )
        mainContainerView.addSubviews(containerStackView)
        addSubview(mainContainerView)

        let tapGestureRecognizers = [
            UITapGestureRecognizer(target: self, action: #selector(imageTapped)),
            UITapGestureRecognizer(target: self, action: #selector(textTapped))
        ]

        imageView.addGestureRecognizer(tapGestureRecognizers[0])
        textView.addGestureRecognizer(tapGestureRecognizers[1])

        views = [imageView, textView]
        updateViewsAppearance()
    }

    private func setupConstraints() {
        mainContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        [imageLabel, textLabel].forEach { label in
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }

        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(48)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(containerStackView.snp.top).offset(2)
            make.bottom.equalTo(containerStackView.snp.bottom).offset(-2)
            make.leading.equalTo(containerStackView.snp.leading).offset(2)
            make.height.equalTo(45)
        }

        textView.snp.makeConstraints { make in
            make.top.equalTo(containerStackView.snp.top).offset(2)
            make.bottom.equalTo(containerStackView.snp.bottom).offset(-2)
            make.trailing.equalTo(containerStackView.snp.trailing).offset(-2)
            make.height.equalTo(45)
        }
    }

    @objc private func imageTapped() {
        selectedIndex = 0
    }

    @objc private func textTapped() {
        selectedIndex = 1
    }

    private func updateViewsAppearance() {
        for (index, view) in views.enumerated() {
            let isSelected = index == selectedIndex
            let label = (view == imageView) ? imageLabel : textLabel

            view.setNeedsLayout()
            view.layoutIfNeeded()

            if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
                gradientLayer.removeFromSuperlayer()
            }

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
                gradientLayer.masksToBounds = true

                view.layer.insertSublayer(gradientLayer, at: 0)
            } else {
                view.backgroundColor = .clear
            }

            label.font = isSelected ? UIFont.CustomFont.footnoteSemibold : UIFont.CustomFont.footnoteRegular
            label.textColor = isSelected ? UIColor.labelsPrimaryInverted : UIColor.labelsTertiary

            view.bringSubviewToFront(label)
        }

        setNeedsLayout()
        layoutIfNeeded()

        guard let selectedIndex = selectedIndex else { return }
        delegate?.didSelect(at: selectedIndex)
    }

    func configure(selectedIndex: Int) {
        guard selectedIndex >= 0 && selectedIndex < views.count else {
            fatalError("Invalid index provided for SelectorView configuration")
        }
        self.selectedIndex = selectedIndex
        updateViewsAppearance()
    }

    func updateFirstLabel(_ text: String) {
        imageLabel.text = text
    }

    func updateSecondLabel(_ text: String) {
        textLabel.text = text
    }
}
