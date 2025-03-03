using FIAS_Murt.MessageWind;
using System;
using System.Windows;
using System.Windows.Controls;

namespace FIAS_Murt.EmployeesFold
{
    /// <summary>
    /// Логика взаимодействия для EmployeesEditPage.xaml
    /// </summary>
    public partial class EmployeesEditPage : Page
    {
        private FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();
        private Employees currentEmployee;
        private bool isNew;

        public EmployeesEditPage(Employees employee)
        {
            InitializeComponent();

            if (employee == null)
            {
                currentEmployee = new Employees();
                isNew = true;
            }
            else
            {
                // Для редактирования получаем отслеживаемую сущность
                currentEmployee = db.Employees.Find(employee.ID_Empl);
                isNew = false;
                tbID_Empl.Text = currentEmployee.ID_Empl.ToString();
                tbFIO.Text = currentEmployee.FIO;
                tbPhone.Text = currentEmployee.Phone;
                tbEmail.Text = currentEmployee.Email;

                // Первичный ключ нельзя менять
                tbID_Empl.IsEnabled = false;
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // ID сотрудника – только для новой записи
                if (isNew)
                {
                    if (!int.TryParse(tbID_Empl.Text.Trim(), out int id))
                    {
                        MessageBox.Show("Введите корректное числовое значение для ID.");
                        return;
                    }
                    currentEmployee.ID_Empl = id;
                }

                // ФИО – обязательное поле
                string fio = tbFIO.Text.Trim();
                if (string.IsNullOrEmpty(fio))
                {
                    MessageBox.Show("Поле ФИО не должно быть пустым.");
                    return;
                }
                currentEmployee.FIO = fio;

                // Телефон – обязательное, не более 12 символов
                string phone = tbPhone.Text.Trim();
                if (string.IsNullOrEmpty(phone) || phone.Length > 12)
                {
                    MessageBox.Show("Поле Телефон не должно быть пустым и должно содержать не более 12 символов.");
                    return;
                }
                currentEmployee.Phone = phone;

                // Email – необязательное, но если указано – не более 100 символов
                string email = tbEmail.Text.Trim();
                if (!string.IsNullOrEmpty(email) && email.Length > 100)
                {
                    MessageBox.Show("Поле Email должно содержать не более 100 символов.");
                    return;
                }
                currentEmployee.Email = email;

                if (isNew)
                {
                    db.Employees.Add(currentEmployee);
                }
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