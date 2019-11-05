



## 查找publish Nintex Workflow中使用了哪些Action

这个问题来源于一个New Feature Request，客户想要做on-premise 的Nintex Workflow 转移到online Nitex Workflow的功能，但是由于我们当前已经支持了一部分的Nintex Workflow Action的转移，因此需要查找客户环境中的nintex workflow中使用了哪些Action，继而分析还有哪些action没有在支持的action列表中，进而估计开发时间。

Nintex 方面为我们提供了一个脚本可以支持这个功能，具体网址如下：

[Nintex 提供的脚本及说明](http://vadimtabakman.com/nintex-workflow-powershell-find-actions-in-a-workflow-part-6.aspx)

这个脚本提供了不止一个功能，具体都有哪些功能亲们自己看脚本吧，脚本里的注释还是比较清晰的

我在我自己的nintex 10 环境中测试这个脚本是时发现该脚本在New-WebServiceProxy时会throw 异常（只有Nintex 10环境才有这个问题，Nintex 13环境可以正常New出），导致该脚本不可用，研究半天没看出来问题原因，没有办法只好修改了脚本，不再通过WebService获取Nintex Workflow的definition xml，而是使用nwadmin.exe的ExportWorkflow 命令将definition xml先export到磁盘中，再读进内存的方式，具体脚本如下：

[link](/Nintex10 AllWorkflows  Result.png)

[Nintex10 AllWorkflows .ps1](Nintex10 AllWorkflows .ps1)

由于该脚本使用了nwadmin.exe，因此需要将该脚本放在与nwadmin.exe相同的路径下（C:\Program Files\Nintex\Nintex Workflow 2010）

具体的命令行如下:

​       & '.\Nintex10 AllWorkflows .ps1'  -nwlogin domain\username  -nwpassword password –nwresultfilepath  resultFilePath "C:\Result\result.csv" –tempfilepath tempFilePath "c:\Result\temp.nwf"

​       例子：

​       & '.\Nintex10 AllWorkflows .ps1'  -nwlogin domain\username  -nwpassword password -nwresultfilepath "C:\Result\result.csv" -tempfilepath "c:\Result\temp.nwf"

其中resultfilepath为最终输出结果的文件路径，tempfilepath为使用nwadmin.exe exportworkflow时产生的nintex workflow definition xml的文件路径

对于Nintex13环境，因为New-WebServiceProxy好使，因此获取Nintex Workflow的definition xmlb不再需要使用nwadmin.exe的ExportWorkflow命令，直接使用调用WebService提供的API即可，具体脚本如下：



[Nintex13 AllWorkflows.ps1](/Nintex13 AllWorkflows .ps1)

由于该脚本使用了nwadmin.exe（获取当前环境中所有的publish Workflow的信息（包括site url、list title、Workflow name等）），因此需要将该脚本放在与nwadmin.exe相同的路径下（C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\BIN）

命令行与Nintex10的命令行类似：

​       & '.\Nintex13 AllWorkflows.ps1'  -nwlogin domain\username  -nwpassword password –nwresultfilepath  resultFilePath "C:\Result\result.csv" 

​       例子：

​       & '.\Nintex13 AllWorkflows.ps1'  -nwlogin domain\username  -nwpassword password -nwresultfilepath "C:\Result\result.csv"

因为Nintex13的脚本没有使用nwadmin.exe的ExportWorkflow命令来export workflow definition xml，因此不再需要tempfilepath来存储tempfile



最终输出结果如下图:

![img](/Nintex10 AllWorkflows  Result.png)

输出结果包括workflow 的name、parentWeb、level、parentList以及该workflow中包含的nintex workflow action

