using System;
using System.Windows;
using System.Windows.Controls;

namespace FIAS_Murt
{
    /// <summary>
    /// Логика взаимодействия для GarEditPage.xaml
    /// </summary>
    public partial class GarEditPage : Page
    {
        private readonly Frame mainFrame;
        private readonly FIAS_PraktikaEntities db;
        public GAR Gar { get; set; }

        // Флаг, показывающий, новая это запись или редактирование существующей
        private bool isNew;

        /// <summary>
        /// Если параметр gar == null – создаётся новая запись, иначе редактируется существующая.
        /// </summary>
        public GarEditPage(Frame frame, FIAS_PraktikaEntities context, GAR gar)
        {
            InitializeComponent();
            mainFrame = frame;
            db = context;

            if (gar == null)
            {
                Gar = new GAR();
                isNew = true;
            }
            else
            {
                Gar = gar;
                isNew = false;
                // Заполнение полей для редактирования
                tbID_GAR.Text = Gar.ID_GAR.ToString();
                tbMunOtdel.Text = Gar.Mun_otdel;
                tbAdministrOtdel.Text = Gar.Administr_otdel;
                tbIFNSL_FL.Text = Gar.IFNSL_FL.ToString();
                tbIFNSL_YL.Text = Gar.IFNSL_YL.ToString();
                tbOKATO.Text = Gar.OKATO.ToString();
                tbOKTMO.Text = Gar.OKTMO.ToString();
                tbPochta_Index.Text = Gar.Pochta_Index.ToString();
                tbID_Reestr.Text = Gar.ID_Reestr.ToString();
                tbKadastr_nom.Text = Gar.Kadastr_nom;
                tbStatus_zap.Text = Gar.Status_zap;
                dpData_Vnesenia.SelectedDate = Gar.Data_Vnesenia;
                dpData_aktual.SelectedDate = Gar.Data_aktual;

                // Обычно первичный ключ не редактируют:
                tbID_GAR.IsEnabled = false;
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            if (isNew)
            {
                if (!int.TryParse(tbID_GAR.Text.Trim(), out int id_gar))
                {
                    MessageBox.Show("Неверное значение для ID_GAR. Введите целое число.");
                    return;
                }
                Gar.ID_GAR = id_gar;
            }

            string munOtdel = tbMunOtdel.Text.Trim();
            if (string.IsNullOrEmpty(munOtdel))
            {
                MessageBox.Show("Поле Mun_otdel не должно быть пустым.");
                return;
            }
            Gar.Mun_otdel = munOtdel;

            string administrOtdel = tbAdministrOtdel.Text.Trim();
            if (string.IsNullOrEmpty(administrOtdel))
            {
                MessageBox.Show("Поле Administr_otdel не должно быть пустым.");
                return;
            }
            Gar.Administr_otdel = administrOtdel;

            if (!int.TryParse(tbIFNSL_FL.Text.Trim(), out int ifnsl_fl))
            {
                MessageBox.Show("Неверное значение для IFNSL_FL.");
                return;
            }
            if (ifnsl_fl < 1000 || ifnsl_fl > 9999)
            {
                MessageBox.Show("Значение IFNSL_FL должно быть четырехзначным числом.");
                return;
            }
            Gar.IFNSL_FL = ifnsl_fl;

            if (!int.TryParse(tbIFNSL_YL.Text.Trim(), out int ifnsl_yl))
            {
                MessageBox.Show("Неверное значение для IFNSL_YL.");
                return;
            }
            if (ifnsl_yl < 1000 || ifnsl_yl > 9999)
            {
                MessageBox.Show("Значение IFNSL_YL должно быть четырехзначным числом.");
                return;
            }
            Gar.IFNSL_YL = ifnsl_yl;

            string okatoText = tbOKATO.Text.Trim();
            if (okatoText.Length != 9 || !int.TryParse(okatoText, out int okatoValue))
            {
                MessageBox.Show("Поле OKATO должно содержать 9 цифр.");
                return;
            }
            Gar.OKATO = (int)okatoValue;

            string oktmoText = tbOKTMO.Text.Trim();
            if (oktmoText.Length != 9 || !int.TryParse(oktmoText, out int oktmoValue))
            {
                MessageBox.Show("Поле OKTMO должно содержать 9 цифр.");
                return;
            }
            Gar.OKTMO = (int)oktmoValue;

            if (!int.TryParse(tbPochta_Index.Text.Trim(), out int pochtaIndex))
            {
                MessageBox.Show("Неверное значение для Pochta_Index.");
                return;
            }
            Gar.Pochta_Index = pochtaIndex;

            if (!int.TryParse(tbID_Reestr.Text.Trim(), out int idReestr))
            {
                MessageBox.Show("Неверное значение для ID_Reestr.");
                return;
            }
            Gar.ID_Reestr = idReestr;

            string kadastrNom = tbKadastr_nom.Text.Trim();
            if (string.IsNullOrEmpty(kadastrNom) || kadastrNom.Length > 20)
            {
                MessageBox.Show("Поле Kadastr_nom не должно быть пустым и должно содержать не более 20 символов.");
                return;
            }
            Gar.Kadastr_nom = kadastrNom;

            string statusZap = tbStatus_zap.Text.Trim();
            if (string.IsNullOrEmpty(statusZap) || statusZap.Length > 25)
            {
                MessageBox.Show("Поле Status_zap не должно быть пустым и должно содержать не более 25 символов.");
                return;
            }
            Gar.Status_zap = statusZap;

            if (!dpData_Vnesenia.SelectedDate.HasValue)
            {
                MessageBox.Show("Выберите дату для Data_Vnesenia.");
                return;
            }
            Gar.Data_Vnesenia = dpData_Vnesenia.SelectedDate.Value;

            if (!dpData_aktual.SelectedDate.HasValue)
            {
                MessageBox.Show("Выберите дату для Data_aktual.");
                return;
            }
            Gar.Data_aktual = dpData_aktual.SelectedDate.Value;

            try
            {
                if (isNew)
                {
                    db.GAR.Add(Gar);
                }
                db.SaveChanges();
                mainFrame.Navigate(new GARPage(mainFrame));
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при сохранении данных: " + ex.Message);
            }
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            mainFrame.Navigate(new GARPage(mainFrame));
        }
    }
}