//
//  OnboardingController.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 20/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import Foundation
import UIKit

class OnboardingController: UIViewController {

    // MARK: - Properties
    
    let segueToApp = "showMainViewController"
    let screenBounds = UIScreen.main.bounds
    
    let titles = ["Pesquisar prédios", "Ativação do GPS", "Acessar Google Maps"]
    let texts = ["A pesquisa dos prédios pode ser feita por nome, departamento ou campus.", "A ativação do GPS pode ser feita para facilitar a pesquisa de prédios próximos.", "Durante a pesquisa, o Google Maps pode ser acessado diretamente para verificar o melhor trajeto"]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure UI stuff
        configureScrollView()
        configureControllers()
        configurePageControl()
        configureButtons(page: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureScrollView()
    }
    
    // MARK: - Configuration methods
    
    private func configureScrollView() {
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(titles.count), height: scrollView.frame.size.height)
        scrollView.delegate = self
    }
    
    private func configureControllers() {
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        for index in 0..<titles.count {
            
            let vc = storyboard.instantiateViewController(withIdentifier: "onboardingStepController") as! OnboardingStepController
            
            addChild(vc)
            scrollView.addSubview(vc.view)
            
            vc.didMove(toParent: self)

            vc.view.frame = CGRect(origin: CGPoint(x: screenBounds.width * CGFloat(index), y: 0), size: CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height))
            
            vc.configure(image: UIImage(named: "onboarding\(index + 1)"), title: titles[index], text: texts[index])
        }
        
    }
    
    private func configurePageControl() {

        pageControl.numberOfPages = titles.count
        pageControl.currentPage = 0
        
        pageControl.tintColor = .white
        pageControl.pageIndicatorTintColor = LayoutUtils.secondaryColor
        pageControl.currentPageIndicatorTintColor = LayoutUtils.mainColor
    
        pageControl.isUserInteractionEnabled = false
        
    }
    
    private func configureButtons(page: Int) {

        leftButton.isUserInteractionEnabled = true
        rightButton.isUserInteractionEnabled = true
        
        // se for a última página
        if page == titles.count - 1 {
            
            hideView(leftButton)
            
            rightButton.setTitle("Entendi", for: .normal)
            rightButton.removeTarget(nil, action: nil, for: .allEvents)
            rightButton.addTarget(self, action: #selector(goToApp), for: .touchUpInside)
        } else {
            
            showView(leftButton)
            
            leftButton.setTitle("Pular", for: .normal)
            leftButton.addTarget(self, action: #selector(goToApp), for: .touchUpInside)
            
            rightButton.setTitle("Próximo", for: .normal)
            rightButton.removeTarget(nil, action: nil, for: .allEvents)
            rightButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        }
        
    }
    
    // MARK: - Actions
    
    @objc func goToApp() {
        
        // save in user defaults a flag indicating that user has seen the onboarding
        let defaults = UserDefaults.standard
        
        defaults.set(false, forKey: "isFirstTime")
        defaults.synchronize()
        
        // go to main controller
        performSegue(withIdentifier: segueToApp, sender: nil)
    }
    
    @objc func nextPage() {
        let nextPage = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width)) + 1
        let newPoint = CGPoint(x: (scrollView.frame.size.width *  CGFloat(nextPage)), y: 0)
        
        scrollView.setContentOffset(newPoint, animated: true)
        didScrollTo(page: nextPage)
    }

}

// MARK: - UI Scroll View Delegate

extension OnboardingController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        leftButton.isUserInteractionEnabled = false
        rightButton.isUserInteractionEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didScrollTo(page: Int(round(scrollView.contentOffset.x / scrollView.frame.size.width)))
    }
    
    func didScrollTo(page: Int) {
        pageControl.currentPage = page
        configureButtons(page: page)
    }
    
}

// MARK: - UI Methods

extension OnboardingController {

    // MARK: - Show/Hide
    
    func showView(_ view: UIView) {
        if view.isHidden {
            view.alpha = 0.0
            view.isHidden = false
            
            UIView.animate(withDuration: 0.2) {
                view.alpha = 1.0
            }
        }
    }

    func hideView(_ view: UIView) {
        if !view.isHidden {
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 0.0
            }) { _ in
                view.isHidden = true
            }
        }
    }

}
