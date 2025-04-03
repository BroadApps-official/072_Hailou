import UIKit

class SubCell: UICollectionViewCell {
    static let identifier = "SubCell"

    private let secondLabel = UILabel()
    private let priceStackView = UIStackView()
    private let circleImageView = UIImageView()
    private let containerView = UIView()
    private let underLabel = UILabel()

    private let saveLabel = UILabel()
    private let saveView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradientBackground(isSelected: isSelected)
        applyGradientBorder(isSelected: isSelected)
        applyGradientSaveBackground()
        saveView.bringSubviewToFront(saveLabel)
    }

    private func setupUI() {
        backgroundColor = .clear
        containerView.isUserInteractionEnabled = false
        circleImageView.image = R.image.sub_cell_circle()
        circleImageView.tintColor = UIColor.textInactive

        containerView.do { make in
            make.backgroundColor = UIColor.bgTertiary
            make.layer.cornerRadius = 16
        }

        underLabel.do { make in
            make.text = L.underLabel()
            make.font = UIFont.CustomFont.caption2Regular
            make.textColor = UIColor.labelsQuaternary
            make.textAlignment = .left
        }

        secondLabel.do { make in
            make.text = "Just $29.99 / Annual"
            make.font = UIFont.CustomFont.bodyRegular
            make.textColor = UIColor.labelsPrimary
            make.textAlignment = .left
        }

        priceStackView.do { make in
            make.axis = .vertical
            make.spacing = 2
            make.alignment = .leading
            make.distribution = .fill
        }

        saveLabel.do { make in
            make.text = "SAVE 40%"
            make.textAlignment = .center
            make.font = UIFont.CustomFont.caption2Semibold
            make.textColor = UIColor.labelsPrimaryInverted
        }

        saveView.do { make in
            make.layer.cornerRadius = 16
            make.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
            make.layer.masksToBounds = true
        }

        priceStackView.addArrangedSubviews([secondLabel, underLabel])
        saveView.addSubviews(saveLabel)
        saveView.bringSubviewToFront(saveLabel)
        addSubviews(circleImageView, containerView, priceStackView, saveView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        circleImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }

        priceStackView.snp.makeConstraints { make in
            make.leading.equalTo(circleImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        saveView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(21)
            make.width.equalTo(82)
        }

        saveLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }

    func configureAppearance(isSelected: Bool) {
        applyGradientBackground(isSelected: isSelected)
        applyGradientBorder(isSelected: isSelected)
        circleImageView.image = isSelected ? R.image.sub_cell_circleFill() : R.image.sub_cell_circle()
    }

    func configure(name: String, price: String, weeklyPrice: String?, isFirst: Bool) {
        secondLabel.text = "Just \(price) / \(name.capitalized)"
        saveView.isHidden = !isFirst
    }

    private func applyGradientBackground(isSelected: Bool) {
        containerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        guard isSelected else {
            containerView.backgroundColor = UIColor.bgTertiary
            return
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 246 / 255, green: 172 / 255, blue: 250 / 255, alpha: 0).cgColor,
            UIColor(red: 50 / 255, green: 107 / 255, blue: 118 / 255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = containerView.bounds
        gradientLayer.cornerRadius = 16

        containerView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func applyGradientBorder(isSelected: Bool) {
        containerView.layer.sublayers?.removeAll(where: { $0.name == "gradientBorder" })

        guard isSelected else {
            containerView.layer.borderWidth = 0
            return
        }

        let borderLayer = CAGradientLayer()
        borderLayer.colors = [
            UIColor(red: 249 / 255, green: 171 / 255, blue: 251 / 255, alpha: 1).cgColor,
            UIColor(red: 151 / 255, green: 208 / 255, blue: 248 / 255, alpha: 1).cgColor
        ]
        borderLayer.startPoint = CGPoint(x: 0, y: 0.5)
        borderLayer.endPoint = CGPoint(x: 1, y: 0.5)

        let offsetX: CGFloat = 1.2
        let offsetY: CGFloat = 1.5

        borderLayer.frame = containerView.bounds.insetBy(dx: -1, dy: -1)
        borderLayer.frame.origin.x += offsetX
        borderLayer.frame.origin.y += offsetY
        borderLayer.cornerRadius = containerView.layer.cornerRadius + 1
        borderLayer.name = "gradientBorder"

        let maskLayer = CAShapeLayer()
        let inset: CGFloat = 2
        let path = UIBezierPath(roundedRect: containerView.bounds.insetBy(dx: inset, dy: inset), cornerRadius: containerView.layer.cornerRadius)

        maskLayer.path = path.cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = 3
        borderLayer.mask = maskLayer

        containerView.layer.addSublayer(borderLayer)
    }

    private func applyGradientSaveBackground() {
        if saveView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) == nil {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor(red: 249 / 255, green: 171 / 255, blue: 251 / 255, alpha: 1).cgColor,
                UIColor(red: 151 / 255, green: 208 / 255, blue: 248 / 255, alpha: 1).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.frame = saveView.bounds

            let maskPath = UIBezierPath(roundedRect: saveView.bounds,
                                        byRoundingCorners: [.topRight, .bottomLeft],
                                        cornerRadii: CGSize(width: 16, height: 16))

            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            gradientLayer.mask = maskLayer

            saveView.layer.addSublayer(gradientLayer)
        }
    }
}
