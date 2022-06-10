//
//  LicensingDetailView.swift
//  One Step Ahead
//
//  Created by Ethan Marshall on 6/10/22.
//

import SwiftUI

/// A view for displaying information about a third-party asset.
struct LicensingDetailView: View {
    
    // MARK: View Variables
    /// The title of the asset this view displays.
    var assetTitle: String
    var assetType: AssetType
    var assetCatalogName: String = ""
    var sourceTitle: String
    var sourceLink: String
    var licenseTitle: String
    var licenseLink: String

    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)
                        .opacity(0.3)
                    
                    switch assetType {
                    case .image:
                        Image(assetCatalogName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .frame(width: 100, height: 100)
                        
                    case .music:
                        Image(assetCatalogName)
                        
                    case .soundEffect:
                        Image(assetCatalogName)
                        
                    case .drawingDataset:
                        Image(assetCatalogName)
                    }
                }
                
                Text(assetTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    switch assetType {
                    case .image:
                        Text("Image Source")
                            .font(.title)
                            .fontWeight(.bold)
                    case .music:
                        Text("Music Source")
                    case .soundEffect:
                        Text("Sound Effect Source")
                    case .drawingDataset:
                        Text("Dataset Source")
                    }
                    
                    Spacer()
                }
                .padding([.top, .leading])
                
                Link(destination: URL(string: sourceLink)!) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .opacity(0.3)
                            .cornerRadius(25)
                        
                        HStack {
                            Image(systemName: "link")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.blue)
                                .padding()
                                .padding(.leading, 7)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sourceTitle)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(sourceLink)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 75)
                
                HStack {
                    switch assetType {
                    case .image:
                        Text("Image License")
                            .font(.title)
                            .fontWeight(.bold)
                    case .music:
                        Text("Music License")
                    case .soundEffect:
                        Text("Sound Effect License")
                    case .drawingDataset:
                        Text("Dataset License")
                    }
                    
                    Spacer()
                }
                .padding([.top, .leading])
                
                Link(destination: URL(string: licenseLink)!) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .opacity(0.3)
                            .cornerRadius(25)
                        
                        HStack {
                            Image(systemName: "building.columns.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.blue)
                                .padding()
                                .padding(.leading, 7)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(licenseTitle)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(licenseLink)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 75)
            }
        }
    }
}

struct LicensingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LicensingDetailView(assetTitle: "Preview Image", assetType: .image, assetCatalogName: "space background", sourceTitle: "Unsplash", sourceLink: "https://unsplash.com/photos/_0eMNseqmYk", licenseTitle: "Unsplash License", licenseLink: "https://unsplash.com/license")
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
