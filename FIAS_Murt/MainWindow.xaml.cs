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
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;

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

            // Если ввод превышает длину кода, обрезаем лишнее
            if (currentInput.Count > konamiCode.Count)
                currentInput.RemoveAt(0);

            // Проверяем совпадение
            if (currentInput.Count == konamiCode.Count && !konamiCode.Where((t, i) => t != currentInput[i]).Any())
            {
                ActivateCrackEffect();
                currentInput.Clear();
            }
        }

        private void ActivateCrackEffect()
        {
            Grid mainGrid = this.Content as Grid;
            if (mainGrid == null) return;

            // Начальный и конечный прямоугольники для разрыва
            Rect startRect = new Rect(0, 0, this.Width, this.Height);
            Rect endRect = new Rect(this.Width / 4, 0, this.Width / 2, this.Height);

            RectangleGeometry clipGeometry = new RectangleGeometry(startRect);
            this.Clip = clipGeometry;

            // Создаём анимацию трещины
            RectAnimation crackAnimation = new RectAnimation
            {
                From = startRect,
                To = endRect,
                Duration = TimeSpan.FromSeconds(1),
                AutoReverse = false
            };

            crackAnimation.Completed += (s, e) => ShowPopupImage();

            clipGeometry.BeginAnimation(RectangleGeometry.RectProperty, crackAnimation);
        }

        private void ShowPopupImage()
        {
            Image popupImage = new Image
            {
                Source = new BitmapImage(new Uri("pack://application:,,,/Resources/surprise.png")),
                Width = this.Width,
                Height = this.Height,
                Stretch = Stretch.Uniform,
                RenderTransform = new ScaleTransform(0, 0),
                HorizontalAlignment = HorizontalAlignment.Center,
                VerticalAlignment = VerticalAlignment.Center
            };

            (this.Content as Grid)?.Children.Add(popupImage);

            ScaleTransform scale = new();
            popupImage.RenderTransform = scale;

            DoubleAnimation scaleAnimation = new()
            {
                From = 0,
                To = 1,
                Duration = TimeSpan.FromSeconds(0.5),
                EasingFunction = new BounceEase() { Bounces = 3, Bounciness = 2 }
            };

            scale.BeginAnimation(ScaleTransform.ScaleXProperty, scaleAnimation);
            scale.BeginAnimation(ScaleTransform.ScaleYProperty, scaleAnimation);
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