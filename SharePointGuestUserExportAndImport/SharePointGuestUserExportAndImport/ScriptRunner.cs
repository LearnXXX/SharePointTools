using System;
using System.Collections;
using System.Management.Automation;
using System.Threading;

namespace SharePointGuestUserExportAndImport
{
    class ScriptRunner
    {
        public static void Run(string script, IDictionary parameters)
        {
            using (PowerShell powerShellInstance = PowerShell.Create())
            {
                powerShellInstance.AddScript(script);
                powerShellInstance.AddParameters(parameters);
                PSDataCollection<PSObject> outputCollection = new PSDataCollection<PSObject>();
                outputCollection.DataAdded += DataAddedInfo;
                powerShellInstance.Streams.Error.DataAdded += DataAddedError;
                IAsyncResult result = powerShellInstance.BeginInvoke<PSObject, PSObject>(null, outputCollection);
                while (result.IsCompleted == false)
                {
                    Thread.Sleep(1000);
                }
            }
        }


        private static void DataAddedInfo(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<PSObject> temp = sender as PSDataCollection<PSObject>;
            if (temp != null)
            {
                Logger.Instance.Info(temp[e.Index].ToString());
            }
        }

        private static void DataAddedError(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<ErrorRecord> temp = sender as PSDataCollection<ErrorRecord>;
            if (temp != null)
            {
                Logger.Instance.Error(temp[e.Index].ToString());
            }
        }
    }
}
