import UIKit

final class ExampleViewController: UIViewController {
    private let addLabel = UILabel()
    private let goodLabel = UILabel()
    private let goodDescriptionLabel = UILabel()
    private let badLabel = UILabel()
    private let badDescriptionLabel = UILabel()
    private let useLabel = UILabel()

    private let firstImageView = UIImageView()
    private let secondImageView = UIImageView()
    private let thirdImageView = UIImageView()
    private let fourthImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#232323")

        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        firstImageView.image = UIImage(named: "example_first_image")
        secondImageView.image = UIImage(named: "example_second_image")
        thirdImageView.image = UIImage(named: "example_third_image")
        fourthImageView.image = UIImage(named: "example_fourth_image")

        addLabel.do { make in
            make.text = "Add photo"
            make.font = UIFont.CustomFont.title3Semibold
            make.textColor = UIColor.white
            make.textAlignment = .center
        }

        [goodLabel, badLabel].forEach { label in
            label.do { make in
                make.font = UIFont.CustomFont.title3Semibold
                make.textColor = UIColor.white
                make.textAlignment = .center
            }
        }

        goodLabel.text = "Good examples"
        badLabel.text = "Bad examples"

        [goodDescriptionLabel, badDescriptionLabel].forEach { label in
            label.do { make in
                make.font = UIFont.CustomFont.footnoteRegular
                make.textColor = UIColor.labelsScondary
                make.textAlignment = .center
                make.numberOfLines = 0
            }
        }

        goodDescriptionLabel.text = "The photo was taken full-face (the man is standing straight), hands are visible."
        badDescriptionLabel.text = "Group photo, covered face, nudity, very large face, blurred face, very small face, hands not visible or covered."

        useLabel.do { make in
            make.text = "Use images where the face and hands are visible for the best result."
            make.font = UIFont.CustomFont.caption2Semibold
            make.textColor = UIColor.labelsTertiary
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(
            addLabel, goodLabel, goodDescriptionLabel,
            firstImageView, secondImageView,
            badLabel, badDescriptionLabel,
            thirdImageView, fourthImageView,
            useLabel
        )
    }

    private func setupConstraints() {
        addLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        goodLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(addLabel.snp.bottom).offset(UIDevice.isIphoneBelowX ? 10 : 28)
        }

        goodDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(goodLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        [firstImageView, secondImageView].enumerated().forEach { index, imageView in
            imageView.snp.makeConstraints { make in
                let offset: CGFloat = 16
                make.top.equalTo(goodDescriptionLabel.snp.bottom).offset(16)
                make.width.equalToSuperview().dividedBy(2).offset(-21.5)
                if index == 0 {
                    make.leading.equalToSuperview().offset(offset)
                } else {
                    make.trailing.equalToSuperview().inset(offset)
                }
            }
        }

        badLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(firstImageView.snp.bottom).offset(12)
        }

        badDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(badLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        [thirdImageView, fourthImageView].enumerated().forEach { index, imageView in
            imageView.snp.makeConstraints { make in
                let offset: CGFloat = 16
                make.top.equalTo(badDescriptionLabel.snp.bottom).offset(16)
                make.width.equalToSuperview().dividedBy(2).offset(-21.5)
                if index == 0 {
                    make.leading.equalToSuperview().offset(offset)
                } else {
                    make.trailing.equalToSuperview().inset(offset)
                }
            }
        }

        useLabel.snp.makeConstraints { make in
            make.top.equalTo(thirdImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
