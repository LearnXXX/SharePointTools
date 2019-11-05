using System;
using System.IO;
using CommandLine;
using System.Reflection;
using System.Collections.Generic;

namespace SharePointGuestUserExportAndImport
{

    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                var optionResult = Parser.Default.ParseArguments<Options>(args);
                if (optionResult.Tag == ParserResultType.NotParsed)
                {
                    Console.WriteLine("Please input right command line and try again.");
                }
                else
                {
                    optionResult.WithParsed(option => Execute(option));
                }
            }
            catch (Exception e)
            {
                Logger.Instance.Error("An error occurred while running, error: {0}", e.ToString());
            }
            Console.WriteLine("Press any key to esc...");
            Console.ReadKey();
        }
        private static void Execute(Options option)
        {
            switch (option.Model)
            {
                case Model.Export:
                    var exportParameters = GetExpoprtParameter(option);
                    ScriptRunner.Run(GetScriptText("SharePointGuestUserExportAndImport.PS.ExportGuestUsers.ps1"), exportParameters);
                    break;
                case Model.Import:
                    var importParameters = GetImportParameter(option);
                    ScriptRunner.Run(GetScriptText("SharePointGuestUserExportAndImport.PS.ImportGuestUsers.ps1"), importParameters);
                    break;
            }
            Logger.Instance.Info("Please refer {0} to see report.", option.ReportFilePath);
        }

        private static string GetScriptText(string filePath)
        {
            var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(filePath);
            using (var reader = new StreamReader(stream))
            {
                return reader.ReadToEnd();
            }
        }
        private static void TryGetImportUsersFilePath(Options option)
        {
            while (!File.Exists(option.ImportUsersFilePath))
            {
                Console.WriteLine("Please input an exit external user information file path");
                option.ImportUsersFilePath = Console.ReadLine();
            }
        }

        private static Dictionary<string, string> GetImportParameter(Options option)
        {
            TryGetImportUsersFilePath(option);


            Dictionary<string, string> parameters = new Dictionary<string, string>();
            parameters.Add("guestsUsersFilePath", option.ImportUsersFilePath);
            parameters.Add("importUserReport", option.ReportFilePath);
            return parameters;
        }

        private static Dictionary<string, string> GetExpoprtParameter(Options option)
        {
            Dictionary<string, string> parameters = new Dictionary<string, string>();
            parameters.Add("exportReportFilePath", option.ReportFilePath);
            return parameters;
        }
    }
}
