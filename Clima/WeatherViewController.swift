//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate ,ChangeCityDelegate{
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "de04a0306aefdb13ebee1ddfcdb72529"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager=CLLocationManager()
    let weatherDataModel=WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate=self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization() // go to info plist and show popup to ask user to allow application to get his location
        locationManager.startUpdatingLocation() // update the current location and send data to didupdatelocations methos whice exist on CLLocationdelegat
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String,parameters:[String:String]){
        Alamofire.request(url,method:.get,parameters:parameters).responseJSON{
            response in
            if response.result.isSuccess{
                let weatherJson:JSON=JSON(response.result.value!)
                self.updateWeatherData(json: weatherJson)
                
            }
            else
            {
                print(response.result.error!)
            }
            
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON){
        if let tempResult=json["main"]["temp"].double{
        weatherDataModel.tempreture=Int(tempResult-273.15)
        weatherDataModel.city=json["name"].stringValue
        weatherDataModel.condition=json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName=weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else
        {
            print("unavialabe")
        }
        
    }
   
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text=String(weatherDataModel.city)
        temperatureLabel.text="\(weatherDataModel.tempreture)°"
        weatherIcon.image=UIImage(named: String(weatherDataModel.weatherIconName))
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get the last element in locations because it is the most accurte
        let location=locations[locations.count-1]
        if location.horizontalAccuracy>0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate=nil // to prevent this viewcontroller recicve data from Cllocationmanger
            print("y=\(location.coordinate.longitude),x=\(location.coordinate.latitude)")
            let longitude=String(location.coordinate.longitude)
            let latitude=String(location.coordinate.latitude)
            let params:[String:String]=["lat":latitude,"lon":longitude,"appid":APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text="unable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnterCityName(city: String) {
        let params:[String:String]=["q":city,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="changeCityName"{
            let destantion = segue.destination as! ChangeCityViewController
            destantion.delegate=self
        }
        
    }
    
    
    
    
}


