using FIAS_Murt.MessageWind;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;

namespace FIAS_Murt.ZayavkaFold
{
    /// <summary>
    /// Логика взаимодействия для ZayavkaEditPage.xaml
    /// </summary>
    public partial class ZayavkaEditPage : Page
    {
        private FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();
        private Zayavka currentZayavka;
        private bool isNew;

        public ZayavkaEditPage(Zayavka zayavka)
        {
            InitializeComponent();

            if (zayavka == null)
            {
                currentZayavka = new Zayavka();
                isNew = true;
            }
            else
            {
                currentZayavka = db.Zayavka.Find(zayavka.ID_zayavki);
                isNew = false;
                tbID_zayavki.Text = currentZayavka.ID_zayavki.ToString();
                tbType_zayavki.Text = currentZayavka.Type_zayavki;
                tbUroven.Text = currentZayavka.Uroven;
                tbID_GAR.Text = currentZayavka.ID_GAR.ToString();
                tbSozdatel_zayav.Text = currentZayavka.Sozdatel_zayav?.ToString();
                dpData_sozdaniya.SelectedDate = currentZayavka.Data_sozdaniya;
                dpData_sozd2.SelectedDate = currentZayavka.Data_sozd2;
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                currentZayavka.Type_zayavki = tbType_zayavki.Text.Trim();
                currentZayavka.Uroven = tbUroven.Text.Trim();

                if (!int.TryParse(tbID_GAR.Text.Trim(), out int idGar))
                {
                    MessageBox.Show("Введите корректное числовое значение для ID GAR.");
                    return;
                }
                currentZayavka.ID_GAR = idGar;

                if (!string.IsNullOrWhiteSpace(tbSozdatel_zayav.Text))
                {
                    if (!int.TryParse(tbSozdatel_zayav.Text.Trim(), out int sozdatel))
                    {
                        MessageBox.Show("Введите корректное числовое значение для Создателя заявки.");
                        return;
                    }
                    currentZayavka.Sozdatel_zayav = sozdatel;
                }
                else
                {
                    currentZayavka.Sozdatel_zayav = null;
                }

                if (!dpData_sozdaniya.SelectedDate.HasValue)
                {
                    MessageBox.Show("Выберите дату для Даты создания.");
                    return;
                }
                currentZayavka.Data_sozdaniya = dpData_sozdaniya.SelectedDate.Value;

                if (!dpData_sozd2.SelectedDate.HasValue)
                {
                    MessageBox.Show("Выберите дату для Даты создания 2.");
                    return;
                }
                currentZayavka.Data_sozd2 = dpData_sozd2.SelectedDate.Value;

                if (isNew)
                {
                    db.Zayavka.Add(currentZayavka);
                }
                db.SaveChanges();

                MessageWindow successWindow = new MessageWindow("Запись успешно сохранена");
                successWindow.Owner = Application.Current.MainWindow;
                successWindow.ShowDialog();
                NavigationService navService = NavigationService.GetNavigationService(this);
                navService.Navigate(new ZayavkaPage(null));
            }
            catch (Exception ex)
            {
                FailMessageWindow errorWindow = new FailMessageWindow("Ошибка при сохранении: " + ex.Message);
                errorWindow.Owner = Application.Current.MainWindow;
                errorWindow.ShowDialog();
            }
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.GoBack();
        }
    }
}