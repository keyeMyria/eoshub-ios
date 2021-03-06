//
//  CreateAccountInfoFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 11..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class CreateAccountInfoFlowController: FlowController, CreateAccountInfoFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .createAccInfo }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    fileprivate var request: CreateAccountRequest!
    
    func configure(request: CreateAccountRequest) {
        self.request = request
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: CreateAccountInfoViewController.self)
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "CreateAccountInfoViewController") as? CreateAccountInfoViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(request: request)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goGetCode(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = CreateAccountInvoiceFlowController(configure: config)
        fc.configure(request: request)
        fc.start(animated: true)
    }
}

protocol CreateAccountInfoFlowEventDelegate: FlowEventDelegate {
    func goGetCode(from nc: UINavigationController)
}
