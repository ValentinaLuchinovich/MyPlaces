//
//  TabViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 28.02.2022.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let appearanceTabBar = UITabBarAppearance()
        appearanceTabBar.configureWithOpaqueBackground()
        tabBar.scrollEdgeAppearance = appearanceTabBar
        tabBar.standardAppearance = appearanceTabBar
        tabBar.scrollEdgeAppearance?.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
        tabBar.standardAppearance.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
    }

}
