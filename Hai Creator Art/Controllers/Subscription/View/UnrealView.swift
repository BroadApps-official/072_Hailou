
import SnapKit
import UIKit

final class UnrealView: UIControl {
    private let mainLabel = UILabel()
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let thirdLabel = UILabel()
    private let firstImageView = UIImageView()
    private let secondImageView = UIImageView()
    private let thirdImageView = UIImageView()
    private let firstStackView = UIStackView()
    private let secondStackView = UIStackView()
    private let thirdStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        backgroundColor = .clear
        [firstImageView, secondImageView, thirdImageView].forEach { imageView in
            imageView.do { make in
                make.image = R.image.sub_unreal_icon()
            }
        }

        [firstStackView, secondStackView, thirdStackView].forEach { stackView in
            stackView.do { make in
                make.axis = .horizontal
                make.spacing = 2
                make.alignment = .leading
            }
        }

        [firstLabel, secondLabel, thirdLabel].forEach { label in
            label.do { make in
                make.font = UIFont.CustomFont.subheadlineRegular
                make.textColor = UIColor.labelsPrimary
                make.textAlignment = .center
            }
        }
        firstLabel.text = L.unrealFirstLabel()
        secondLabel.text = L.unrealSecondLabel()
        thirdLabel.text = L.unrealThirdLabel()

        mainLabel.do { make in
            make.text = L.unrealMainLabel()
            make.textColor = UIColor.labelsPrimary
            make.numberOfLines = 0
            make.textAlignment = .center
            make.font = UIFont.CustomFont.title1Bold
        }

        firstStackView.addArrangedSubviews([firstImageView, firstLabel])
        secondStackView.addArrangedSubviews([secondImageView, secondLabel])
        thirdStackView.addArrangedSubviews([thirdImageView, thirdLabel])
        addSubviews(mainLabel, firstStackView, secondStackView, thirdStackView)
    }

    private func setupConstraints() {
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        firstStackView.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        secondStackView.snp.makeConstraints { make in
            make.top.equalTo(firstStackView.snp.bottom).offset(4)
            make.leading.equalTo(firstStackView.snp.leading)
        }

        thirdStackView.snp.makeConstraints { make in
            make.top.equalTo(secondStackView.snp.bottom).offset(4)
            make.leading.equalTo(firstStackView.snp.leading)
        }
    }
}
