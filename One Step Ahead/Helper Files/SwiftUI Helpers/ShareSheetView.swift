//
//  ShareSheetView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 7/9/22.
//

import Foundation
import SwiftUI

/// A system share sheet view which can be presented to share items.
struct ShareSheetView: UIViewControllerRepresentable {
    /// The items for the share sheet to share.
    var itemsToShare: [Any]
    /// The services with which to share the item(s).
    var servicesToShareItem: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheetView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: servicesToShareItem)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheetView>) {}
}
