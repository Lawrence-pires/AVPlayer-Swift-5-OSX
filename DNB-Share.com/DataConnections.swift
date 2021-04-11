//
//  DataConverter.swift
//  DNB-Share.com
//
//  Created by M1 on 17/03/2021.
//

import Foundation
//make request to URL and return Data

var httpArray: [String] = []
var minutesArray: [String] = []



class DataConnections: NSObject {

func makeHTTPRequest(url: URL, httpCompletionHandler: @escaping(String?, Error?) -> Void) {

    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    
        if let error = error { self.handleErrors(error: error) }
        guard let data = data else { return }

        let returnedContent = String(data: data, encoding: .utf8)!
 
        httpCompletionHandler(returnedContent, nil)
        
        }
    
        task.resume()
    }
    


    func createPlayList(data: String, dataCompletionHandler: @escaping([[String:String]]) -> Void) {
    
   
        let getData = data.withoutHtml
    //print(content)
    var array =  getData.components(separatedBy: " ") //not ideal we need to find the https and mins strings

    httpArray = array.filter( { $0.range(of: "https", options: .caseInsensitive) != nil })
    minutesArray = array.filter( { $0.range(of: "mins", options: .caseInsensitive) != nil })
    array.removeAll(); httpArray.removeFirst()
    

    var index = 0
    
    for items in httpArray {
   
        var audioTItle =  URL(string: items)!.lastPathComponent
        audioTItle = (audioTItle as NSString).substring(to: (audioTItle as NSString).length-9)
        audioTItle = audioTItle.replacingOccurrences(of: "_", with: " ", options: NSString.CompareOptions.literal, range: nil)
     
        let getMins = minutesArray[index].replacingOccurrences(of: "mins", with: "", options: NSString.CompareOptions.literal, range: nil)
        let removeStrings = getMins.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        let convertMins = Int(removeStrings)! * 60
        let convertBackToString = formatTimeString(Double(convertMins))
        
        tableDataReady.append(["MusicTitle": audioTItle, "Duration": convertBackToString, "Link": items])
        index = index + 1
        }
        minutesArray.removeAll(); httpArray.removeAll()
        dataCompletionHandler(tableDataReady)
    
}
   
    func createHttpsToPlayAudio(data: String, url: URL, CreateHttpsToPlayAudioCompletionHandler: @escaping(URL?, Error?) -> Void) {
  
        var array =  data.components(separatedBy: " ")
        var valueArray = array.filter( { $0.range(of: "value", options: .caseInsensitive) != nil })
        array.removeAll()
        
        var createLinkToPlay: [String] = []
        
        for item in valueArray {
            
            
            let findValueReplace = item.replacingOccurrences(of: "value=\"", with: "", options: NSString.CompareOptions.literal, range: nil)
            let removeBackslash = findValueReplace.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
            
            
            createLinkToPlay.append(removeBackslash)
        }
        let ready = URL(string: "\(url)?file=\(createLinkToPlay[0])&payload=\(createLinkToPlay[1])&play=1")
        valueArray.removeAll(); createLinkToPlay.removeAll()
        CreateHttpsToPlayAudioCompletionHandler(ready, nil)
        
        
    }
    
    func handleErrors(error: Error) {
        print(error.localizedDescription)
        Alert().showAlert(displayError: error.localizedDescription)
    }
    
    
    func formatTimeString(_ d: Double) -> String {

        let h : Int = Int(d / 3600)
        let m : Int = Int((d - Double(h) * 3600) / 60)
        let s : Int = Int(d - 3600 * Double(h)) - m * 60
        
        if Double(h) <= 1.0 {
            let str = String(format: "%01d:%02d:%02d", h, m, s)
            return str
                } else {
            
            let str = String(format: "%01d:%02d:%02d", h, m, s)
            return str
                }
    }
}

    
    


extension String {
    public var withoutHtml: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }

        return attributedString.string
    }
    

}
