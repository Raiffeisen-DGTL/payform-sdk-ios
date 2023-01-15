//
//  KeyboardAwareAnimatedConstraint.swift
//  sbp_framework
//
// Copyright (c) 2022 IceRock MAG Inc. Use of this source code is governed by the Apache 2.0 license.
//

import UIKit

class KeyboardAwareAnimatedConstraint: NSLayoutConstraint {
    private var defaultConst: CGFloat = 0.0

    override func awakeFromNib() {
        super.awakeFromNib()
        setupKeyboardObservers()
        defaultConst = constant
    }

    deinit {
        removeKeyboardObservers()
    }

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
        animateWithKeyboard(notification: notification) { keyboardFrame in
            let guide = self.firstItem as? UILayoutGuide ?? self.secondItem as? UILayoutGuide
            let mainHeight = guide?.owningView?.frame.height ?? 0.0
            let safeAreaBottomInset = mainHeight - (guide?.layoutFrame.maxY ?? 0.0)
            self.constant = self.defaultConst + keyboardFrame.height - safeAreaBottomInset
        }
    }

    @objc
    dynamic func keyboardWillHide(
        notification: NSNotification
    ) {
        animateWithKeyboard(notification: notification) { _ in
            self.constant = self.defaultConst
        }
    }

    func animateWithKeyboard(
        notification: NSNotification,
        animations: ((_ keyboardFrame: CGRect) -> Void)?
    ) {
        // Extract the duration of the keyboard animation
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo![durationKey] as? Double ?? 0

        // Extract the final frame of the keyboard
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        let keyboardFrameValue = notification.userInfo![frameKey] as? NSValue

        // Extract the curve of the iOS keyboard animation
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        let curveValue = notification.userInfo![curveKey] as? Int ?? 0
        let curve = UIView.AnimationCurve(rawValue: curveValue)!

//         Create a property animator to manage the animation
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve
        ) {
            // Perform the necessary animation layout updates
            animations?(keyboardFrameValue?.cgRectValue ?? .zero)

            // Required to trigger NSLayoutConstraint changes
            // to animate
            (self.secondItem as? UIView)?.superview?.layoutIfNeeded()
            (self.firstItem as? UIView)?.superview?.layoutIfNeeded()
            (self.secondItem as? UIView)?.layoutIfNeeded()
            (self.firstItem as? UIView)?.layoutIfNeeded()
        }

        // Start the animation
        animator.startAnimation()
    }
}
