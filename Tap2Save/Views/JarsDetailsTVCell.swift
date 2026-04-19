

import UIKit
import FirebaseAuth
import FirebaseFirestore

// Class to manager Jars table view
class JarsDetailsTVCell: UITableViewCell {
    
    
    @IBOutlet weak var jarNameLabel: UILabel!
    
    // Gives the cell a jar name 
    // Displays the jar name inside the table view cell.
    func configure(with jar: Jar) {
        
        jarNameLabel.text = jar.name
       }

}
