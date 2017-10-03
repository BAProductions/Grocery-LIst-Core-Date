//
//  functions.swift

// <Grocery-LIst is a simple list appclation for ios 9.3 an above and swift 2.2 an above>
// Copyright (C) <2016>  <DJABHipHop/BAProductions>

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import UIKit
//Convert hex color to uicolor
//func hexStringToUIColor (hex:String) -> UIColor {
//    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
//    if (cString.hasPrefix("#")) {
//        cString = cString.substring(from: cString.startIndex.advanced(by: 1))
//    }
//    if ((cString.characters.count) != 6) {
//        return UIColor.gray
//    }
//    var rgbValue:UInt32 = 0
//    Scanner(string: cString).scanHexInt32scanHexInt32(&rgbValue)
//    return UIColor(
//        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//        alpha: CGFloat(1.0)
//    )
//}
//Dismiss keybard then user tuoches outside UITextField, UITextView or UISearchbar ("Experimental Code")
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
//Add background images to uiview
extension UIView {
    func addBackground(imageName:String) {
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: imageName)
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        self.addSubview(imageViewBackground)
        self.sendSubview(toBack: imageViewBackground)
    }
}
//Hides the search bar
extension UITableView {
    func hideSearchBar() {
        if let bar = self.tableHeaderView as? UISearchBar {
            let height = CGRect.init(x: 0, y: 0, width: 0, height: bar.frame.height)
            let offset = self.contentOffset.y
            if offset < height.height {
                self.contentOffset = CGPoint(x: 0, y: height.height)
            }
        }
    }
}
//Round Button
class RoundButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
//Round Label
class RoundLabel: UILabel {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
extension String {
    func localizedWithComment(comment:String) -> String {
        //print(NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment))
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    func replace(string:String, replacement:String) -> String {
        return self.replace(string: string, replacement: replacement)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "_")
    }
}
class TipInCellAnimator {
    class func fadeIn(cell:UITableViewCell) {
        let view = cell.contentView
        let rotationDegrees: CGFloat = -15.0
        let rotationRadians: CGFloat = rotationDegrees * (CGFloat(M_PI)/180.0)
        let offset = CGPoint(x: -20, y: -20)
        var startTransform = CATransform3DIdentity // 2
        startTransform = CATransform3DRotate(CATransform3DIdentity, rotationRadians, 0.0, 0.0, 1.0) // 3
        startTransform = CATransform3DTranslate(startTransform, offset.y, offset.x, 0.0) // 4
        //view.layer.transform = startTransform
        view.layer.opacity = 0.0
        UIView.animate(withDuration: 1) {
            //view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        }
    }
    class func fadeOut(cell:UITableViewCell) {
        let view = cell.contentView
        let rotationDegrees: CGFloat = -15.0
        let rotationRadians: CGFloat = rotationDegrees * (CGFloat(M_PI)/180.0)
        let offset = CGPoint(x: -20, y: -20)
        var startTransform = CATransform3DIdentity // 2
        startTransform = CATransform3DRotate(CATransform3DIdentity, rotationRadians, 0.0, 0.0, 0.0) // 3
        startTransform = CATransform3DTranslate(startTransform, offset.y, offset.x, 0.0) // 4
        //view.layer.transform = startTransform
        view.layer.opacity = 1.0
        UIView.animate(withDuration: 1) {
            //view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 0
        }
    }
    
}
//Make String UpperCase
func firstCharacterUpperCase(sentenceToCap:String) -> String {
    //break it into an array by delimiting the sentence using a space
    let breakupSentence = sentenceToCap.components(separatedBy: " ")
    var newSentence = ""
    //Loop the array and concatinate the capitalized word into a variable.
    for wordInSentence  in breakupSentence {
        newSentence = "\(newSentence) \(wordInSentence.capitalized)"
    }
    // send it back up.
    return newSentence
}
func firstCharacterLowerCase(sentenceToCap:String) -> String {
    //break it into an array by delimiting the sentence using a space
    let breakupSentence = sentenceToCap.components(separatedBy: " ")
    var newSentence = ""
    //Loop the array and concatinate the capitalized word into a variable.
    for wordInSentence  in breakupSentence {
        newSentence = "\(newSentence) \(wordInSentence.lowercased())"
    }
    // send it back up.
    return newSentence
}
func isBlank (optionalString :String?) -> Bool {
    if let string = optionalString {
        return string.isEmpty
    } else {
        return true
    }
}
//Block Number in a string
func noNumber(text: String) -> String {
//    let regex = try! NSRegularExpression(pattern: "^[0-9]+$", options: NSRegularExpression.Options.caseInsensitive)
//    let range = NSMakeRange(0, alpha.characters.count)
//    let modString = regex.stringByReplacingMatches(in: alpha, options: [], range: range, withTemplate: "xx")
//    return modString
    let alphaNumericCharacterSet = NSMutableCharacterSet() //create an empty mutable set
    alphaNumericCharacterSet.formUnion(with:CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"))
    alphaNumericCharacterSet.addCharacters(in: "?&. ")
    let filteredCharacters = text.characters.filter {
        return  String($0).rangeOfCharacter(from: alphaNumericCharacterSet as CharacterSet) != nil
    }
    let filteredString = String(filteredCharacters)
    // send it back up.
    return filteredString
}
extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    var letters: String {
        return components(separatedBy: CharacterSet.letters.inverted)
            .joined()
    }
}
//Block Emoji in a string
func noEmoji(text:String) -> String {
    let alphaNumericCharacterSet = NSMutableCharacterSet() //create an empty mutable set
    alphaNumericCharacterSet.formUnion(with: NSCharacterSet.alphanumerics)
    alphaNumericCharacterSet.addCharacters(in: "?& ")
    let filteredCharacters = text.characters.filter {
        return  String($0).rangeOfCharacter(from: alphaNumericCharacterSet as CharacterSet) != nil
    }
    let filteredString = String(filteredCharacters)
    // send it back up.
    return filteredString
}
//Block Emoji and letter in a string
func noEmojiOrLatter(text:String) -> String {
    let numericCharacterSet = NSCharacterSet(charactersIn:"0123456789/")
    let filteredCharacters = text.characters.filter {
        return  String($0).rangeOfCharacter(from: numericCharacterSet as CharacterSet) != nil
    }
    let filteredString = String(filteredCharacters)
    // send it back up.
    return filteredString
}
extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[index(startIndex, offsetBy: i)];
        }
    }
}
func isValidInput(Input:String) -> Bool {
    let myCharSet=CharacterSet(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let output: String = Input.trimmingCharacters(in: myCharSet.inverted)
    let isValid: Bool = (Input == output)
    print("\(isValid)")
    
    return isValid
}
//func stringArrayToNSData(array: [String]) -> NSData {
//    let data = NSMutableData()
//    let terminator = [0]
//    for string in array {
//        if let encodedString = string.data(using: String.Encoding.utf8) {
//            data.append(encodedString)
//            data.append(terminator, length: 1)
//        }
//        else {
//            NSLog("Cannot encode string \"\(string)\"")
//        }
//    }
//    return data
//}
extension Int {
    var stringValue:String {
        return "\(self)"
    }
}
extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

