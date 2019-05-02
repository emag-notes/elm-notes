const { Elm } = require("./elm.js");

const app = Elm.Main.init();

app.ports.tick.subscribe(count => {
  console.log(count);
});
