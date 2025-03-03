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
        private Frame mainFrame;
        private FIAS_PraktikaEntities db;
        private bool isNew;
        public Employees Employee { get; set; }

        /// <summary>
        /// Если employee равен null – создаётся новая запись, иначе редактируется существующая.
        /// </summary>
        public EmployeesEditPage(Frame frame, FIAS_PraktikaEntities context, Employees employee)
        {
            InitializeComponent();
            mainFrame = frame;
            db = context;

            if (employee == null)
            {
                Employee = new Employees();
                isNew = true;
            }
            else
            {
                Employee = employee;
                isNew = false;
                tbID_Empl.Text = Employee.ID_Empl.ToString();
                tbFIO.Text = Employee.FIO;
                tbPhone.Text = Employee.Phone;
                tbEmail.Text = Employee.Email;
                // Обычно первичный ключ не редактируют:
                tbID_Empl.IsEnabled = false;
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            // Валидация и присвоение значений

            // ID_Empl (только для новой записи)
            if (isNew)
            {
                if (!int.TryParse(tbID_Empl.Text.Trim(), out int id))
                {
                    MessageBox.Show("Введите корректное числовое значение для ID.");
                    return;
                }
                Employee.ID_Empl = id;
            }

            // ФИО (обязательное поле)
            string fio = tbFIO.Text.Trim();
            if (string.IsNullOrEmpty(fio))
            {
                MessageBox.Show("Поле ФИО не должно быть пустым.");
                return;
            }
            Employee.FIO = fio;

            // Телефон (обязательное, не более 12 символов)
            string phone = tbPhone.Text.Trim();
            if (string.IsNullOrEmpty(phone) || phone.Length > 12)
            {
                MessageBox.Show("Поле Телефон не должно быть пустым и должно содержать не более 12 символов.");
                return;
            }
            Employee.Phone = phone;

            // Email (необязательное, но если указано – не более 100 символов)
            string email = tbEmail.Text.Trim();
            if (!string.IsNullOrEmpty(email) && email.Length > 100)
            {
                MessageBox.Show("Поле Email должно содержать не более 100 символов.");
                return;
            }
            Employee.Email = email;

            try
            {
                if (isNew)
                {
                    db.Employees.Add(Employee);
                }
                db.SaveChanges();
                mainFrame.Navigate(new EmployeesPage(mainFrame));
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при сохранении данных: " + ex.Message);
            }
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            mainFrame.Navigate(new EmployeesPage(mainFrame));
        }
    }
}