﻿using FIAS_Murt.EmployeesFold;
using FIAS_Murt.Uvedoml;
using FIAS_Murt.ZayavkaFold;
using System.Diagnostics;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

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
        }

        private void TextBlock_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
        }

        private void Navigate_Click(object sender, RoutedEventArgs e)
        {
            TextBlock textBlock
                = sender as TextBlock;
            switch (textBlock.Text)
            {
                case "Меню":
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
        private void ToggleSidebar(object sender, MouseButtonEventArgs e)
        {
            Sidebar.Visibility = Sidebar.Visibility == Visibility.Visible ? Visibility.Collapsed : Visibility.Visible;
        }

    }
}