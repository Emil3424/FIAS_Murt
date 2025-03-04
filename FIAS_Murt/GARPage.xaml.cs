using FIAS_Murt.MessageWind;
using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace FIAS_Murt
{
    /// <summary>
    /// Логика взаимодействия для GAR.xaml
    /// </summary>
    public partial class GARPage : Page
    {
        private readonly Frame mainFrame;
        private readonly FIAS_PraktikaEntities db;

        public GARPage(Frame frame)
        {
            InitializeComponent();

            try
            {
                db = new FIAS_PraktikaEntities();
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
                var data = db.GAR.ToList();

                if (!data.Any())
                {
                    MessageBox.Show("В таблице GAR нет данных.");
                }
                dataGridGar.ItemsSource = data;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при загрузке данных: " + ex.Message);
                Console.WriteLine(ex);
            }
        }

        private void AddButton_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new GarEditPage(mainFrame, db, null));
        }

        private void EditButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridGar.SelectedItem is GAR selectedGar)
            {
                NavigationService.Navigate(new GarEditPage(mainFrame, db, selectedGar));
            }
            else
            {
                MessageBox.Show("Выберите запись для редактирования!");
            }
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {
            if (dataGridGar.SelectedItem is GAR selectedEmployee)
            {
                FRDeleteWindow confirmWindow = new FRDeleteWindow
                {
                    Owner = Application.Current.MainWindow
                };
                if (confirmWindow.ShowDialog() == true)
                {
                    try
                    {
                        db.GAR.Remove(selectedEmployee);
                        db.SaveChanges();
                        MessageWindow successWindow = new MessageWindow("Запись успешно удалена")
                        {
                            Owner = Application.Current.MainWindow
                        };
                        successWindow.ShowDialog();
                        LoadData();
                    }
                    catch (Exception ex)
                    {
                        // Показываем окно ошибки
                        FailMessageWindow errorWindow = new FailMessageWindow("Ошибка при удалении: " + ex.Message)
                        {
                            Owner = Application.Current.MainWindow
                        };
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