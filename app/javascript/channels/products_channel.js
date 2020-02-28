import consumer from "./consumer";

consumer.subscriptions.create("ProductsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to the products stream!");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    // ! only update the main store page, otherwise any page you are one gets updated when the price changes :)
    $("#main.store").html(data.html);
    console.log("Recieving:");
    // console.log(data.content);
  }
});

// let submit_messages;

// $(document).on("turbolinks:load", function() {
//   submit_messages();
// });

// submit_messages = function() {
//   $("#message_content").on("keydown", function(event) {
//     if (event.keyCode == 13) {
//       $("input").click();
//       event.target.value = "";
//       event.preventDefault();
//     }
//   });
// };
