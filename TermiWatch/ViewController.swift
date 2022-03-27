import CoreLocation
import HealthKit
import PMKCoreLocation
import PMKHealthKit
import PromiseKit
import UIKit

let hkDataTypesOfInterest = Set([
  HKObjectType.activitySummaryType(),
  HKCategoryType.categoryType(forIdentifier: .appleStandHour)!,
  HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
  HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
  HKObjectType.quantityType(forIdentifier: .heartRate)!,
  HKObjectType.quantityType(forIdentifier: .stepCount)!,
])

struct OpenWeatherMapResponse: Codable {
    let main: MainResponse
    struct MainResponse: Codable {
        let temp: Double
    }
    let weather: [Weather]
    struct Weather: Codable{
        let main: String
        let description: String
    }
}

func httpTest(apiLink: String) -> String{
    /*
     This is for requesting the internet permission.
     */
    guard let url = URL(string: apiLink) else { return "False" }
//    var gdata:String = ""
    let session = URLSession.shared
    session.dataTask(with: url) { (data, response, error) in
        if let response = response {
            print(response)
        }
        if let data = data {
            print(data)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
        }
    }.resume()
    return "Done"
}


class ViewController: UIViewController, CLLocationManagerDelegate{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var clickBot: UIButton!
    @IBOutlet weak var outputLabel: UILabel!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        firstly {
          CLLocationManager.requestAuthorization()
        }.then { _ in
          HKHealthStore().requestAuthorization(toShare: nil, read: hkDataTypesOfInterest)
        }.catch {
          print("Error:", $0)
        }
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestLocation()

      }
    
    @IBAction func showMessage() {
        let alertController = UIAlertController(title: "TermiWatch", message: "Forked from kuglee, Developed by Masa", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Location data received.")
            print(location)
            let coordinate1: CLLocationCoordinate2D = location.coordinate
            let apiLink:String = "https://api.openweathermap.org/data/2.5/weather?"
            + "lat=\(coordinate1.latitude)"
            + "&lon=\(coordinate1.longitude)"
            + "&APPID=7a50241bcd95028607b60ff46502c08e"
            self.outputLabel.text = "Location Get, Requesting API"
            guard let url = URL(string: apiLink) else {return}
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                if let data = data {
                    print(data)
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                        DispatchQueue.main.async{
                            self.outputLabel.font = UIFont.systemFont(ofSize: 10.0)
                            self.outputLabel.text = String(data: data, encoding: String.Encoding.utf8) as String?
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get users location.")
    }
}

