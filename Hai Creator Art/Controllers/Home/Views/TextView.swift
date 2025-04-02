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
            case .promt: L.enterPromt()
            case .description: ""
            }
        }

        var title: String? {
            switch self {
            case .promt: return nil
            case .description: return nil
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
        if type == .promt {
            backgroundColor = UIColor.bgTertiary
            layer.cornerRadius = 12

            deleteButton.do { make in
                make.backgroundColor = UIColor.accentPrimaryAlpha
                make.setImage(R.image.delete_icon(), for: .normal)
                make.setTitle(L.delete(), for: .normal)
                make.setTitleColor(UIColor.labelsPrimary, for: .normal)
                make.titleLabel?.font = UIFont.CustomFont.footnoteSemibold
                make.layer.cornerRadius = 12
                make.isHidden = true
                make.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
            }

            textView.do { make in
                make.font = UIFont.CustomFont.bodyRegular
                make.textColor = UIColor.labelsPrimary
                make.textAlignment = .left
                make.backgroundColor = .clear
                make.delegate = self
                make.showsVerticalScrollIndicator = false
                make.showsHorizontalScrollIndicator = false
            }

            placeholderLabel.do { make in
                make.text = type.placeholder
                make.font = UIFont.CustomFont.bodyRegular
                make.textColor = UIColor.labelsQuaternary
                make.isHidden = !textView.text.isEmpty
                make.numberOfLines = 0
            }

            addSubviews(textView, placeholderLabel, deleteButton)
        } else if type == .description {
            backgroundColor = UIColor.bgTertiary
            layer.cornerRadius = 12

            textView.do { make in
                make.font = UIFont.CustomFont.bodyRegular
                make.textColor = UIColor.labelsPrimary
                make.textAlignment = .left
                make.backgroundColor = .clear
                make.delegate = self
                make.showsVerticalScrollIndicator = false
                make.showsHorizontalScrollIndicator = false
                make.isEditable = false
                make.isUserInteractionEnabled = false
            }

            copyButton.do { make in
                make.backgroundColor = UIColor.accentPrimaryAlpha
                make.setTitle(L.copy(), for: .normal)
                make.setTitleColor(UIColor.labelsPrimary, for: .normal)
                make.titleLabel?.font = UIFont.CustomFont.footnoteSemibold
                make.layer.cornerRadius = 12
                make.addTarget(self, action: #selector(didTapCopyButton), for: .touchUpInside)
            }

            addSubviews(textView, copyButton)
        }
    }

    private func setupConstraints() {
        if type == .promt {
            textView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(7)
                make.leading.trailing.equalToSuperview().inset(10)
            }

            placeholderLabel.snp.makeConstraints { make in
                make.top.equalTo(textView.snp.top).offset(7)
                make.leading.equalTo(textView.snp.leading).offset(5)
                make.trailing.equalTo(textView.snp.trailing).offset(-16)
            }

            deleteButton.snp.makeConstraints { make in
                make.bottom.trailing.equalToSuperview().inset(16)
                make.height.equalTo(34)
                make.width.equalTo(89)
            }
        } else if type == .description {
            textView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(7)
                make.leading.trailing.equalToSuperview().inset(10)
            }

            copyButton.snp.makeConstraints { make in
                make.bottom.trailing.equalToSuperview().inset(16)
                make.height.equalTo(34)
                make.width.equalTo(61)
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
        let hasText = !textView.text.isEmpty
        deleteButton.isHidden = !hasText
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
