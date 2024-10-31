const nboard = @import("module/nboard.zig");
const webui = @import("module/webui.zig");

pub fn main() !void {
  try nboard.init();
  
  webui.start();

  nboard.stop();
  while(nboard.isRunning()){}
}
