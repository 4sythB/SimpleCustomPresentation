//
//  MainViewController.swift
//  SimpleCustomPresentation
//
//  Created by Brad Forsyth on 3/14/18.
//  Copyright © 2018 Brad Forsyth. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var interactor: SideMenuInteractiveTransition!
    var sideMenu: SideMenuViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .lightGray
        
        self.interactor = SideMenuInteractiveTransition()
        
        self.sideMenu = SideMenuViewController.createFromStoryboard()
        self.sideMenu.transitioningDelegate = self
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let translation: CGPoint = gestureRecognizer.translation(in: self.view)
        
        let progress = SideMenuHelper.calculateProgress(translationInView: translation, viewBounds: self.view.bounds, direction: .right)
        
        SideMenuHelper.mapGestureStateToInteractor(gestureState: gestureRecognizer.state, progress: progress, interactor: self.interactor) {
            self.present(self.sideMenu, animated: true, completion: nil)
        }
    }
    
    @IBAction func showMenuButtonTapped(_ sender: Any) {
        self.present(self.sideMenu, animated: true, completion: nil)
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideMenuInterruptibleAnimator(isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideMenuInterruptibleAnimator(isPresentation: false)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactor.hasStarted ? self.interactor : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactor.hasStarted ? self.interactor : nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SideMenuPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.interactor = self.interactor
        return presentationController
    }
}
