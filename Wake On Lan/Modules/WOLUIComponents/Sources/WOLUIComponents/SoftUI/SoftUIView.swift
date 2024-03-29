//
//  SoftUIView.swift
//

import SharedExtensions
import SharedProtocolsAndModels
import UIKit
import WOLResources

public protocol ConfigurableSoftUIView: UIControl {
    func configure(with model: DescribesSoftUIViewModel)
}

public class SoftUIView: UIControl {

    // MARK: - Appearance

    private let appearance = Appearance(); struct Appearance {
        var mainColor: CGColor { Asset.Colors.primary.color.resolved }
        var darkShadowColor: CGColor { Asset.Colors.darkShadow.color.resolved }
        var lightShadowColor: CGColor { Asset.Colors.lightShadow.color.resolved }

        let shadowOffset = CGSize(width: 2, height: 2)
        let shadowRadius = CGFloat(2)
        let cornerRadius = CGFloat(15)
    }

    // MARK: - Properties

    open var type: SoftUIViewType = .pushButton {
        didSet { updateShadowLayers() }
    }

    lazy var mainColor = appearance.mainColor {
        didSet {
            backgroundLayer.backgroundColor = mainColor
            darkOuterShadowLayer.fillColor = mainColor
            lightOuterShadowLayer.fillColor = mainColor
            darkInnerShadowLayer.fillColor = mainColor
            lightInnerShadowLayer.fillColor = mainColor
        }
    }

    lazy var darkShadowColor = appearance.darkShadowColor {
        didSet {
            darkOuterShadowLayer.shadowColor = darkShadowColor
            darkInnerShadowLayer.shadowColor = darkShadowColor
        }
    }

    lazy var lightShadowColor = appearance.lightShadowColor {
        didSet {
            lightOuterShadowLayer.shadowColor = lightShadowColor
            lightInnerShadowLayer.shadowColor = lightShadowColor
        }
    }

    lazy var shadowOffset = appearance.shadowOffset {
        didSet {
            darkOuterShadowLayer.shadowOffset = shadowOffset
            lightOuterShadowLayer.shadowOffset = shadowOffset.inversed
            darkInnerShadowLayer.shadowOffset = shadowOffset
            lightInnerShadowLayer.shadowOffset = shadowOffset.inversed
        }
    }

    lazy var cornerRadius: CGFloat = appearance.cornerRadius {
        didSet { updateSublayersShape() }
    }

    lazy var shadowRadius = appearance.shadowRadius {
        didSet {
            darkOuterShadowLayer.shadowRadius = shadowRadius
            lightOuterShadowLayer.shadowRadius = shadowRadius
            darkInnerShadowLayer.shadowRadius = shadowRadius
            lightInnerShadowLayer.shadowRadius = shadowRadius
        }
    }

    private var circleShape = false

    private let feedbackGenerator: GeneratesImpactFeedback

    // MARK: - Layers

    private lazy var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.frame = bounds
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = mainColor

        return layer
    }()

    private lazy var darkOuterShadowLayer: CAShapeLayer = {
        makeOuterShadowLayer(shadowColor: darkShadowColor, shadowOffset: shadowOffset)
    }()

    private lazy var lightOuterShadowLayer: CAShapeLayer = {
        makeOuterShadowLayer(shadowColor: lightShadowColor, shadowOffset: shadowOffset.inversed)
    }()

    private lazy var darkInnerShadowLayer: CAShapeLayer = {
        let layer = makeInnerShadowLayer(shadowColor: darkShadowColor, shadowOffset: shadowOffset)
        layer.isHidden = true
        return layer
    }()

    private lazy var lightInnerShadowLayer: CAShapeLayer = {
        let layer = makeInnerShadowLayer(shadowColor: lightShadowColor, shadowOffset: shadowOffset.inversed)
        layer.isHidden = true
        return layer
    }()

    private var contentView: UIView?
    private var selectedContentView: UIView?
    private var selectedTransform: CGAffineTransform?

    // MARK: - Init

    public init(
        frame: CGRect = .zero,
        feedbackGenerator: GeneratesImpactFeedback = UIImpactFeedbackGenerator(style: .medium)
    ) {
        self.feedbackGenerator = feedbackGenerator
        super.init(frame: frame)
        addSublayers()
        updateSublayersShape()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public convenience init(circleShape: Bool) {
        self.init(frame: .zero)
        self.circleShape = circleShape
    }

    // MARK: - Override

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if
            #available(iOS 13, *),
            traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    override public var bounds: CGRect {
        didSet { updateSublayersShape() }
    }

    override public var isSelected: Bool {
        didSet {
            updateShadowLayers()
            updateContentView()
        }
    }

    override public var backgroundColor: UIColor? {
        get { .clear }
        set { super.backgroundColor = newValue }
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch type {
        case .pushButton:
            isSelected = true
            feedbackGenerator.impactOccurred()

        case .toggleButton:
            isSelected.toggle()

        case .normal:
            break
        }
        super.touchesBegan(touches, with: event)
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .pushButton = type { isSelected = isTracking }
        super.touchesMoved(touches, with: event)
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .pushButton = type { isSelected = false }
        super.touchesEnded(touches, with: event)
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .pushButton = type { isSelected = false }
        super.touchesCancelled(touches, with: event)
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if circleShape { cornerRadius = bounds.height / 2 }
    }

}

