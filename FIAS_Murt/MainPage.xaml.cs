using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;

namespace FIAS_Murt
{
    public partial class MainPage : Page
    {
        public MainPage()
        {
            InitializeComponent();
        }

        private void FlipCard_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (!(sender is Border card)) return;

            Grid parentGrid = (Grid)card.Child;
            Grid front = (Grid)parentGrid.Children[0];
            Grid back = (Grid)parentGrid.Children[1];

            ScaleTransform st = new ScaleTransform(1, 1);
            card.RenderTransform = st;

            DoubleAnimation shrinkAnim = new DoubleAnimation(1, 0, TimeSpan.FromMilliseconds(200));
            shrinkAnim.Completed += (s, a) =>
            {
                front.Visibility = front.Visibility == Visibility.Visible ? Visibility.Collapsed : Visibility.Visible;
                back.Visibility = back.Visibility == Visibility.Visible ? Visibility.Collapsed : Visibility.Visible;

                DoubleAnimation expandAnim = new DoubleAnimation(0, 1, TimeSpan.FromMilliseconds(200));
                st.BeginAnimation(ScaleTransform.ScaleXProperty, expandAnim);
            };

            st.BeginAnimation(ScaleTransform.ScaleXProperty, shrinkAnim);
        }
    }
}