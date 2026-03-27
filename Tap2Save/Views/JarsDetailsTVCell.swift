

import UIKit
import FirebaseAuth
import FirebaseFirestore


class JarsDetailsTVCell: UITableViewCell {
    
    
    @IBOutlet weak var jarIcon: UIImageView!
    @IBOutlet weak var jarNameLabel: UILabel!
    
    
    func configure(with jar: Jar) {
        
        jarNameLabel.text = jar.name
       }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
