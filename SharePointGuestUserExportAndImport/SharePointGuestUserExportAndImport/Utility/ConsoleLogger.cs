using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SharePointGuestUserExportAndImport
{
    class ConsoleLogger
    {
        public static void Info(string format, params object[] arg)
        {
            Log(ConsoleColor.Green, format, arg);
        }

        public static void Error(string format, params object[] arg)
        {
            Log(ConsoleColor.Red, format, arg);
        }

        private static void Log(ConsoleColor foregroundColor, string format, params object[] arg)
        {
            var temp = Console.ForegroundColor;
            Console.ForegroundColor = foregroundColor;
            Console.WriteLine(format, arg);
            Console.ForegroundColor = temp;
        }
    }
}
