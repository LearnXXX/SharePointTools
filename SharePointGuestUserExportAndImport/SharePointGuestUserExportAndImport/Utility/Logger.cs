using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;

namespace SharePointGuestUserExportAndImport
{
    public class Logger
    {
        private static Logger logger;
        private static string fileName;
        private Logger()
        {
            fileName = string.Format("{0}.log", Path.Combine(System.IO.Directory.GetCurrentDirectory(), DateTime.Now.ToString("yyyyMMddmmss")));
            File.Create(fileName).Dispose();
        }

        public static Logger Instance
        {
            get
            {
                if (logger == null)
                {
                    logger = new Logger();
                }
                return logger;
            }
        }
        public void Info(string format, params object[] arg)
        {
            try
            {
                ConsoleLogger.Info(format, arg);
                File.AppendAllLines(fileName, new string[] { string.Format(format, arg) });
            }
            catch (Exception e)
            {
                this.Error("An error occurred while write info log, error: {0}", e.ToString());
            }
        }

        public void Error(string format, params object[] arg)
        {
            try
            {
                ConsoleLogger.Error(format, arg);
                File.AppendAllLines(fileName, new string[] { string.Format(format, arg) });
            }
            catch (Exception e)
            {
                Console.WriteLine("An error occurred while write error log, error: {0}", e.ToString());
            }
        }
    }
}
