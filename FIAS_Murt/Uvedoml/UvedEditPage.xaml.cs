using FIAS_Murt.MessageWind;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;

namespace FIAS_Murt.Uvedoml
{
    /// <summary>
    /// Логика взаимодействия для UvedEditPage.xaml
    /// </summary>
    public partial class UvedEditPage : Page
    {
        private FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();
        private Uvedomleniya currentUved;

        public UvedEditPage(Uvedomleniya uved)
        {
            InitializeComponent();
            if (uved != null)
            {
                currentUved = db.Uvedomleniya.Find(uved.ID_Uved);
                if (currentUved != null)
                {
                    tbID_Zayavki.Text = currentUved.ID_Zayavki?.ToString();
                    tbType_Uved.Text = currentUved.Type_uved;
                    tbStatus_Uved.Text = currentUved.Status_uved;
                    dpData_Ispoln.SelectedDate = currentUved.Data_ispoln_1;
                    tbKommentarii.Text = currentUved.Kommentarii;
                }
            }
            else
            {
                currentUved = new Uvedomleniya();
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                currentUved.ID_Zayavki = int.TryParse(tbID_Zayavki.Text, out int idZ) ? idZ : (int?)null;
                currentUved.Type_uved = tbType_Uved.Text;
                currentUved.Status_uved = tbStatus_Uved.Text;
                currentUved.Data_ispoln_1 = dpData_Ispoln.SelectedDate;
                currentUved.Kommentarii = tbKommentarii.Text;

                if (currentUved.ID_Uved == 0)
                {
                    db.Uvedomleniya.Add(currentUved);
                }

                db.SaveChanges();
                MessageWindow successWindow = new MessageWindow("Уведомление сохранено!");
                successWindow.Owner = Application.Current.MainWindow;
                successWindow.ShowDialog();
                NavigationService navService = NavigationService.GetNavigationService(this);
                navService.Navigate(new UvedPage(null));
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