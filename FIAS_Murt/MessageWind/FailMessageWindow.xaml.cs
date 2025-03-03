using System.Windows;

namespace FIAS_Murt.MessageWind
{
    /// <summary>
    /// Логика взаимодействия для FailMessageWindow.xaml
    /// </summary>
    public partial class FailMessageWindow : Window
    {
        public FailMessageWindow(string message)
        {
            InitializeComponent();
            tbMessage.Text = message;
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }
    }
}