//
//  BuyRamViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 16..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BuyRamViewController: BaseViewController {
    
    var flowDelegate: BuyRamFlowEventDelegate?
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var btnStake: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    fileprivate let inputForm = RamInputForm()
    
    fileprivate var account: AccountInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .white)
        title = LocalizedString.Wallet.Ram.buyram
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        btnStake.setTitle(LocalizedString.Wallet.Ram.buyram, for: .normal)
        btnHistory.setTitle(LocalizedString.Wallet.Ram.history, for: .normal)
    }
    
    private func bindActions() {
        
        btnStake.rx.singleTap
            .bind { [weak self] in
                self?.handleTransaction()
            }
            .disposed(by: bag)
        
        btnHistory.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToTx(from: nc)
            }
            .disposed(by: bag)
        
    }
    
    private func handleTransaction() {

        let quantity = Currency(balance: inputForm.quantity.value, symbol: .eos)
        let accountName = account.account
        unlockWallet(pinTarget: self, pubKey: account.pubKey)
            .flatMap { (wallet) -> Observable<JSON> in
                return RxEOSAPI.buyram(account: accountName, quantity: quantity, wallet: wallet)
            }
            .flatMap { (_) -> Observable<Void> in
                return AccountManager.shared.loadAccounts()
            }
            .subscribe(onError: { (error) in
                Log.e(error)
            })
            .disposed(by: bag)

    }
    
}

extension BuyRamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellId = ""
        if indexPath.row == 0 {
            cellId = "MyAccountCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SendMyAccountCell else { preconditionFailure() }
            let balance = Currency(balance: account.totalEOS, symbol: .eos)
            cell.configure(account: account, balance: balance)
            return cell
            
        } else {
            cellId = "RamInputFormCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? RamInputFormCell else { preconditionFailure() }
            cell.configure(account: account, inputForm: inputForm)
            return cell
        }
    }
}


class RamInputFormCell: UITableViewCell {
    @IBOutlet fileprivate weak var ramBytes: UILabel!
    @IBOutlet fileprivate weak var txtQuantity: UITextField!
    @IBOutlet fileprivate weak var lbQuantity: UILabel!
    @IBOutlet fileprivate weak var lbWarning: UILabel!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    
    private func setupUI() {
        lbQuantity.text = LocalizedString.Wallet.Transfer.quantity
        txtQuantity.addDoneButtonToKeyboard(myAction: #selector(self.txtQuantity.resignFirstResponder))
        lbWarning.text = LocalizedString.Wallet.Ram.warning
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    func configure(account: AccountInfo, inputForm: RamInputForm) {
        ramBytes.text = account.ramBytes.prettyPrinted + " Bytes"
        
        let bag = DisposeBag()
        txtQuantity.rx.text.orEmpty
            .subscribe(onNext: { (text) in
                inputForm.quantity.value = Double(text) ?? 0
            })
            .disposed(by: bag)
        
        self.bag = bag
    }
}

struct RamInputForm {
    let quantity = Variable<Double>(0)
}