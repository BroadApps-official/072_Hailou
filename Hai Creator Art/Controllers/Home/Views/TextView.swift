import SnapKit
import UIKit

protocol TextViewDelegate: AnyObject {
    func didTapTextField(type: TextView.TextType)
    func didTapCopyButton()
}

final class TextView: UIControl {
    enum TextType {
        case promt
        case description

        var placeholder: String {
            switch self {
            case .promt: return "Enter here a detailed description of what you want to see in your video"
            case .description: return ""
            }
        }

        var title: String? {
            switch self {
            case .promt, .description: return nil
            }
        }
    }

    private let type: TextType
    weak var delegate: TextViewDelegate?

    let textField = UITextField()
    let textView = UITextView()
    let placeholderLabel = UILabel()
    let deleteButton = UIButton()
    let copyButton = UIButton()

    init(type: TextType) {
        self.type = type
        super.init(frame: .zero)
        backgroundColor = .clear
        drawSelf()
        setupConstraints()
        configureButtonActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        backgroundColor = UIColor.bgTertiary
        layer.cornerRadius = 12
        
        switch type {
        case .promt:
            setupPromptView()
        case .description:
            setupDescriptionView()
        }
    }

    private func setupPromptView() {
        deleteButton.configure {
            $0.backgroundColor = UIColor.accentPrimaryAlpha
            $0.setImage(UIImage(named: "delete_icon"), for: .normal)
            $0.setTitle("Delete", for: .normal)
            $0.setTitleColor(UIColor.labelsPrimary, for: .normal)
            $0.titleLabel?.font = UIFont.CustomFont.footnoteSemibold
            $0.layer.cornerRadius = 12
            $0.isHidden = true
            $0.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        }

        textView.configure {
            $0.font = UIFont.CustomFont.bodyRegular
            $0.textColor = UIColor.labelsPrimary
            $0.textAlignment = .left
            $0.backgroundColor = .clear
            $0.delegate = self
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }

        placeholderLabel.configure {
            $0.text = type.placeholder
            $0.font = UIFont.CustomFont.bodyRegular
            $0.textColor = UIColor.labelsQuaternary
            $0.isHidden = !textView.text.isEmpty
            $0.numberOfLines = 0
        }

        addSubviews(textView, placeholderLabel, deleteButton)
    }

    private func setupDescriptionView() {
        textView.configure {
            $0.font = UIFont.CustomFont.bodyRegular
            $0.textColor = UIColor.labelsPrimary
            $0.textAlignment = .left
            $0.backgroundColor = .clear
            $0.delegate = self
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.isEditable = false
            $0.isUserInteractionEnabled = false
        }

        copyButton.configure {
            $0.backgroundColor = UIColor.accentPrimaryAlpha
            $0.setTitle("Copy", for: .normal)
            $0.setTitleColor(UIColor.labelsPrimary, for: .normal)
            $0.titleLabel?.font = UIFont.CustomFont.footnoteSemibold
            $0.layer.cornerRadius = 12
            $0.addTarget(self, action: #selector(didTapCopyButton), for: .touchUpInside)
        }

        addSubviews(textView, copyButton)
    }

    private func setupConstraints() {
        textView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(7)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        switch type {
        case .promt:
            placeholderLabel.snp.makeConstraints {
                $0.top.equalTo(textView.snp.top).offset(7)
                $0.leading.equalTo(textView.snp.leading).offset(5)
                $0.trailing.equalTo(textView.snp.trailing).offset(-16)
            }

            deleteButton.snp.makeConstraints {
                $0.bottom.trailing.equalToSuperview().inset(16)
                $0.height.equalTo(34)
                $0.width.equalTo(89)
            }

        case .description:
            copyButton.snp.makeConstraints {
                $0.bottom.trailing.equalToSuperview().inset(16)
                $0.height.equalTo(34)
                $0.width.equalTo(61)
            }
        }
    }

    private func configureButtonActions() {
        textView.delegate = self
        textView.isEditable = true
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChangeNotification(_:)), name: UITextView.textDidChangeNotification, object: textView)
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        addTarget(self, action: #selector(didTapButton), for: .touchUpOutside)

        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private func updateButtonVisibility() {
        deleteButton.isHidden = textView.text.isEmpty
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.didTapTextField(type: type)
        updateButtonVisibility()
    }

    @objc private func didTapButton() {
        delegate?.didTapTextField(type: type)
    }

    @objc private func textViewDidChangeNotification(_ notification: Notification) {
        if let textView = notification.object as? UITextView {
            placeholderLabel.isHidden = !textView.text.isEmpty
            delegate?.didTapTextField(type: type)
            updateButtonVisibility()
        }
    }

    @objc private func didTapDeleteButton() {
        textView.text = ""
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.didTapTextField(type: type)
        updateButtonVisibility()
    }

    @objc private func didTapCopyButton() {
        UIPasteboard.general.string = textView.text
        delegate?.didTapCopyButton()
    }
}

// MARK: - UITextViewDelegate
extension TextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.didTapTextField(type: type)
    }
}

// MARK: - UIButton and UILabel Extensions
private extension UIButton {
    func configure(_ configure: (UIButton) -> Void) {
        configure(self)
    }
}

private extension UILabel {
    func configure(_ configure: (UILabel) -> Void) {
        configure(self)
    }
}

private extension UITextView {
    func configure(_ configure: (UITextView) -> Void) {
        configure(self)
    }
}
