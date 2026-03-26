import UIKit
import Firebase

class NewSaveVC: UIViewController {
        
    
    @IBAction func saveNewEntry(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBOutlet weak var tableViewJars: UITableView!
    
    var jars: [String] = ["vacations", "car", "savings", "other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
}
