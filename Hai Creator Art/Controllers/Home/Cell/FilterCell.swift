import AVFoundation
import UIKit

final class FilterCell: UICollectionViewCell {
    static let identifier = "FilterCell"

    private var filter: Filter?

    private let videoView = UIView()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var effectLabel = UILabel()
    private let underView = UIView()
    private var isVideoPlaying = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        underView.do { make in
            make.backgroundColor = UIColor.bgDim
            make.layer.masksToBounds = true
        }

        effectLabel.do { make in
            make.font = UIFont.CustomFont.bodySemibold
            make.textAlignment = .center
            make.textColor = UIColor.labelsPrimary
        }

        underView.addSubviews(effectLabel)
        contentView.addSubview(videoView)
        contentView.addSubview(underView)

        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        underView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(46)
        }

        effectLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
    }

    func configure(with filter: Filter) {
        self.filter = filter
        effectLabel.text = filter.title
        if !isVideoPlaying {
            setupVideo(for: filter)
        }
    }

    private func setupVideo(for filter: Filter) {
        guard let videoURL = CacheManager.shared.loadVideoURLFromCache(fileName: "\(filter.id)_preview.mp4") else {
            return
        }
        playVideo(from: videoURL)
    }

    private func playVideo(from url: URL) {
        guard !isVideoPlaying else {
            return
        }

        if player == nil {
            player = AVPlayer(url: url)
        }
        player?.volume = 0
        if playerLayer == nil {
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            DispatchQueue.main.async { [weak self] in
                self?.playerLayer?.frame = self?.videoView.bounds ?? CGRect.zero
                if self?.playerLayer?.superlayer == nil {
                    self?.videoView.layer.addSublayer(self?.playerLayer ?? CALayer())
                }
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(restartVideo),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        player?.play()
    }

    @objc private func restartVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async { [weak self] in
            self?.playerLayer?.frame = self?.videoView.bounds ?? CGRect.zero
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        isVideoPlaying = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
}
