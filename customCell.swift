import Foundation
import UIKit
class customCell: UITableViewCell
{
    @IBOutlet weak var busSlotA: UIView!
    @IBOutlet weak var busSlotB: UIView!
    @IBOutlet weak var busNameA: UILabel!
    @IBOutlet weak var busNameB: UILabel!
    var pointer = 0
}
enum busTendancy
{
    case Null
    case Occupied
    case Present
}
