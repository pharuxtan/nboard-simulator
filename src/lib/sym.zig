const std = @import("std");
const windows = std.os.windows;

const PCSTR = [*]const windows.CHAR;

extern "dbghelp" fn SymInitialize(hProcess: windows.HANDLE, UserSearchPath: ?PCSTR, fInvadeProcess: windows.BOOL) callconv(windows.WINAPI) void;
extern "dbghelp" fn SymCleanup(hProcess: windows.HANDLE) callconv(windows.WINAPI) void;

const MODLOAD_DATA = extern struct {
  ssize: windows.DWORD,
  ssig: windows.DWORD,
  data: windows.PVOID,
  size: windows.DWORD,
  flags: windows.DWORD,
};

extern "dbghelp" fn SymLoadModuleEx(hProcess: windows.HANDLE,
                                    hFile: ?windows.HANDLE,
                                    ImageName: PCSTR,
                                    ModuleName: ?PCSTR,
                                    BaseOfDll: windows.DWORD64,
                                    DllSize: windows.DWORD,
                                    Data: ?*MODLOAD_DATA,
                                    Flags: windows.DWORD) callconv(windows.WINAPI) windows.DWORD64;

extern "dbghelp" fn SymUnloadModule64(hProcess: windows.HANDLE, BaseOfDll: windows.DWORD64) callconv(windows.WINAPI) windows.BOOL;

var processHandle: windows.HANDLE = undefined;
var nboardBaseAddr: ?windows.DWORD64 = null;

pub fn init() void {
  processHandle = windows.kernel32.GetCurrentProcess();
  SymInitialize(processHandle, null, windows.FALSE);
}

pub fn deinit() void {
  SymCleanup(processHandle);
}

pub fn loadNboardSymbols() void {
  const snap: windows.HANDLE = windows.kernel32.CreateToolhelp32Snapshot(windows.TH32CS_SNAPMODULE | windows.TH32CS_SNAPMODULE32, 0);
  if(snap != windows.INVALID_HANDLE_VALUE){
    defer windows.CloseHandle(snap);

    var entry: windows.MODULEENTRY32 = undefined;
    entry.dwSize = @sizeOf(windows.MODULEENTRY32);

    if(windows.kernel32.Module32First(snap, &entry) != 0){
      var valid = true;
      while (valid) {
        if(std.mem.eql(u8, entry.szModule[0..10], "nboard.dll")){
          while(SymUnloadModule64(processHandle, @intFromPtr(entry.modBaseAddr)) == windows.TRUE) {}
          const image_name: []u8 = &entry.szExePath;
          const module_name: []u8 = &entry.szModule;
          const base_address = SymLoadModuleEx(processHandle, null, image_name.ptr, module_name.ptr, @intFromPtr(entry.modBaseAddr), entry.modBaseSize, null, 0);
          if(base_address == 0 and windows.kernel32.GetLastError() == windows.Win32Error.SUCCESS){
            nboardBaseAddr = @intFromPtr(entry.modBaseAddr);
          } else if(base_address != 0){
            nboardBaseAddr = base_address;
          } else {
            nboardBaseAddr = null;
          }
          break;
        }
        
        valid = windows.kernel32.Module32Next(snap, &entry) == 1;
      }
    }
  }
}

pub fn unloadNboardSymbols() void {
  if(nboardBaseAddr) |baseAddr| {
    while(SymUnloadModule64(processHandle, baseAddr) == windows.TRUE) {}
    nboardBaseAddr = null;
  }
}