import UIKit
import FirebaseAuth
import FirebaseFirestore

// Class for Jar details View Controller
class JarDetailsVC: UIViewController {
    
    var selectedJar: Jar?
    
    @IBOutlet weak var jarNameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetches information from the selected cell in Table view
        guard let jar = selectedJar else { return }
        
        jarNameLabel.text = jar.name
        balanceLabel.text = String(format: "$%.2f", jar.balance)
        goalLabel.text = String(format: "$%.2f", jar.goal)
    }

}
