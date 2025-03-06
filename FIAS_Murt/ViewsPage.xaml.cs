using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace FIAS_Murt
{
    public partial class ViewsPage : Page
    {
        private readonly FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();

        public ViewsPage(Frame frame)
        {
            InitializeComponent();
            LoadViewList();
        }

        private void LoadViewList()
        {
            cbViews.Items.Add("FullGAR");
            cbViews.Items.Add("ZayavkaDetails");
            cbViews.Items.Add("EmployeeActivity");
            cbViews.Items.Add("AdresZayavkaProsm");
            cbViews.Items.Add("UvedProsm");
            cbViews.SelectedIndex = 0; //  По умол крч ставим первое представление
        }

        private void cbViews_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (cbViews.SelectedItem != null)
            {
                LoadViewData(cbViews.SelectedItem.ToString());
            }
        }

        private void LoadViewData(string viewName)
        {
            try
            {
                switch (viewName)
                {
                    case "FullGAR":
                        dgViews.ItemsSource = db.FullGAR.ToList();
                        break;

                    case "ZayavkaDetails":
                        dgViews.ItemsSource = db.ZayavkaDetails.ToList();
                        break;

                    case "EmployeeActivity":
                        dgViews.ItemsSource = db.EmployeeActivity.ToList();
                        break;

                    case "AdresZayavkaProsm":
                        dgViews.ItemsSource = db.AdresZayavkaProsm.ToList();
                        break;

                    case "UvedProsm":
                        dgViews.ItemsSource = db.UvedProsm.ToList();
                        break;

                    default:
                        MessageBox.Show("Представление не найдено.",
                                        "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                        break;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при загрузке представления " + viewName + ": " + ex.Message,
                                "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}