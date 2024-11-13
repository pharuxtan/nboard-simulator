const nboard = @import("module/nboard.zig");
const webui = @import("module/webui.zig");

const sym = @import("lib/sym.zig");

pub fn main() !void {
  sym.init();
  defer sym.deinit();

  try nboard.init();
  
  webui.start();

  nboard.stop();
  while(nboard.isRunning()){}
}
