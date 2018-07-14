//
//  MainTabViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class MainTabViewController: TabBarViewController {
  
    var flowDelegate: MainTabFlowEventDelegate?
    
    let accountMgr = AccountManager.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if accountMgr.needPinConfirm {
            view.isUserInteractionEnabled = false
            checkPin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        setupMenus()
    }
    
    private func bindActions() {
        menuTabBar.selected
            .bind { [weak self](menu) in
                guard let strongSelf = self, let menu = menu as? MainMenu else { return }
                strongSelf.flowDelegate?.go(from: strongSelf, to: menu, animated: true)
            }
            .disposed(by: bag)
        
        AccountManager.shared.pinValidated
            .subscribe(onNext:{ [weak self](_) in
                self?.view.isUserInteractionEnabled = true
            })
            .disposed(by: bag)
    }
    
    private func setupMenus() {
        menuTabBar.configure(menus: [MainMenu.wallet, MainMenu.vote, MainMenu.airdrop])
        menuTabBar.selectMenu(menu: MainMenu.wallet)
    }
    
    private func checkPin() {
        guard let nc = navigationController else { return }
        if self.isCreatedPin() == false {
           flowDelegate?.cratePin(from: nc)
        } else {
           flowDelegate?.validatePin(from: nc)
        }
    }
    
    private func isCreatedPin() -> Bool {
        return Security.shared.hasPin()
    }
}