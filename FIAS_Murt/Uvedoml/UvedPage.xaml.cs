using FIAS_Murt.MessageWind;
using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;

namespace FIAS_Murt.Uvedoml
{
    /// <summary>
    /// Логика взаимодействия для UvedPage.xaml
    /// </summary>
    public partial class UvedPage : Page
    {
        private readonly FIAS_PraktikaEntities1 db = new();

        public UvedPage(Frame frame)
        {
            InitializeComponent();
            LoadData();
        }

        private void LoadData()
        {
            dataGridUved.ItemsSource = db.Uvedomleniya.ToList();
        }

        private void AddButton_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new UvedEditPage(null));
        }

        private void EditButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridUved.SelectedItem is Uvedomleniya selectedUved)
            {
                NavigationService.Navigate(new UvedEditPage(selectedUved));
            }
            else
            {
                MessageBox.Show("Выберите уведомление для редактирования.");
            }
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridUved.SelectedItem is Uvedomleniya selectedUved)
            {
                FRDeleteWindow confirmWindow = new()
                {
                    Owner = Application.Current.MainWindow
                };
                if (confirmWindow.ShowDialog() == true)
                {
                    try
                    {
                        db.Uvedomleniya.Remove(selectedUved);
                        db.SaveChanges();
                        MessageWindow successWindow = new("Уведомление удалено!")
                        {
                            Owner = Application.Current.MainWindow
                        };
                        successWindow.ShowDialog();
                        LoadData();
                    }
                    catch (Exception ex)
                    {
                        FailMessageWindow errorWindow = new("Ошибка при удалении: " + ex.Message)
                        {
                            Owner = Application.Current.MainWindow
                        };
                        errorWindow.ShowDialog();
                    }
                }
            }
            else
            {
                MessageBox.Show("Выберите уведомление для удаления.");
            }
        }
    }
}