import SnapKit
import UIKit

final class EmptyHistoryView: UIControl {
    private let emptyHistoryImage = UIImageView()
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()

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
        emptyHistoryImage.image = R.image.history_empty_icon()

        firstLabel.do { make in
            make.text = L.emptyHere()
            make.font = UIFont.CustomFont.title3Semibold
            make.textAlignment = .center
            make.textColor = UIColor.labelsPrimary
            make.numberOfLines = 0
        }

        secondLabel.do { make in
            make.text = L.createFirstGeneration()
            make.font = UIFont.CustomFont.footnoteRegular
            make.textAlignment = .center
            make.textColor = UIColor.labelsScondary
            make.numberOfLines = 0
        }

        addSubviews(emptyHistoryImage, firstLabel, secondLabel)
    }

    private func setupConstraints() {
        emptyHistoryImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(64)
        }

        firstLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyHistoryImage.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(25)
        }

        secondLabel.snp.makeConstraints { make in
            make.top.equalTo(firstLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }
}
