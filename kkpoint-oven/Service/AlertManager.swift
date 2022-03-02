//
//  AlertManager.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/09.
//

import UIKit

class AlertManager {

    class func showAlert(title: String?, message: String?,
                         oKTItle: String, cancelTitle: String?, actionClosure: @escaping () -> Void) {
        guard let topVC = Utilities.topViewController() else { return}
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: oKTItle, style: .default) { _ in
            actionClosure()
        }
        var cancelAction = UIAlertAction(title: "", style: .cancel, handler: nil)
        if cancelTitle != nil {
            cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
            alert.addAction(cancelAction)
        }
        alert.addAction(OKAction)
        topVC.present(alert, animated: false, completion: nil)
    }
    
    class func showUpdateAlert() {
        guard let topVC = Utilities.topViewController() else { return}
        let alert = UIAlertController(title: "test", message: "", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(OKAction)
        topVC.present(alert, animated: false, completion: nil)
    }
}