// MARK: - ConfigurableSoftUIView

extension SoftUIView: ConfigurableSoftUIView {

    public func configure(with model: DescribesSoftUIViewModel) {
        contentView.map { $0.transform = model.selectedTransform ?? .identity }
        [contentView, selectedContentView].compactMap { $0 }.forEach {
            $0.removeFromSuperview()
        }

        [model.contentView, model.selectedContentView].compactMap { $0 }.forEach {
            $0.isUserInteractionEnabled = false
            addSubview($0)
        }

        contentView = model.contentView
        selectedContentView = model.selectedContentView
        selectedTransform = model.selectedTransform

        updateContentView()
    }

}

// MARK: - Private

private extension SoftUIView {

    func addSublayers() {
        layer.addSublayer(lightOuterShadowLayer)
        layer.addSublayer(darkOuterShadowLayer)
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(darkInnerShadowLayer)
        layer.addSublayer(lightInnerShadowLayer)
    }

    func makeOuterShadowLayer(shadowColor: CGColor, shadowOffset: CGSize) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = mainColor
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 1.0
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shouldRasterize = true

        return layer
    }

    func makeInnerShadowLayer(shadowColor: CGColor, shadowOffset: CGSize) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = mainColor
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 1.0
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillRule = .evenOdd
        layer.shouldRasterize = true

        return layer
    }

    func makeOuterShadowPath() -> CGPath {
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    func makeInnerShadowPath() -> CGPath {
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: -100, dy: -100), cornerRadius: cornerRadius)
        path.append(.init(roundedRect: bounds, cornerRadius: cornerRadius))
        return path.cgPath
    }

    func makeInnerShadowMask() -> CALayer {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        return layer
    }

    func updateSublayersShape() {
        backgroundLayer.frame = bounds
        backgroundLayer.cornerRadius = cornerRadius

        darkOuterShadowLayer.path = makeOuterShadowPath()
        lightOuterShadowLayer.path = makeOuterShadowPath()

        darkInnerShadowLayer.path = makeInnerShadowPath()
        darkInnerShadowLayer.mask = makeInnerShadowMask()

        lightInnerShadowLayer.path = makeInnerShadowPath()
        lightInnerShadowLayer.mask = makeInnerShadowMask()
    }

    func updateAppearance() {
        mainColor = appearance.mainColor

        shadowOffset = appearance.shadowOffset
        shadowRadius = appearance.shadowRadius
        cornerRadius = appearance.cornerRadius

        darkShadowColor = appearance.darkShadowColor
        lightShadowColor = appearance.lightShadowColor
    }

    func updateContentView() {
        if isSelected, selectedContentView != nil {
            contentView?.isHidden = true
            contentView?.transform = .identity
            selectedContentView?.isHidden = false
        } else if isSelected, selectedTransform != nil {
            contentView?.isHidden = false
            selectedTransform.map { contentView?.transform = $0 }
            selectedContentView?.isHidden = true
        } else {
            contentView?.isHidden = false
            contentView?.transform = .identity
            selectedContentView?.isHidden = true
        }
    }

    func updateShadowLayers() {
        [darkOuterShadowLayer, lightOuterShadowLayer].forEach { $0.isHidden = isSelected }
        [darkInnerShadowLayer, lightInnerShadowLayer].forEach { $0.isHidden = !isSelected }
    }

}
