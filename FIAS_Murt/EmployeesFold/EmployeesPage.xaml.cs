using FIAS_Murt.MessageWind;
using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace FIAS_Murt.EmployeesFold
{
    /// <summary>
    /// Логика взаимодействия для EmployeesPage.xaml
    /// </summary>
    public partial class EmployeesPage : Page
    {
        private Frame mainFrame;
        private FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();

        public EmployeesPage(Frame frame)
        {
            InitializeComponent();
            try
            {
                LoadData();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка инициализации контекста: " + ex.Message);
            }
        }

        private void LoadData()
        {
            try
            {
                var data = db.Employees.ToList();
                dataGridEmployees.ItemsSource = data;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при загрузке данных: " + ex.Message);
            }
        }

        private void AddButton_Click(object sender, RoutedEventArgs e)
        {
            mainFrame.Navigate(new EmployeesEditPage(mainFrame, db, null));
        }

        private void EditButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridEmployees.SelectedItem is Employees selectedEmployee)
            {
                mainFrame.Navigate(new EmployeesEditPage(mainFrame, db, selectedEmployee));
            }
            else
            {
                MessageBox.Show("Выберите запись для редактирования!");
            }
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridEmployees.SelectedItem is Employees selectedEmployee)
            {
                FRDeleteWindow confirmWindow = new FRDeleteWindow
                {
                    Owner = Application.Current.MainWindow
                };
                if (confirmWindow.ShowDialog() == true)
                {
                    try
                    {
                        db.Employees.Remove(selectedEmployee);
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
                MessageBox.Show("Выберите запись для удаления!");
            }
        }
    }
}