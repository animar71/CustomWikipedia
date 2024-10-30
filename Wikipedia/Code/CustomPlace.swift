import CoreLocation

@objc class CustomPlace: NSObject {
    let coordinate: CLLocationCoordinate2D
    let name: String
    
    init(
        coordinate: CLLocationCoordinate2D,
        name: String
    ) {
        self.coordinate = coordinate
        self.name = name
    }
}
