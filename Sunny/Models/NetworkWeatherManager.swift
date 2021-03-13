//
//  NetworkWeatherManager.swift
//  Sunny
//
//  Created by Olga Trofimova on 05.01.2021.
//  Copyright © 2021 Ivan Akulov. All rights reserved.
//

import Foundation
import CoreLocation

class NetworkWeatherManager {
    
    enum RequestType {
        case cityName(city: String)
        case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    }
    
    var onCompletion: ((CurrentWeather) -> Void)?
    
    //универсальный метод для запроса и по городу, и по координатам
    
    func fetchCurrentWeather(forRequestType requestType: RequestType) {
        var urlString = ""
        switch requestType {
        case .cityName(let city):
            urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        case .coordinate(let latitude, let longitude):
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        }
        
        performRequest(withURLString: urlString)
    }
    
   fileprivate func performRequest(withURLString urlString: String) {
        guard let url = URL(string: urlString) else { return } //создаем и извлекаем url
        let session = URLSession(configuration: .default) // вся работа с запросами идет через сессию
        //создаем запрос
        let task = session.dataTask(with: url) { (data, response, error) in
            if let data = data {
//                let dataString = String(data: data, encoding: .utf8)
//                print(dataString!)
                if let currentWeather = self.parseJSON(withData: data) {
                    self.onCompletion?(currentWeather)
                }
            }
        }
        //обязательно вызвать .resume()!!!
        task.resume()
    }

    fileprivate func parseJSON(withData data: Data) -> CurrentWeather? {
        let decoder = JSONDecoder()
        do {
            let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data)
            guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else {
                return nil
            }
            print(currentWeatherData.main.temp)
            return currentWeather
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
