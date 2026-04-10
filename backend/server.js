const io = require("socket.io")(3000, {
  cors: { origin: "*" },
});

io.on("connection", (socket) => {
  console.log("User Connected: " + socket.id);

  // চ্যাট মেসেজ হ্যান্ডেল করা
  socket.on("send_message", (data) => {
    io.emit("receive_message", data);
  });

  // কল রিকোয়েস্ট হ্যান্ডেল করা (অন্য ইউজারকে সিগন্যাল পাঠানো)
  socket.on("make_call", (data) => {
    socket.broadcast.emit("incoming_call", data);
  });

  socket.on("disconnect", () => {
    console.log("User Disconnected");
  });
});

console.log("Socket server running on port 3000");
