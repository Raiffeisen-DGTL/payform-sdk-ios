//
//  SBPView.swift
//
//
//  Created by Sergey Panov on 27.09.2022.
//

import Foundation
import UIKit

class SBPViewController: UIViewController {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.primary
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let maxDimmedAlpha: CGFloat = 0.6
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }()
    
    private lazy var contentSBP: SBPView = {
        let view = SBPView()
        view.configureView()
        return view
    }()
    
    private var containerViewHeightConstraint: NSLayoutConstraint?
    private var containerViewBottomConstraint: NSLayoutConstraint?

    private let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    private let screenHeight = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)

    private let dismissibleHeight: CGFloat = UIScreen.main.bounds.height * 0.3
    private var isKeyboardHidden: Bool = true
    
    private lazy var defaultWidth: CGFloat = {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            return screenWidth * 0.8
        } else {
            return screenWidth
        }
    }()
    
    private var defaultHeight: CGFloat {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            if (UIDevice.current.orientation.isLandscape) {
                return isKeyboardHidden ? screenWidth * 0.6 : screenWidth - 27
            } else {
                return isKeyboardHidden ? screenHeight * 0.6 : screenHeight - 120
            }
        } else {
            if (UIDevice.current.orientation.isLandscape) {
                return screenWidth - 27
            } else {
                return isKeyboardHidden ? screenHeight * 0.6 : screenHeight - 64
            }
        }
    }
    private var currentContainerHeight: CGFloat = UIScreen.main.bounds.height * 0.6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupPanGesture()
        contentSBP.closeAction = { [weak self] in
            self?.animateDismissView()
        }
        overrideUserInterfaceStyle = .light
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
        setupKeyboardObservers()
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    private func setupConstraints() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: defaultWidth),
        ])
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
        
        containerView.addSubview(contentSBP)
        contentSBP.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentSBP.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentSBP.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            contentSBP.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentSBP.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
    
    private func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    private func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        let newHeight = currentContainerHeight - translation.y
        
        switch gesture.state {
        case .changed:
            if newHeight < defaultHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            } else if newHeight > defaultHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else {
                animateContainerHeight(defaultHeight)
            }
        default:
            break
        }
    }
    
    private func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    
    func animateDismissView() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
        
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            SBPRouter.instance.dialogDissmissed()
            self.dismiss(animated: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        animateContainerHeight(defaultHeight)
    }
}

extension SBPViewController {
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc
    dynamic func keyboardWillShow(
        notification: NSNotification
    ) {
        isKeyboardHidden = false
        animateContainerHeight(defaultHeight)
    }

    @objc
    dynamic func keyboardWillHide(
        notification: NSNotification
    ) {
        isKeyboardHidden = true
        animateContainerHeight(defaultHeight)
    }
}
