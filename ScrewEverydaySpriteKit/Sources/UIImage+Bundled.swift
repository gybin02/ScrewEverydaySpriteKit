import UIKit

extension UIImage {
    static func bundled(_ name: String) -> UIImage {
        guard let path = Bundle.main.path(forResource: name, ofType: "png"),
              let img = UIImage(contentsOfFile: path) else { return UIImage() }
        return img
    }
}
