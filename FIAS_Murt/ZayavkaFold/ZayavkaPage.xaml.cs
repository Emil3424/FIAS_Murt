using FIAS_Murt.MessageWind;
using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;

namespace FIAS_Murt.ZayavkaFold
{
    /// <summary>
    /// Логика взаимодействия для ZayavkaPage.xaml
    /// </summary>
    public partial class ZayavkaPage : Page
    {
        private FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();

        public ZayavkaPage(Frame frame)
        {
            InitializeComponent();
            LoadData();
        }

        private void LoadData()
        {
            try
            {
                dataGridZayavka.ItemsSource = db.Zayavka.ToList();
            }
            catch (Exception ex)
            {
                FailMessageWindow errorWindow = new FailMessageWindow("Ошибка загрузки данных: " + ex.Message);
                errorWindow.Owner = Application.Current.MainWindow;
                errorWindow.ShowDialog();
            }
        }

        private void AddButton_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new ZayavkaEditPage(null));
        }

        private void EditButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridZayavka.SelectedItem is Zayavka selectedZayavka)
            {
                NavigationService.Navigate(new ZayavkaEditPage(selectedZayavka));
            }
            else
            {
                MessageBox.Show("Выберите заявку для редактирования!");
            }
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridZayavka.SelectedItem is Zayavka selectedZayavka)
            {
                FRDeleteWindow confirmWindow = new FRDeleteWindow { Owner = Application.Current.MainWindow };
                if (confirmWindow.ShowDialog() == true)
                {
                    try
                    {
                        db.Zayavka.Remove(selectedZayavka);
                        db.SaveChanges();
                        MessageWindow successWindow = new MessageWindow("Запись успешно удалена");
                        successWindow.Owner = Application.Current.MainWindow;
                        successWindow.ShowDialog();
                        LoadData();
                    }
                    catch (Exception ex)
                    {
                        FailMessageWindow errorWindow = new FailMessageWindow("Ошибка при удалении: " + ex.Message);
                        errorWindow.Owner = Application.Current.MainWindow;
                        errorWindow.ShowDialog();
                    }
                }
            }
            else
            {
                MessageBox.Show("Выберите заявку для удаления!");
            }
        }
    }
}