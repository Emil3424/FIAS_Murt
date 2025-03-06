using FIAS_Murt.DokumentsFold;
using FIAS_Murt.EmployeesFold;
using FIAS_Murt.Uvedoml;
using FIAS_Murt.ZayavkaFold;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media.Animation;
using WpfAnimatedGif;

namespace FIAS_Murt
{
    /// <summary>
    /// Логика взаимодействия для MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            MainFrame.Content = new MainPage();
            this.KeyDown += MainWindow_KeyDown;
        }
        private readonly List<Key> konamiCode = new()
        { Key.Up, Key.Up, Key.Down, Key.Down, Key.Left, Key.Right, Key.Left, Key.Right};

        private List<Key> currentInput = new();

        private void MainWindow_KeyDown(object sender, KeyEventArgs e)
        {
            currentInput.Add(e.Key);
            if (currentInput.Count > konamiCode.Count)
                currentInput.RemoveAt(0);

            if (currentInput.Count == konamiCode.Count && !konamiCode.Where((t, i) => t != currentInput[i]).Any())
            {
                ShowGIFOverlay();
                currentInput.Clear();
            }
        }

        private void ShowGIFOverlay()
        {
            var controller = ImageBehavior.GetAnimationController(Giff);
            Giff.Visibility = Visibility.Visible;
            ImageBehavior.SetRepeatBehavior(Giff, new RepeatBehavior(1)); // Установите повтор анимации на 1 раз
            controller.Play(); //Запуск анимации
        }

        private void Giff_AnimationCompleted(object sender, RoutedEventArgs e)
        {
            Giff.Visibility = Visibility.Collapsed; // Скрыть GIF после завершения
            ImageBehavior.SetRepeatBehavior(Giff, new RepeatBehavior(0)); // Возвращаем повтор анимации в 0, чтобы больше не воспроизводилась
        }

        private void Navigate_Click(object sender, RoutedEventArgs e)
        {
            TextBlock textBlock
                = sender as TextBlock;
            switch (textBlock.Text)
            {
                case "Главная":
                    MainFrame.Content = new MainPage();
                    break;

                case "ГАР":
                    MainFrame.Content = new GARPage(MainFrame);
                    break;

                case "Заявки":
                    MainFrame.Content = new ZayavkaPage(MainFrame);
                    break;

                case "Карта":
                    MainFrame.Content = new MapPage(MainFrame);
                    break;

                case "Граф":
                    MainFrame.Content = new GraphicPage(MainFrame);
                    break;

                case "Сотрудники":
                    MainFrame.Content = new EmployeesPage(MainFrame);
                    break;

                case "Уведомления":
                    MainFrame.Content = new UvedPage(MainFrame);
                    break;

                case "Документы":
                    MainFrame.Content = new DokumentsPage(MainFrame);
                    break;

                case "Представления":
                    MainFrame.Content = new ViewsPage(MainFrame);
                    break;

                case "Отчет Эксель":
                    MainFrame.Content = new ReportsPage(MainFrame);
                    break;
            }
        }
        private void Image_MouseDown(object sender, MouseButtonEventArgs e)
        {
            try
            {
                Process.Start(new ProcessStartInfo("https://fias.nalog.ru") { UseShellExecute = true });
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Не удалось открыть сайт: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Podderzhka_MouseDown(object sender, MouseButtonEventArgs e)
        {
            try
            {
                Process.Start(new ProcessStartInfo("https://t.me/Murt_Emil") { UseShellExecute = true });
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Не удалось открыть сайт: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private bool isSidebarOpen = false;

        private void ToggleSidebar(object sender, MouseButtonEventArgs e)
        {
            if (isSidebarOpen)
            {
                Storyboard collapse = (Storyboard)FindResource("SidebarCollapse");
                collapse.Begin();
            }
            else
            {
                Storyboard expand = (Storyboard)FindResource("SidebarExpand");
                expand.Begin();
            }
            isSidebarOpen = !isSidebarOpen;
        }
    }
}