import UIKit

final class HailuoButton: UIControl {
    // MARK: - Properties

    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    private var shouldApplyGradient = true
    private let titleLabel = UILabel()
    let buttonContainer = UIView()

    private let stackView = UIStackView()
    private let arrowImageView = UIImageView()
    private let playImageView = UIImageView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if shouldApplyGradient {
            applyGradient()
        }
    }

    // MARK: - Private methods

    private func drawSelf() {
        buttonContainer.do { make in
            make.backgroundColor = UIColor.colorsSecondary
            make.layer.cornerRadius = 12
            make.isUserInteractionEnabled = false
        }

        titleLabel.do { make in
            make.text = L.next()
            make.textColor = UIColor.labelsPrimaryInverted
            make.font = UIFont.CustomFont.bodySemibold
            make.isUserInteractionEnabled = false
        }

        stackView.do { make in
            make.axis = .horizontal
            make.alignment = .center
            make.spacing = 8
            make.distribution = .fillProportionally
            make.isUserInteractionEnabled = false
        }

        buttonContainer.addSubview(titleLabel)
        addSubviews(buttonContainer)

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        buttonContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func applyGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 0.98, green: 0.67, blue: 0.98, alpha: 1.0).cgColor,
                                UIColor(red: 0.59, green: 0.82, blue: 0.97, alpha: 1.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = buttonContainer.bounds
        gradientLayer.cornerRadius = 14

        buttonContainer.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func removeGradient() {
        buttonContainer.layer.sublayers?.removeAll { $0 is CAGradientLayer }
    }

    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }

    func setTitle(to title: String) {
        titleLabel.text = title
    }

    func setTextColor(_ color: UIColor) {
        titleLabel.textColor = color
    }

    func setBackgroundColor(_ color: UIColor) {
        buttonContainer.backgroundColor = color
    }

    func createOffMode() {
        buttonContainer.isUserInteractionEnabled = false
        shouldApplyGradient = false
        removeGradient()
        buttonContainer.do { make in
            make.backgroundColor = UIColor.accentGrey
            make.layer.cornerRadius = 12
            make.isUserInteractionEnabled = false
        }

        titleLabel.do { make in
            make.text = L.toCreate()
            make.textColor = UIColor.labelsQuintuple
            make.font = UIFont.CustomFont.bodySemibold
            make.isUserInteractionEnabled = false
        }
        setNeedsLayout()
    }

    func createOnMode() {
        buttonContainer.isUserInteractionEnabled = true
        shouldApplyGradient = true
        buttonContainer.do { make in
            make.backgroundColor = UIColor.accentGrey
            make.layer.cornerRadius = 12
            make.isUserInteractionEnabled = false
        }

        titleLabel.do { make in
            make.text = L.toCreate()
            make.textColor = UIColor.labelsPrimaryInverted
            make.font = UIFont.CustomFont.bodySemibold
            make.isUserInteractionEnabled = false
        }
        setNeedsLayout()
    }
}
