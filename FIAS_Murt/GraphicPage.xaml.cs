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
            cbGraphs.SelectedIndex = 0;
        }

        private void cbGraphs_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (cbGraphs.SelectedItem is ComboBoxItem item)
            {
                string tableTag = item.Tag.ToString();
                LoadData(tableTag);
            }
        }

        private void LoadData(string tableName)
        {
            try
            {
                SeriesCollection = new SeriesCollection();
                switch (tableName)
                {
                    case "GAR":
                        // По статусуууу ЗВписи
                        var garData = db.GAR.ToList()
                                        .GroupBy(g => g.Status_zap ?? "Не указан")
                                        .Select(g => new { Category = g.Key, Count = g.Count() })
                                        .ToList();
                        foreach (var entry in garData)
                        {
                            SeriesCollection.Add(new PieSeries
                            {
                                Title = entry.Category,
                                Values = new ChartValues<int> { entry.Count },
                                DataLabels = true,
                                LabelPoint = chartPoint => $"{entry.Count} ({chartPoint.Participation:P})"
                            });
                        }
                        break;

                    case "Employees":
                        // КРЧ по первой букве ФИО
                        var empData = db.Employees.ToList()
                                        .GroupBy(emp => emp.FIO.Substring(0, 1).ToUpper())
                                        .Select(g => new { Category = g.Key, Count = g.Count() })
                                        .ToList();
                        foreach (var entry in empData)
                        {
                            SeriesCollection.Add(new PieSeries
                            {
                                Title = entry.Category,
                                Values = new ChartValues<int> { entry.Count },
                                DataLabels = true,
                                LabelPoint = chartPoint => $"{entry.Count} ({chartPoint.Participation:P})"
                            });
                        }
                        break;

                    case "Uvedomleniya":
                        // По типу
                        var uvedData = db.Uvedomleniya.ToList()
                                        .GroupBy(u => u.Type_uved ?? "Не указан")
                                        .Select(g => new { Category = g.Key, Count = g.Count() })
                                        .ToList();
                        foreach (var entry in uvedData)
                        {
                            SeriesCollection.Add(new PieSeries
                            {
                                Title = entry.Category,
                                Values = new ChartValues<int> { entry.Count },
                                DataLabels = true,
                                LabelPoint = chartPoint => $"{entry.Count} ({chartPoint.Participation:P})"
                            });
                        }
                        break;

                    case "Dokuments":
                        // ГПо Типу Документа
                        var dokData = db.Dokuments.ToList()
                                        .GroupBy(d => d.Type_Dok ?? "Не указан")
                                        .Select(g => new { Category = g.Key, Count = g.Count() })
                                        .ToList();
                        foreach (var entry in dokData)
                        {
                            SeriesCollection.Add(new PieSeries
                            {
                                Title = entry.Category,
                                Values = new ChartValues<int> { entry.Count },
                                DataLabels = true,
                                LabelPoint = chartPoint => $"{entry.Count} ({chartPoint.Participation:P})"
                            });
                        }
                        break;

                    default:
                        break;
                }
                DataContext = null;
                DataContext = this;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при загрузке данных графика: " + ex.Message,
                                "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}