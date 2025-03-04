using Microsoft.Web.WebView2.Core;
using System;
using System.Net.Http;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

namespace FIAS_Murt
{
    /// <summary>
    /// Логика взаимодействия для MapPage.xaml
    /// </summary>
    public partial class MapPage : Page
    {
        private readonly string fiasApiUrl = "https://fias.nalog.ru/Public/DownloadPage.aspx?type=API";

        public MapPage(Frame frame)
        {
            InitializeComponent();
            InitializeMapAsync();
        }

        private async void InitializeMapAsync()
        {
            try
            {
                await MapWebView.EnsureCoreWebView2Async(null);

                string html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8' />
    <title>ФИАС-Карта</title>
    <script src='https://api-maps.yandex.ru/2.1/?apikey=ffaceb71-09e9-4465-9116-b354ef1af2ba&lang=ru_RU' type='text/javascript'></script>
    <style>
        html, body, #map {
            width: 100%;
            height: 100%;
            padding: 0;
            margin: 0;
        }
    </style>
    <script type='text/javascript'>
        ymaps.ready(init);

        function init() {
            var myMap = new ymaps.Map('map', {
                center: [56.098044, 54.228128],
                zoom: 17,
                controls: ['zoomControl', 'searchControl']
            });

            var searchControl = myMap.controls.get('searchControl');
            searchControl.options.set('size', 'large');

            // Обработчик клика по карте
            myMap.events.add('click', function (e) {
                var coords = e.get('coords');
                fetchFiasData(coords);
            });

            function fetchFiasData(coords) {
                var lat = coords[0];
                var lon = coords[1];

                // Вызываем C#-метод для запроса ФИАС
                window.chrome.webview.postMessage(JSON.stringify({ latitude: lat, longitude: lon }));
            }

            function addPlacemark(coords, address) {
                var placemark = new ymaps.Placemark(coords, {
                    balloonContent: address
                });
                myMap.geoObjects.add(placemark);
            }

            window.chrome.webview.addEventListener('message', event => {
                var data = JSON.parse(event.data);
                if (data.address) {
                    addPlacemark([data.latitude, data.longitude], data.address);
                } else {
                    alert('Адрес не найден');
                }
            });
        }
    </script>
</head>
<body>
    <div id='map'></div>
</body>
</html>";

                MapWebView.NavigateToString(html);
                MapWebView.WebMessageReceived += OnWebMessageReceived;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка загрузки карты: " + ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async void OnWebMessageReceived(object sender, CoreWebView2WebMessageReceivedEventArgs e)
        {
            try
            {
                var json = e.TryGetWebMessageAsString();
                if (!string.IsNullOrEmpty(json))
                {
                    var data = System.Text.Json.JsonSerializer.Deserialize<FiasRequest>(json);
                    if (data != null)
                    {
                        string address = await GetFiasAddressAsync(data.Latitude, data.Longitude);
                        var response = new { latitude = data.Latitude, longitude = data.Longitude, address };
                        MapWebView.CoreWebView2.PostWebMessageAsString(System.Text.Json.JsonSerializer.Serialize(response));
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка обработки запроса: " + ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private async Task<string> GetFiasAddressAsync(double lat, double lon)
        {
            try
            {
                using (var httpClient = new HttpClient())
                {
                    string requestUrl = $"{fiasApiUrl}/api/Address?lat={lat}&lon={lon}";
                    var response = await httpClient.GetStringAsync(requestUrl);
                    return response; // API возвращает строку с адресом
                }
            }
            catch (Exception)
            {
                return "Адрес не найден";
            }
        }

        private class FiasRequest
        {
            public double Latitude { get; set; }
            public double Longitude { get; set; }
        }
    }
}