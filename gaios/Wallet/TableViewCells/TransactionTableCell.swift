import Foundation
import UIKit

class TransactionTableCell: UITableViewCell {

    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var bumpFee: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setup(with transaction: Transaction) {
        let isLiquid = getGdkNetwork(getNetwork()).liquid
        bumpFee.isHidden = !transaction.canRBF || isLiquid
        amount.text = transaction.amount()
        selectionStyle = .none
        date.text = transaction.date()
        let asset = transaction.amounts.filter { $0.key != "btc" }.first
        if !transaction.memo.isEmpty {
            address.text = transaction.memo
        } else if isLiquid, asset != nil {
            address.text = asset!.key
        } else if transaction.type == "redeposit" {
            address.text = NSLocalizedString("id_redeposited", comment: String())
        } else if transaction.type == "incoming" {
            address.text = NSLocalizedString("id_received", comment: String())
        } else if isLiquid {
            address.text = ""
        } else {
            address.text = transaction.address()
        }
    }

    func checkBlockHeight(transaction: Transaction, blockHeight: UInt32) {
        let isLiquid = getGdkNetwork(getNetwork()).liquid
        if transaction.blockHeight == 0 {
            status.text = NSLocalizedString("id_unconfirmed", comment: "")
            status.textColor = UIColor.errorRed()
        } else if isLiquid && blockHeight < transaction.blockHeight + 1 {
            status.textColor = UIColor.customTitaniumLight()
            status.text = NSLocalizedString("id_12_confirmations", comment: "")
        } else if !isLiquid && blockHeight < transaction.blockHeight + 5 {
            let confirmCount = blockHeight - transaction.blockHeight + 1
            status.textColor = UIColor.customTitaniumLight()
            status.text = String(format: NSLocalizedString("id_d6_confirmations", comment: ""), confirmCount)
        } else {
            status.text = NSLocalizedString("id_completed", comment: "")
            status.textColor = UIColor.customTitaniumLight()
        }
    }

    func checkTransactionType(transaction: Transaction) {
        if transaction.type == "incoming" {
            amount.textColor = UIColor.customMatrixGreen()
        } else {
            amount.textColor = UIColor.white
        }
    }
}
