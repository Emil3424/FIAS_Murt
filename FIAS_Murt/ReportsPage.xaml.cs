using Microsoft.Win32;
using OfficeOpenXml;
using System;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using Word = Microsoft.Office.Interop.Word;

namespace FIAS_Murt
{
    /// <summary>
    /// Логика взаимодействия для ReportsPage.xaml
    /// </summary>
    public partial class ReportsPage : Page
    {
        private FIAS_PraktikaEntities db = new FIAS_PraktikaEntities();

        public ReportsPage(Frame frame)
        {
            InitializeComponent();
            LoadPreviewData();
        }

        private void LoadPreviewData()
        {
            try
            {
                var data = db.GAR.Select(g => new
                {
                    g.ID_GAR,
                    g.Mun_otdel,
                    g.Administr_otdel,
                    g.Kadastr_nom,
                    g.Status_zap,
                    g.Data_Vnesenia,
                    g.Data_aktual
                }).ToList();

                dataGridPreview.ItemsSource = data;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка загрузки данных: " + ex.Message);
            }
        }

        private void btnGenerateExcel_Click(object sender, RoutedEventArgs e)
        {
            SaveFileDialog saveFileDialog = new SaveFileDialog
            {
                Filter = "Файлы Excel (*.xlsx)|*.xlsx",
                Title = "Сохранить отчет в Excel"
            };

            if (saveFileDialog.ShowDialog() == true)
            {
                GenerateExcelReport(saveFileDialog.FileName);
            }
        }

        private void GenerateExcelReport(string filePath)
        {
            try
            {
                var data = db.GAR.Select(g => new
                {
                    g.ID_GAR,
                    g.Mun_otdel,
                    g.Administr_otdel,
                    g.Kadastr_nom,
                    g.Status_zap,
                    g.Data_Vnesenia,
                    g.Data_aktual
                }).ToList();

                ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
                using (var package = new ExcelPackage())
                {
                    var worksheet = package.Workbook.Worksheets.Add("GAR Report");

                    worksheet.Cells[1, 1].Value = "ID_GAR";
                    worksheet.Cells[1, 2].Value = "Муниципальный отдел";
                    worksheet.Cells[1, 3].Value = "Административный отдел";
                    worksheet.Cells[1, 4].Value = "Кадастровый номер";
                    worksheet.Cells[1, 5].Value = "Статус";
                    worksheet.Cells[1, 6].Value = "Дата внесения";
                    worksheet.Cells[1, 7].Value = "Дата актуального внесения";

                    for (int i = 0; i < data.Count; i++)
                    {
                        worksheet.Cells[i + 2, 1].Value = data[i].ID_GAR;
                        worksheet.Cells[i + 2, 2].Value = data[i].Mun_otdel;
                        worksheet.Cells[i + 2, 3].Value = data[i].Administr_otdel;
                        worksheet.Cells[i + 2, 4].Value = data[i].Kadastr_nom;
                        worksheet.Cells[i + 2, 5].Value = data[i].Status_zap;
                        worksheet.Cells[i + 2, 6].Value = data[i].Data_Vnesenia.ToString("dd.MM.yyyy");
                        worksheet.Cells[i + 2, 7].Value = data[i].Data_aktual.ToString("dd.MM.yyyy");
                    }

                    worksheet.Cells.AutoFitColumns();

                    File.WriteAllBytes(filePath, package.GetAsByteArray());

                    MessageBox.Show("Отчёт в Excel успешно создан!", "Успех", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Ошибка при создании отчёта Excel: " + ex.Message);
            }
        }
    }
}