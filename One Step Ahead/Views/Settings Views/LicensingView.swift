//
//  LicensingView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 6/10/22.
//

import SwiftUI

/// A view with information about third-party assets used in the app.
struct LicensingView: View {
    var body: some View {
        Form {
            Section(header: Text("Images")) {
                NavigationLink(destination: LicensingDetailView(assetTitle: "Blue Background Image", assetType: .image, assetCatalogName: "space background", sourceTitle: "Unsplash", sourceLink: "https://unsplash.com/photos/_0eMNseqmYk", licenseTitle: "Unsplash License", licenseLink: "https://unsplash.com/license")) {
                    HStack { Image(systemName: "photo").imageScale(.large); Text("Blue Background Image") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "Space Background Image", assetType: .image, assetCatalogName: "star background", sourceTitle: "Unsplash", sourceLink: "https://unsplash.com/photos/qVotvbsuM_c", licenseTitle: "Unsplash License", licenseLink: "https://unsplash.com/license")) {
                    HStack { Image(systemName: "photo").imageScale(.large); Text("Space Background Image") }
                }
            }
            
            Section(header: Text("Music")) {
                Button(action: {
                    // ???
                }) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Powerup\"") }
                }
                
                Button(action: {
                    // ???
                }) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"The Big Beat 80s\"") }
                }
            }
            
            Section(header: Text("Sound Effects")) {
                Button(action: {
                    // ???
                }) {
                    HStack { Image(systemName: "music.note").imageScale(.large); Text("Dun Dun Dun Sound Effect") }
                }
                
                Button(action: {
                    // ???
                }) {
                    HStack { Image(systemName: "music.note").imageScale(.large); Text("Game Win Jingle") }
                }
                
                Button(action: {
                    // ???
                }) {
                    HStack { Image(systemName: "music.note").imageScale(.large); Text("Game Defeat Jingle") }
                }
            }
            
            Section(header: Text("Assets")) {
                Button(action: {
                    // ???
                }) {
                    HStack { Image(systemName: "scribble").imageScale(.large); Text("Google Quick, Draw! Dataset") }
                }
            }
        }
        
        // MARK: Navigation View Settings
        .navigationTitle("Licensing and Credit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LicensingView_Previews: PreviewProvider {
    static var previews: some View {
        LicensingView()
    }
}
