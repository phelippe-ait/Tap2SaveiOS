import UIKit
import FirebaseAuth
import FirebaseFirestore

// Class for Jar details View Controller
class JarDetailsVC: UIViewController {
    
    var selectedJar: Jar?

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    @IBOutlet weak var jarNameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    
    // Loads the selected jar information into the detail labels.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetches information from the selected cell in Table view
        guard let jar = selectedJar else { return }
        
        jarNameLabel.text = jar.name
        balanceLabel.text = formatCurrency(jar.balance)
        goalLabel.text = formatCurrency(jar.goal)
    }
    
    // Refreshes the jar details each time this screen appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let jar = selectedJar else { return }
        
        jarNameLabel.text = jar.name
        balanceLabel.text = formatCurrency(jar.balance)
        goalLabel.text = formatCurrency(jar.goal)
    }

    // Formats a number as currency with separators, like $2,000.00.
    private func formatCurrency(_ amount: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: amount)) ?? String(format: "$%.2f", amount)
    }

}
