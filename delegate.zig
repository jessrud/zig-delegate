const std = @import("std");

pub fn Delegate(comptime Context: type) type {
    return struct {
        reciever: usize,
        rawCallBack: fn (usize, Context) void,

        fn create(reciever: anytype, comptime func: fn (@TypeOf(reciever), Context) void) @This() {
            const recieverType = @TypeOf(reciever);
            return .{
                .reciever = @ptrToInt(reciever),
                .rawCallBack = struct {
                    fn rawCallback(ptr: usize, other: Context) void {
                        return func(@intToPtr(recieverType, ptr), other);
                    }
                }.rawCallback,
            };
        }
        fn call(self: @This(), other: Context) void {
            self.rawCallBack(self.reciever, other);
        }
    };
}

test "example" {
    const SomeEvent = struct { in: usize };

    const Foo = struct {
        n: usize,

        fn callback(self: *@This(), event: SomeEvent) void {
            self.n += event.in;
        }
    };

    var foo = Foo{ .n = 0 };
    const fooCB = Delegate(SomeEvent).create(&foo, Foo.callback);
    var event = SomeEvent{ .in = 5 };

    std.debug.print("\n{}\n", .{foo.n});

    fooCB.call(event);
    std.debug.print("{}\n", .{foo.n});
}
