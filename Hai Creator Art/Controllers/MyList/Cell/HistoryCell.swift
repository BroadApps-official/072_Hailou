import AVFoundation
import UIKit

final class HistoryCell: UICollectionViewCell {
    static let identifier = "HistoryCell"
    private var model: GeneratedVideo?

    private let imageView = UIImageView()
    private let generationLabel = UILabel()
    private let generationActivityIndicator = UIActivityIndicatorView(style: .large)

    private var nameLabel = UILabel()
    private let underView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.bgTertiary
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        imageView.do { make in
            make.layer.cornerRadius = 8
            make.masksToBounds = true
        }

        generationLabel.do { make in
            make.text = "Generation usually takes about a minute"
            make.font = UIFont.CustomFont.calloutRegular
            make.textAlignment = .center
            make.textColor = UIColor.labelsPrimary
            make.numberOfLines = 0
        }

        underView.do { make in
            make.backgroundColor = UIColor.bgDim
            make.layer.masksToBounds = true
        }

        nameLabel.do { make in
            make.font = UIFont.CustomFont.bodySemibold
            make.textAlignment = .center
            make.textColor = UIColor.labelsPrimary
        }

        generationActivityIndicator.tintColor = .white

        contentView.addSubview(imageView)
        contentView.addSubview(generationLabel)
        contentView.addSubview(generationActivityIndicator)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        generationActivityIndicator.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.centerX.equalToSuperview()
            if UIDevice.isIphoneBelowX {
                make.top.equalToSuperview().offset(60)
            } else {
                make.top.equalToSuperview().offset(85)
            }
        }

        generationLabel.snp.makeConstraints { make in
            make.top.equalTo(generationActivityIndicator.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(215)
        }
    }

    func configure(with model: GeneratedVideo) {
        self.model = model

        if model.isFinished {
            generationActivityIndicator.isHidden = true
            generationLabel.isHidden = true
            generationActivityIndicator.stopAnimating()

            imageView.image = nil
            let videoURL = model.cacheURL

            if FileManager.default.fileExists(atPath: videoURL.path) {
                generateThumbnail(from: videoURL)
                print("Video found: \(videoURL.path)")
            } else {
                print("Video not found: \(videoURL.path)")
            }
        } else {
            generationActivityIndicator.isHidden = false
            generationLabel.isHidden = false
            generationActivityIndicator.startAnimating()

            imageView.image = UIImage(named: "ai_video_cell_placeholder")
        }

        if model.source == .api2 {
            nameLabel.text = model.name

            underView.addSubviews(nameLabel)
            contentView.addSubview(underView)

            underView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(46)
            }

            nameLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(16)
            }
        }
    }

    private func generateThumbnail(from url: URL) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 600)

        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, result, error in
            if let error = error {
                print("Thumbnail generation error: \(error)")
                return
            }

            if result == .succeeded, let image = image {
                let uiImage = UIImage(cgImage: image)
                DispatchQueue.main.async {
                    self.imageView.image = uiImage
                }
            }
        }
    }
}
