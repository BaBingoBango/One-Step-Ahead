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
                NavigationLink(destination: LicensingDetailView(assetTitle: "Dun Dun Dun Sound Effect", assetType: .soundEffect, assetCatalogName: "", sourceTitle: "Freesound", sourceLink: "https://freesound.org/people/copyc4t/sounds/146434/", licenseTitle: "Creative Commons Attribution 4.0 International", licenseLink: "https://creativecommons.org/licenses/by/4.0/")) {
                    HStack { Image(systemName: "music.note").imageScale(.large); Text("Dun Dun Dun Sound Effect") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "Game Victory Jingle", assetType: .soundEffect, assetCatalogName: "", sourceTitle: "Free Music Archive", sourceLink: "http://freemusicarchive.org/", licenseTitle: "Attribution-NonCommercial-NoDerivs 3.0 Unported", licenseLink: "https://creativecommons.org/licenses/by-nc-nd/3.0/")) {
                    HStack { Image(systemName: "music.note").imageScale(.large); Text("Game Victory Jingle") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "Game Defeat Jingle", assetType: .soundEffect, assetCatalogName: "", sourceTitle: "Free Music Archive", sourceLink: "http://freemusicarchive.org/", licenseTitle: "Attribution-NonCommercial-NoDerivs 3.0 Unported", licenseLink: "https://creativecommons.org/licenses/by-nc-nd/3.0/")) {
                    HStack { Image(systemName: "music.note").imageScale(.large); Text("Game Defeat Jingle") }
                }
            }
            
            Section(header: Text("Assets")) {
                NavigationLink(destination: LicensingDetailView(assetTitle: "Google Quick, Draw! Dataset", assetType: .drawingDataset, assetCatalogName: "", sourceTitle: "Google", sourceLink: "https://quickdraw.withgoogle.com/data", licenseTitle: "Creative Commons Attribution 4.0 International", licenseLink: "https://creativecommons.org/licenses/by/4.0/")) {
                    HStack { Image(systemName: "scribble.variable").imageScale(.large); Text("Google Quick, Draw! Dataset") }
                }
            }
            
            Section(header: Text("Software")) {
                NavigationLink(destination: LicensingDetailView(assetTitle: "MKiCloudSync", assetType: .software, assetCatalogName: "", sourceTitle: "Steinlogic", sourceLink: "https://github.com/MugunthKumar/MKiCloudSync", licenseTitle: "Custom License", licenseLink: "https://github.com/MugunthKumar/MKiCloudSync")) {
                    HStack { Image(systemName: "curlybraces").imageScale(.large); Text("MKiCloudSync") }
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
