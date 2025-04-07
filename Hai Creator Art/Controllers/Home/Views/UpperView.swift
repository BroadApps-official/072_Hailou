import UIKit

final class UpperView: UIControl {
    enum UpperViewType {
        case image
        case text

        var title: String {
            switch self {
            case .image: return "Image to Video"
            case .text: return "Text to Video"
            }
        }

        var image: UIImage? {
            switch self {
            case .image: return UIImage(named: "home_image_icon")
            case .text: return UIImage(named: "home_text_icon")
            }
        }
    }

    // MARK: - Properties

    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    private let type: UpperViewType
    private let titleLabel = GradientLabel()
    private let buttonContainer = UIView()
    private let imageView = UIImageView()

    // MARK: - Init

    init(type: UpperViewType, frame: CGRect = .zero) {
        self.type = type
        super.init(frame: frame)
        drawSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func drawSelf() {
        imageView.image = type.image

        buttonContainer.do { make in
            make.backgroundColor = UIColor.bgTertiary
            make.layer.cornerRadius = 12
            make.isUserInteractionEnabled = false
        }

        titleLabel.do { make in
            make.text = type.title
            make.font = UIFont.CustomFont.headlineRegular
            make.textAlignment = .left
            make.isUserInteractionEnabled = false
        }

        buttonContainer.addSubviews(titleLabel, imageView)
        addSubviews(buttonContainer)

        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
        }

        buttonContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }
}
