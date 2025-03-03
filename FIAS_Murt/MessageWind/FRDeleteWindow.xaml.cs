using System.Windows;

namespace FIAS_Murt.MessageWind
{
    /// <summary>
    /// Логика взаимодействия для FRDeleteWindow.xaml
    /// </summary>
    public partial class FRDeleteWindow : Window
    {
        public FRDeleteWindow()
        {
            InitializeComponent();
        }

        private void YesButton_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = true;
            Close();
        }

        private void NoButton_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
            Close();
        }
    }
}