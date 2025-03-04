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
    /// Логика взаимодействия для DokumentsEditPage.xaml
    /// </summary>
    public partial class DokumentsEditPage : Page
    {
        private FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();
        private Dokuments currentDokument;
        private bool isNew;
        public DokumentsEditPage(Dokuments dokument)
        {
            InitializeComponent();

            if (dokument == null)
            {
                currentDokument = new Dokuments();
                isNew = true;
            }
            else
            {
                currentDokument = db.Dokuments.Find(dokument.ID_Dok);
                isNew = false;
                tbID_Dok.Text = currentDokument.ID_Dok.ToString();
                tbType_Dok.Text = currentDokument.Type_Dok;
                dpDate_Dok.SelectedDate = currentDokument.Date_Dok;
                tbNaimenovanie.Text = currentDokument.Naimenovanie;
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Считывание типа документа
                currentDokument.Type_Dok = tbType_Dok.Text.Trim();

                // Дата документа — обязательна для выбора
                if (!dpDate_Dok.SelectedDate.HasValue)
                {
                    MessageBox.Show("Выберите дату для Даты документа.");
                    return;
                }
                currentDokument.Date_Dok = dpDate_Dok.SelectedDate.Value;

                // Наименование
                currentDokument.Naimenovanie = tbNaimenovanie.Text.Trim();

                if (isNew)
                    db.Dokuments.Add(currentDokument);
                db.SaveChanges();

                MessageWindow successWindow = new MessageWindow("Запись успешно сохранена");
                successWindow.Owner = Application.Current.MainWindow;
                successWindow.ShowDialog();
                NavigationService.GoBack();
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