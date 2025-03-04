using FIAS_Murt.MessageWind;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace FIAS_Murt.DokumentsFold
{
    /// <summary>
    /// Логика взаимодействия для DokumentsPage.xaml
    /// </summary>
    public partial class DokumentsPage : Page
    {
        private FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();
        public DokumentsPage(Frame frame)
        {
            InitializeComponent();
            LoadData();
        }

        private void LoadData()
        {
            try
            {
                dataGridDokuments.ItemsSource = db.Dokuments.ToList();
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
            NavigationService.Navigate(new DokumentsEditPage(null));
        }

        private void EditButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridDokuments.SelectedItem is Dokuments selectedDokument)
            {
                NavigationService.Navigate(new DokumentsEditPage(selectedDokument));
            }
            else
            {
                MessageBox.Show("Выберите документ для редактирования!");
            }
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridDokuments.SelectedItem is Dokuments selectedDokument)
            {
                FRDeleteWindow confirmWindow = new FRDeleteWindow { Owner = Application.Current.MainWindow };
                if (confirmWindow.ShowDialog() == true)
                {
                    try
                    {
                        db.Dokuments.Remove(selectedDokument);
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
                MessageBox.Show("Выберите документ для удаления!");
            }
        }
    }
}