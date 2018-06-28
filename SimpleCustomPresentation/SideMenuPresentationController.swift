//
//  SideMenuPresentationController.swift
//  SimpleCustomPresentation
//
//  Created by Brad Forsyth on 3/14/18.
//  Copyright © 2018 Bloom Built Inc. All rights reserved.
//

import UIKit


class SideMenuPresentationController: UIPresentationController {
    
    @objc var interactor: SideMenuInteractiveTransition?
    private var dimmingView: UIView!
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        self.setupDimmingView()
    }
    
    private func setupDimmingView() {
        self.dimmingView = UIView()
        self.dimmingView.translatesAutoresizingMaskIntoConstraints = false
        self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.dimmingView.alpha = 0.0
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        dimmingView.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: presentedViewController.view)
        
        let progress = SideMenuHelper.calculateProgress(translationInView: translation,
                                                        viewBounds: presentedViewController.view.bounds,
                                                        direction: .left)
        
        SideMenuHelper.mapGestureStateToInteractor(gestureState: recognizer.state, progress: progress, interactor: self.interactor) {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    override func presentationTransitionWillBegin() {
        guard let container = self.containerView else { return }
        if container.subviews.contains(self.dimmingView) == false {
            container.insertSubview(self.dimmingView, at: 0)
        }
        
        self.dimmingView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        self.dimmingView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        self.dimmingView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        self.dimmingView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.dimmingView.alpha = 1.0
            return
        }
        
        
        ///////////////////////////////////////////////////////////////
        // THIS IS THE BUG. IT IS NOT ANIMATING ALONGSIDE TRANSITION //
        // WHEN USING AN INTERRUPTIBLE ANIMATOR AND A PRESENTATION   //
        // CONTROLLER.                                               //
        ///////////////////////////////////////////////////////////////
        
        coordinator.animate(alongsideTransition: { (_) in
            self.dimmingView.alpha = 1.0
            self.presentedViewController.view.backgroundColor = .green
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        guard let coordinator = self.presentedViewController.transitionCoordinator else { return }
        
        if coordinator.isCancelled {
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.dimmingView.alpha = 0.0
            return
        }
        
        
        ///////////////////////////////////////////////////////////////
        // THIS IS THE BUG. IT IS NOT ANIMATING ALONGSIDE TRANSITION //
        // WHEN USING AN INTERRUPTIBLE ANIMATOR AND A PRESENTATION   //
        // CONTROLLER.                                               //
        ///////////////////////////////////////////////////////////////
        
        coordinator.animate(alongsideTransition: { (_) in
            self.dimmingView.alpha = 0.0
            self.presentedViewController.view.backgroundColor = .blue
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.presentingViewController.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = self.frameOfPresentedViewInContainerView
        presentingViewController.view.frame = self.frameOfPresentingViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        
        var width = parentSize.width * SideMenuHelper.menuWidth
        if width > 300 {
            width = 300
        }
        
        return CGSize(width: width, height: parentSize.height)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView?.bounds.size ?? .zero)
        frame.origin = .zero
        
        return frame
    }
    
    private var frameOfPresentingViewInContainerView: CGRect {
        var frame: CGRect = self.presentingViewController.view.frame
        frame.origin = CGPoint(x: self.frameOfPresentedViewInContainerView.size.width, y: 0)
        
        return frame
    }
}
