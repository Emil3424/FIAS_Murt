using LiveCharts;
using LiveCharts.Wpf;
using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace FIAS_Murt
{
    public partial class GraphicPage : Page
    {
        public SeriesCollection SeriesCollection { get; set; }

        private FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();

        public GraphicPage(Frame frame)
        {
            InitializeComponent();
            DataContext = this;
            LoadData();
        }

        private void LoadData()
        {
            try
            {
                var data = db.Zayavka.ToList();

                var grouped = data.GroupBy(z => z.Type_zayavki ?? "Не указан")
                                  .Select(g => new { Type = g.Key, Count = g.Count() })
                                  .ToList();

                SeriesCollection = new SeriesCollection();
                foreach (var item in grouped)
                {
                    SeriesCollection.Add(new PieSeries
                    {
                        Title = item.Type,
                        Values = new ChartValues<int> { item.Count },
                        DataLabels = true,
                        LabelPoint = chartPoint => $"{item.Count} ({chartPoint.Participation:P})"
                    });
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при загрузке данных графика: " + ex.Message,
                                "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}