//
//  MenuButtonTableCell.swift
//  AboutScreen
//
//  Created by Vladislav Lisianskii on 23.05.2021.
//  Copyright © 2021 Владислав Лисянский. All rights reserved.
//

import SnapKit
import UIKit
import WOLResources
import WOLUIComponents

final class MenuButtonTableCell: UITableViewCell {

    // MARK: - Properties

    private lazy var buttonBodyView: SoftUIView = {
        let view = SoftUIView()
        view.configure(with: SoftUIViewModel(contentView: buttonContentView))
        view.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return view
    }()

    private lazy var buttonContentView: UIView = {
        let view = UIView()
        view.addSubview(buttonImageView)
        view.addSubview(buttonTitleLabel)
        return view
    }()

    private lazy var buttonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Asset.Colors.lightGray.color
        return imageView
    }()

    private lazy var buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = Asset.Colors.lightGray.color
        return label
    }()

    private var action: (() -> Void)?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = Asset.Colors.soft.color
        addSubviews()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override

    override func prepareForReuse() {
        super.prepareForReuse()
        action = nil
    }
}

// MARK: - Internal methods

extension MenuButtonTableCell {
    func configure(with model: MenuButtonCellViewModel) {
        buttonImageView.image = UIImage(sfSymbol: model.symbol, withConfiguration: .init(weight: .semibold))
        buttonTitleLabel.text = model.title
        self.action = model.action
    }
}

// MARK: - Private methods

private extension MenuButtonTableCell {
    func addSubviews() {
        contentView.addSubview(buttonBodyView)
    }

    func makeConstraints() {
        buttonBodyView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }

        buttonContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        buttonImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        buttonTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(buttonImageView.snp.trailing).offset(8)
            make.top.bottom.trailing.equalToSuperview()
        }

        buttonImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    @objc func buttonPressed() {
        action?()
    }
}