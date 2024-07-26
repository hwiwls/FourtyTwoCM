//
//  CustomAnnotation.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/21/24.
//

import Foundation
import MapKit
import CoreLocation

final class CustomAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var imageName: String?
    var post: Post?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
