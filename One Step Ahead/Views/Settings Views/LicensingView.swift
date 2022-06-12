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
                NavigationLink(destination: LicensingDetailView(assetTitle: "\"Lounge Drum and Bass\"", assetType: .music, assetCatalogName: "", sourceTitle: "Pixabay", sourceLink: "https://pixabay.com/music/drum-n-bass-lounge-drum-and-bass-108785/", licenseTitle: "Simplified Pixabay License", licenseLink: "https://pixabay.com/service/license/")) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Lounge Drum and Bass\"") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "\"Space Chillout\"", assetType: .music, assetCatalogName: "", sourceTitle: "Pixabay", sourceLink: "https://pixabay.com/music/upbeat-space-chillout-14194/", licenseTitle: "Simplified Pixabay License", licenseLink: "https://pixabay.com/service/license/")) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Space Chillout\"") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "\"Acceleron\"", assetType: .music, assetCatalogName: "", sourceTitle: "Pixabay", sourceLink: "https://pixabay.com/music/synthwave-acceleron-109122/", licenseTitle: "Simplified Pixabay License", licenseLink: "https://pixabay.com/service/license/")) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Acceleron\"") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "\"Autobahn\"", assetType: .music, assetCatalogName: "", sourceTitle: "Pixabay", sourceLink: "https://pixabay.com/music/house-autobahn-99109/", licenseTitle: "Simplified Pixabay License", licenseLink: "https://pixabay.com/service/license/")) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Autobahn\"") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "\"Dancing Racoons\"", assetType: .music, assetCatalogName: "", sourceTitle: "Pixabay", sourceLink: "https://pixabay.com/music/soft-house-dancing-racoons-20793/", licenseTitle: "Simplified Pixabay License", licenseLink: "https://pixabay.com/service/license/")) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Dancing Racoons\"") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "\"Dragonfly\"", assetType: .music, assetCatalogName: "", sourceTitle: "Pixabay", sourceLink: "https://pixabay.com/music/deep-house-dragonfly-15128/", licenseTitle: "Simplified Pixabay License", licenseLink: "https://pixabay.com/service/license/")) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Dragonfly\"") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "\"Protection of Me\"", assetType: .music, assetCatalogName: "", sourceTitle: "Pixabay", sourceLink: "https://pixabay.com/music/deep-house-protection-of-me-by-nazartino-112859/", licenseTitle: "Simplified Pixabay License", licenseLink: "https://pixabay.com/service/license/")) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Protection of Me\"") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "\"Scandinavianz Palmtrees\"", assetType: .music, assetCatalogName: "", sourceTitle: "Pixabay", sourceLink: "https://pixabay.com/music/upbeat-scandinavianz-palmtrees-7326/", licenseTitle: "Simplified Pixabay License", licenseLink: "https://pixabay.com/service/license/")) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Scandinavianz Palmtrees\"") }
                }
                
                NavigationLink(destination: LicensingDetailView(assetTitle: "\"Synthwave 80s\"", assetType: .music, assetCatalogName: "", sourceTitle: "Pixabay", sourceLink: "https://pixabay.com/music/synthwave-synthwave-80s-110045/", licenseTitle: "Simplified Pixabay License", licenseLink: "https://pixabay.com/service/license/")) {
                    HStack { Image(systemName: "music.quarternote.3").imageScale(.large); Text("\"Synthwave 80s\"") }
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
                NavigationLink(destination: LicensingDetailView(assetTitle: "Zephyr", assetType: .software, assetCatalogName: "", sourceTitle: "Ariel Sabintsev", sourceLink: "https://github.com/ArtSabintsev/Zephyr", licenseTitle: "MIT License", licenseLink: "https://github.com/ArtSabintsev/Zephyr/blob/master/LICENSE")) {
                    HStack { Image(systemName: "curlybraces").imageScale(.large); Text("Zephyr") }
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
