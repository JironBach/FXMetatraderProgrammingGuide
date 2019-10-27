#define SW_HIDE 0
#define SW_SHOWNORMAL 1
#define SW_NORMAL 1
#define SW_SHOWMINIMIZED 2
#define SW_SHOWMAXIMIZED 3
#define SW_MAXIMIZE 3
#define SW_SHOWNOACTIVATE 4
#define SW_SHOW 5
#define SW_MINIMIZE 6
#define SW_SHOWMINNOACTIVE 7
#define SW_SHOWNA 8
#define SW_RESTORE 9
#define SW_SHOWDEFAULT 10
#define SW_FORCEMINIMIZE 11
#define SW_MAX 11

#import "shell32.dll"
int ShellExecuteA(int hWnd,int lpVerb,string lpFile,string lpParameters,int lpDirectory,int nCmdShow);
#import

void run_otherpg(string ip){
  string param = "/Users/js/work/nslookup.php "+ip;
  ShellExecuteA(0,0,"c:\\Program Files\\XMTrading MT4\\terminal.exe",param,0,SW_SHOW);
}

int start(){
  run_otherpg("113.150.33.31");
}
