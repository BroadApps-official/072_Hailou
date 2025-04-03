import UIKit

protocol SelectImageViewDelegate: AnyObject {
    func didTapAddPhoto(sender: SelectImageView)
}

final class SelectImageView: UIControl {
    // MARK: - Properties

    let buttonContainer = UIImageView()
    private let stackView = UIStackView()
    private let plusImageView = UIImageView()
    private let plusLabel = UILabel()
    private let dashedBorderLayer = CAShapeLayer()
    weak var delegate: SelectImageViewDelegate?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddPhoto))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateDashedBorder()
    }

    // MARK: - Private methods

    private func drawSelf() {
        plusImageView.image = R.image.home_plus_image_icon()

        buttonContainer.do { make in
            make.backgroundColor = UIColor.bgTertiary
            make.layer.cornerRadius = 12
            make.isUserInteractionEnabled = true
            make.layer.borderColor = UIColor.clear.cgColor
            make.layer.borderWidth = 2
            make.layer.masksToBounds = true
        }

        stackView.do { make in
            make.axis = .vertical
            make.spacing = 10
            make.alignment = .center
            make.distribution = .fill
        }

        plusLabel.do { make in
            make.text = L.clickImage()
            make.font = UIFont.CustomFont.bodyRegular
            make.textColor = UIColor.labelsTertiary
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        stackView.addArrangedSubviews([plusImageView, plusLabel])
        buttonContainer.addSubviews(stackView)
        addSubviews(buttonContainer)

        buttonContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        plusImageView.snp.makeConstraints { make in
            make.size.equalTo(16)
        }

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }

        buttonContainer.layer.addSublayer(dashedBorderLayer)
    }

    private func updateDashedBorder() {
        dashedBorderLayer.strokeColor = UIColor.accentSecondary.cgColor
        dashedBorderLayer.lineDashPattern = [12, 12]
        dashedBorderLayer.fillColor = nil
        dashedBorderLayer.lineWidth = 2
        dashedBorderLayer.frame = buttonContainer.bounds
        dashedBorderLayer.path = UIBezierPath(roundedRect: buttonContainer.bounds, cornerRadius: 12).cgPath
    }

    @objc private func didTapAddPhoto() {
        delegate?.didTapAddPhoto(sender: self)
    }

    func addImage(image: UIImage) {
        buttonContainer.image = image
        stackView.isHidden = true
        buttonContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAddPhoto)))
    }
}
