using CommandLine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SharePointGuestUserExportAndImport
{
    public enum Model
    {
        Export,
        Import,
    }
    public class Options
    {
        [Option("output", Required = true)]
        public string ReportFilePath { get; set; }

        [Option('o', "Operation",Required = true)]
        public Model Model { get; set; }

        [Option('f', "FilePath")]
        public string ImportUsersFilePath { get; set; }

    }
}
