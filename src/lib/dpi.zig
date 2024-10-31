const std = @import("std");
const windows = std.os.windows;
const ntdll = windows.ntdll;

const PROCESS_DPI_AWARENESS = enum(windows.INT) {
  PROCESS_DPI_UNAWARE = 0,
  PROCESS_SYSTEM_DPI_AWARE = 1,
  PROCESS_PER_MONITOR_DPI_AWARE = 2
};

extern "shcore" fn SetProcessDpiAwareness(value: PROCESS_DPI_AWARENESS) callconv(windows.WINAPI) windows.HRESULT;

const DPI_AWARENESS_CONTEXT = enum(isize) { // HANDLE
  DPI_AWARENESS_CONTEXT_UNAWARE = -1,
  DPI_AWARENESS_CONTEXT_SYSTEM_AWARE = -2,
  DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE = -3,
  DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 = -4,
  DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED = -5
};

extern "user32" fn SetProcessDpiAwarenessContext(value: DPI_AWARENESS_CONTEXT) callconv(windows.WINAPI) windows.BOOL;

const WINDOWS_10_1703: windows.ULONG = 15063;
const WINDOWS_10_1607: windows.ULONG = 14393;

pub fn fix() void {
  var lpVersionInformation: windows.OSVERSIONINFOW = undefined;
  lpVersionInformation.dwOSVersionInfoSize = @sizeOf(windows.OSVERSIONINFOW);
  
  if(ntdll.RtlGetVersion(&lpVersionInformation) != windows.NTSTATUS.SUCCESS){
    @setCold(true); // COLD BRANCH
    _ = SetProcessDpiAwareness(PROCESS_DPI_AWARENESS.PROCESS_PER_MONITOR_DPI_AWARE);
    return;
  }

  if(lpVersionInformation.dwBuildNumber >= WINDOWS_10_1703){
    _ = SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
  } else if(lpVersionInformation.dwBuildNumber >= WINDOWS_10_1607) {
    _ = SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE);
  } else {
    _ = SetProcessDpiAwareness(PROCESS_DPI_AWARENESS.PROCESS_PER_MONITOR_DPI_AWARE);
  }
}